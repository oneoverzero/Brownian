#!/usr/bin/env perl

use strict;
use warnings;

use Module::Build;

my $build = Module::Build->new(
  module_name   => 'Bot::BasicBot::Pluggable::Module::Brownian',
  dist_version  => '0.01',
  dist_abstract => 'IRC brownian motion producer',
  license       => 'perl',
  requires      => {
    'perl' => '5.10.1',
    'Bot::BasicBot::Pluggable::Module' => 0,
  },
  configure_requires  => { 'Module::Build'  => 0 },
  add_to_cleanup      => [ 'Bot-*', '*META.*'  ],
);

$build->create_build_script;

