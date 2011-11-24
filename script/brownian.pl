#!/usr/bin/env perl

use warnings;
use strict;

use File::Spec;
use File::Basename 'dirname';
use Bot::BasicBot::Pluggable;
use Bot::BasicBot::Pluggable::Brownian;

use lib join '/', File::Spec->splitdir(dirname(__FILE__)), '..', 'lib';
use lib '/home/infobot/lib';


my $brownian = Bot::BasicBot::Pluggable->new(
    channels => [ "#heartofgold" ],
    server   => "irc.freenode.net",
    nick     => "brownian",
    name     => "Heart of Gold's brownian motion producer",
);

$brownian->load("Loader");
$brownian->load("Auth");
$brownian->load("Seen");
$brownian->load("Infobot");
$brownian->load("Title");
$brownian->load("Karma");

$brownian->run();

