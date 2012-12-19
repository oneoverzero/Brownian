#!/usr/bin/env perl

use 5.014;
use warnings;

use File::Basename 'basename';
use Regexp::Common qw/URI/;
use Mojo::Template;
use Getopt::Long;

my $templates = {

  default => <<'DEFAULT',
% my ( $urls, $file ) = @_;
<!DOCTYPE html>
<!-- @smpb was here -->
<html>
  <head>
    <title>Links from #heartofgold</title>
    <style type="text/css">
      body  { background: #eee; font-family: 'Trebuchet MS' sans-serif; }
      h1#t  { text-align: center; margin-bottom: 30px; }
      h2    { font-size: 1em; }
      ul    { list-style-type: none; }
      #c    { background: #fff; border:1px solid #ccc; margin:auto; width: 90%; padding: 10px; }
      .ll   { margin-bottom: 30px; }
      .id   { color:#c00; font-style:italic; }
    </style>
  </head>
  <body>
    <h1 id='t'>Links from backlog '<a href='<%= $file %>'><%= $file %></a>'</h1>
    <div id='c'>
      % foreach my $date (sort { join('', (split ':', $a)[0,1]) cmp join('', (split ':', $b)[0,1]); } keys %$urls)
      % {
      <h2>[<%= $date %>]</h2>
      <ul class='ll'>
      %   foreach my $user ( sort keys %{$urls->{$date}} )
      %   {
        <li><span class='id'><%= $user %></span> shared <a href='<%= $urls->{$date}{$user}{url} %>'><%= $urls->{$date}{$user}{title} %></a></li>
      %   }
      </ul>
      % }
    </div>
  </body>
</html>
DEFAULT

};


my $parsers = {

  brownian => sub {
    my ($line, $output) = @_;

    state $found;
    state $date;
    state $user;

    # we found a new url
    if ($line =~ /^\[[#\w]+\s+(\d+:\d+).*<([\w]+)>.*($RE{URI}{HTTP}{ -scheme => qr{https?} })/)
    {
      $date = $1;
      $user = $2;

      $found = $3;
      $output->{$date}{$user}{url}   = $3;
      $output->{$date}{$user}{title} = $3;
    }

    # we found the line in which brownian spews out the url's description
    if ($found and $line =~ /brownian> \[ ([\w\W]+) \]/)
    {
      $output->{$date}{$user}{title} = $1 if ($found eq $output->{$date}{$user}{url});
      $found = $date = $user = undef;
    }
  }

};


sub parse
{
  my ($file, $action) = @_;
  my $output = {};

  open my $fh, '<', $file or do { say "ERROR: $!"; exit };

  while (<$fh>)
  {
    $action->($_, $output);
  }

  close $fh;
  return $output;
}

#

my $i; my $o;
my $p = 'brownian';
my $t = 'default';

GetOptions(
  'input=s'  => \$i,
  'output=s' => \$o,
  'parser=s' => \$p,
  'template' => \$t
);

unless (defined $i) { say "ERROR: no '--input' file specified."; exit }
unless (defined $templates->{$t}) { say "ERROR: unknown template specified."; exit }

#

my $mt   = Mojo::Template->new;
my $urls = &parse($i, $parsers->{$p});
my $html = $mt->render($templates->{$t}, $urls, basename $i);

if (defined $o)
{
  open my $fh, '>', $o or do { say "ERROR: $!"; exit };
  print $fh $html;
  close $fh;
}
else
{
  say $html;
}

