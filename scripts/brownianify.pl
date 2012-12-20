#!perl

#
# convert logs, primarily from the 'bip proxy' format, into Brownian's
#

use 5.014;
use warnings;

use DateTime;
use Data::Dumper;
use Getopt::Long;
use Regexp::Grammars;

use File::Spec;
use File::Basename 'dirname';

# vars

my $grammar = '../etc/bip.grammar';
my $channel = '#heartofgold';
my $input;
my $output;
my $db;

# main

GetOptions( 'grammar=s' => \$grammar,
            'channel=s' => \$channel,
            'input=s'   => \$input,
            'output=s'  => \$output,
          );

unless (defined $input) { say "ERROR: no '--input' dir specified."; exit }
unless (defined $output) { say "ERROR: no '--output' dir specified."; exit }

# parser spec

open my $fh, '<', $grammar or die $!; 
my $spec = lc do { local $/; <$fh> };
close $fh;

my $parser = eval "qr{ $spec }x";

# log

opendir my $dh, $input or die "$!";
my @files;
{
  no Regexp::Grammars;
  @files = grep { /heartofgold/i } readdir $dh;
}

foreach my $log ( @files )
{
  say $log;
  open my $ifh, '<', "$input/$log"  or die $!;
  open my $ofh, '>', "$output/$log" or die $!;

  while (my $line = <$ifh>)
  {
    if ($line =~ $parser)
    {
      say $ofh "$line" . Dumper \%/ if $ENV{DEBUG};

      my $dt = DateTime->new( %{ $/{date} } );

      my ( $type ) = grep { $_ ne 'date' } keys %/;
      my $sender = $/{$type}{sender};

      my $header = "[$channel " . $dt->hms . "]";

      given ( $type )
      {
        when ('aka')
        {
          say $ofh "$header NICK: $sender - " . $/{aka}{target};
        }

        when ('dialog')
        {
          my $source = (ref $/{$type}{source} eq 'HASH') ? $/{$type}{source} : {};
          my $line = $header;

          if ((defined $source->{name}) and
              ($sender ne 'subetha') and
              ($source->{name} eq 'subetha'))
          {
            $line .= ' <subetha>';
          }

          utf8::decode $/{dialog}{content};
          say $ofh "$line <$sender> " . $/{dialog}{content};
        }

        when ('topic')
        {
          utf8::decode $/{topic}{content};
          say $ofh "$header TOPIC: $sender - " . $/{topic}{content};
        }

        when ('join')
        {
          say $ofh "$header JOIN: $sender";
        }

        when ('quit')
        {
          my $reason = $/{quit}{content} || '';
          say $ofh "$header QUIT: $sender ($reason)";
        }

        when ('kick')
        {
          my $reason = $/{kick}{content} || '';
          say $ofh "$header KICK: $sender - " . $/{kick}{target} . " ($reason)";
        }
      }
    }
    else { say "FAIL: $line" if $ENV{DEBUG} }
  }

  close $ifh;
  close $ofh;
}

close $fh;

