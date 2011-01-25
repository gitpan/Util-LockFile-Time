=head1 NAME

Util::LockFile::Time - timed lock with an advisory file

=cut
package Util::LockFile::Time;

=head1 VERSION

This documentation describes version 0.01

=cut
use version;      our $VERSION = qv( 0.01 );

use warnings;
use strict;
use Carp;

use File::Temp;
use File::Copy;

use constant { DURATION => 3600 * 12 };

=head1 SYNOPSIS

 use Util::LockFile::Time;
 
 my $lock = '/lock/file/path';

 Util::LockFile::Time->lock( $lock, epoch => 3600, duration => 1200 );

 die "locked\n" if my $seconds = Util::LockFile::Time->check( $lock );

=head1 DESCRIPTION

=head2 lock( file, epoch => start, duration => seconds )

Writes time into the file.

=cut
sub lock
{
    my ( $class, $file, %param ) = @_;

    croak 'lock file not defined' unless defined $file;

    for my $key ( keys %param )
    {
        next unless my $param = $param{$key};
        croak "invalid time $key" if ref $param || $param !~ /^\d+$/;
    }

    my ( $handle, $temp ) = File::Temp::tempfile();
    my $epoch = ( $param{epoch} || 0 ) + time;
    my $end = ( $param{duration} || DURATION ) + $epoch;

    print $handle "$epoch:$end"; 
    close $handle;

    File::Copy::move( $temp, $file );
}

=head2 check( file )

Returns I<true> if time lock is active. Returns I<false> otherwise.

=cut
sub check
{
    my ( $class, $file ) = @_;

    croak 'lock file not defined' unless defined $file;

    my ( $handle, $buffer );
    my $time = time;

    return open( $handle, '<', $file ) && read( $handle, $buffer, 1024 )
        && $buffer =~ /^(\d+):(\d+)$/ && $time >= $1 && $time < $2
            ? $2 - $time : 0;
}

=head1 AUTHOR

Kan Liu

=head1 COPYRIGHT and LICENSE

Copyright (c) 2010. Kan Liu

This program is free software; you may redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

__END__
