#!/usr/bin/env perl

use 5.014;
use warnings;

use Regexp::Common qw /URI/;
use File::Basename 'basename';
use CGI;

#

open my $fh, '<', $ARGV[0] or die $!;

my $urls = {};

my $found = 0;
my $date;
my $url;
while (<$fh>)
{
  /^\[[#\w]+\s+([:\d]+)\].*($RE{URI}{HTTP}{ -scheme => qr{https?} })/ &&
    do
    {
      $found++;
      $date = $1;
      $url  = $2;
      $urls->{$date}{$url}++
    };

  $found && /brownian> \[ ([\w\W]+) \]/ &&
    do
    {
      $found--;
      $urls->{$date}{$url} = $1;
      $date = $url = undef;
    };
}

close $fh;

# HTML

my $cgi = CGI->new;

say $cgi->start_html(-title => 'Links from #heartofgold');
say $cgi->h1( 'Links from ' . $cgi->a( { href => basename $ARGV[0] }, basename $ARGV[0] ) );

foreach my $date (sort {
    join('', (split ':', $a)[0,1,2]) cmp join('', (split ':', $b)[0,1,2]);
  } keys $urls)
{

  say $cgi->h2( $date );
  say $cgi->ul( $cgi->li({-type=>'disc'}, [ sort map { "$urls->{$date}{$_}  : " . $cgi->a( { href => $_ }, $_ ) } sort keys $urls->{$date} ]) );
}

say $cgi->end_html;
