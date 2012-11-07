#!/bin/bash

#perl requirements
#using apt-get because cpan died with an unknown error
apt-get install -y libnet-bluetooth-perl
cpan -i Tie::File::AsHash Proc::Daemon;

#create log dir
mkdir -p /var/log/blue_lock/

#bin
cp -vi bin/blue_lock.pl /usr/bin/
cp -vi bin/screenlock.sh /usr/bin/

#config
cp -vi config/install_config /etc/blue_lock.conf

#lib
cp -vi lib/BlueLock.pm /usr/lib/perl5/

#init.d
cp -vi init.d/blue_lock /etc/init.d
update-rc.d blue_lock defaults
