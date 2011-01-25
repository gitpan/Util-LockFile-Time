#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Util::LockFile::Time' );
}

diag( "Testing Util::LockFile::Time $Util::LockFile::Time::VERSION, Perl $], $^X" );
