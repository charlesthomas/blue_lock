#!/usr/bin/perl
use strict;
use Proc::Daemon;
use Getopt::Long;
use BlueLock;

my ( $config, $debug, $testing );

my $args = GetOptions(
	'config=s' => \$config,
	'debug=i'  => \$debug,
	'testing'  => \$testing,
);

my $blo = BlueLock->new( {
	config => $config,
} );

Proc::Daemon::Init( {
	pid_file => $blo->{pidfile},
} ) unless $testing;

#this assumes your screen is unlocked on start
#the lock/unlock script also confirms,
#so there should be no danger in this assumption
my $state = 'unlocked';
my $run   = 1;
my $fails = 0;

$SIG{USR1} = \&reinit;
$SIG{INT}  = sub{ $run = 0; } if $testing;
$SIG{TERM} = sub{ $run = 0; };

while ( $run ) {

	$blo->log( { string => 'scanning...' } ) if $blo->{verbosity} >= 3;

	if( $blo->find_device( $blo->{mac_address} ) ) {
		$blo->log( { string => 'found' } ) if $blo->{verbosity} >= 3;

		$fails = 0;

		if( $state eq 'locked' ) {
			$blo->unlock();
			$state = 'unlocked';
		}
	} else {
		$blo->log( { string => 'not found' } ) if $blo->{verbosity} >= 3;

		$fails++;

		if( $state eq 'unlocked' && $fails >= $blo->{faillimit} ) {
			$blo->log( { string => 'fail limit reached. locking' } );
			$blo->lock();
			$state = 'locked';
		}
	}

	sleep $blo->{timeout};
}
$blo->log( { string => 'exiting' } );
exit;

sub _reinit {
	undef $blo;
	$blo = BlueLock->new( { config => $config, debug => $debug } );
	return;
}
