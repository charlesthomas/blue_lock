#!/usr/bin/perl
use strict;
use lib "/home/$ENV{USER}/git/charlesthomas/blue_lock/lib";
use BlueLock;

my $blo = BlueLock->new( {
	config => "/home/$ENV{USER}/git/charlesthomas/blue_lock/config/test",
	debug  => 5,
} );

$blo->lock();
exit;
