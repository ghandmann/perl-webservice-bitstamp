#!/usr/bin/env perl

use Mojo::Base -strict;
use lib './lib/';
use WebService::Bitstamp;

my $bs = WebService::Bitstamp->new();
$bs->connect();

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
