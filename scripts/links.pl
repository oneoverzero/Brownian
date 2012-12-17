#!/usr/bin/env perl

use 5.014;
use warnings;

use Regexp::Common qw /URI/;
use CGI;

#

open my $fh, '<', $ARGV[0] or die $!;

my $urls = {};

while (<$fh>)
{
  /^([-\d]+).*($RE{URI}{HTTP})/ && do { $urls->{$1}{$2}++ };
}

close $fh;

# HTML

my $cgi = CGI->new;

say $cgi->start_html(-title => 'Links from #heartofgold');
say $cgi->h1( 'Links from #heartofgold' );

foreach my $date (sort {
    join('', (split '-', $a)[2,1,0]) cmp join('', (split '-', $b)[2,1,0]);
  } keys $urls)
{

  say $cgi->h2( $date );
  say $cgi->ul( $cgi->li({-type=>'disc'}, [ sort map { $cgi->a( { href => $_ }, $_ ) } sort keys $urls->{$date} ]) );
}

say $cgi->end_html;
