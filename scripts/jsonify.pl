#!/usr/bin/env perl

use 5.014;
use warnings;

use Mojo::JSON;
use Data::Dumper;
use Getopt::Long;
use File::Basename 'fileparse';

my $parsers = {

  brownian => sub {
    my ($line, $output) = @_;
    my $date; my $type;
    my $user; my $body;

    given ( $line )
    {
      when ( /([:\d]+).*<(.+?)> (.*)/ )
      {
        $date = $1;
        $type = 'dialog';
        $user = $2;
        $body = $3;
      }

      when ( /([:\d]+).*TOPIC: (.+?) - (.*)/ )
      {
        $date = $1;
        $type = 'topic';
        $user = $2;
        $body = "changed the topic to '$3'";
      }

      when ( /([:\d]+).*(JOIN|PART): (.+)/ )
      {
        $date = $1;
        $type = lc $2;
        $user = $3;
        $body = "has " . $type . "ed the channel";
      }

      when ( /([:\d]+).*QUIT: (.+?) \((.*)\)/ )
      {
        $date = $1;
        $type = 'quit';
        $user = $2;
        $body = "has quit ($3)";
      }

      when ( /([:\d]+).*KICK: (.+?) - (.+) \((.*)\)/ )
      {
        $date = $1;
        $type = 'kick';
        $user = $2;
        $body = "kicked user $3 ($4)";
      }

      when ( /([:\d]+).*NICK: (.+?) - (.+)/ )
      {
        $date = $1;
        $type = 'nick';
        $user = $2;
        $body = "changed his nick to '$3'";
      }
    }

    if ($date)
    {
      push @$output, {
        date => $date,
        type => $type,
        user => $user,
        body => $body,
      };
    }
  },
};


sub parse
{
  my ($file, $action) = @_;
  my $output = [];

  open my $fh, '<', $file or do { say "ERROR: $!"; exit };

  while (<$fh>)
  {
    $action->($_, $output);
  }

  close $fh;
  return $output;
}

#

my $f;
my $i = 'new';
my $o = '.';
my $p = 'brownian';

GetOptions(
  'input=s'  => \$i,
  'output=s' => \$o,
  'parser=s' => \$p,
  'file=s'   => \$f,
);

unless (defined $i) { say "ERROR: no '--input' directory specified."; exit }
unless (defined $parsers->{$p}) { say "ERROR: unknown parsers specified."; exit }

#

my $mj    = Mojo::JSON->new;

opendir my $dh, $i or die "$!";
my @files;

my $pattern = defined $f ? qr/$f/ : qr/heartofgold/i;

@files = grep { /$pattern/ } readdir $dh;

foreach my $log ( @files )
{
  say $log;
  my $lines = &parse( "$i/$log", $parsers->{$p});
  say Dumper $lines if ($ENV{DEBUG});
  my $json  = $mj->encode($lines);

  my ($name) = fileparse $log, '.log';
  open my $fh, '>', "$o/$name.json" or do { say "ERROR: $!"; exit };
  print $fh $json;
  close $fh;
}

close $dh;

