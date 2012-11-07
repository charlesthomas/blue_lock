#!/usr/bin/perl
package BlueLock;
use strict;

use Net::Bluetooth;
use Tie::File::AsHash;

use autouse 'Data::Dumper' => 'Dumper';

use constant LOCKBIN   => '/usr/bin/screenlock.sh';
use constant TIMEOUT   => 15; #seconds
use constant FAILLIMIT => 1;
use constant LOGFILE   => '/var/log/blue_lock/blue_lock.log';
use constant CONFIG    => '/etc/blue_lock.conf';
use constant PIDFILE   => '/var/run/blue_lock.pid';

sub new {
	my( $class, $args ) = @_;

	$args->{config} = CONFIG unless $args->{config};

	my $self = {};

	tie my %config, 'Tie::File::AsHash', $args->{config}, split => '='
		|| die "failed: open config $args->{config}\n";

	foreach my $key ( keys %config ) {
		$self->{$key} = $config{$key};
	}

	untie %config;

	die "mac_address required in config file\n" unless $self->{mac_address};
	die "username required in config file\n" unless $self->{username};

	#force defaults
	$self->{logfile}   = LOGFILE   unless $self->{logfile};
	$self->{timeout}   = TIMEOUT   unless $self->{timeout};
	$self->{faillimit} = FAILLIMIT unless $self->{faillimit};
	$self->{lockbin}   = LOCKBIN   unless $self->{lockbin};
	$self->{pidfile}   = PIDFILE   unless $self->{pidfile};

	bless( $self, $class );

	if( $self->{verbosity} >= 2 ) {
		my @log;
		foreach( keys %$self ) {
			push( @log, "$_: $self->{$_}" );
		}
		$self->log( { section => "CONFIG", array => \@log } );
	}

	return $self;
}

sub find_device {
	my( $self, $mac ) = @_;

	my $devices = get_remote_devices();

	foreach( keys %$devices ) {
		if( $mac eq $_ ) {
			return 1;
		}
	}
	return 0;
}

sub lock {
	my( $self ) = @_;

	$self->log( { string => 'locking' } );

	system( $self->{lockbin}, $self->{username}, 'lock' );
	return;
}

sub unlock {
	my( $self ) = @_;

	$self->log( { string => 'unlocking' } );

	system( $self->{lockbin}, $self->{username}, 'unlock' );
	return;
}

sub log {
	my( $self, $args ) = @_;

	return unless $self->{verbosity} >= 1 || $args->{err};

	open( my $log, '>>', $self->{logfile} )
		|| die "failed: open log $self->{logfile}\n";

	my $ts = localtime( time );

	print $log "$ts - ===== BEGIN $self->{section} =====\n"
		if $args->{section};

	if( $args->{string} ) {
		print $log "$ts - ";
		print $log "ERROR " if $args->{err};
		print $log "$args->{string}\n";
	}

	foreach( @{$args->{array}} ) {
		print $log "$ts - ";
		print $log "ERROR " if $args->{err};
		print $log "$_\n";
	}

	print $log "$ts - ===== END $self->{section} =====\n"
		if $args->{section};

	close( $log );
	return;
}

return 1;
