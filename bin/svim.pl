#!/usr/bin/perl
#===============================================================================
#  DESCRIPTION: Wrapper for a vim server
#
#         TODO: 
#
#       AUTHOR: ΜΗΛΟΝ
#      CREATED: 09-04-2020 12:15
#===============================================================================
use Modern::Perl            '2018';
use strict;
use warnings;
use utf8;
use open qw/:std :utf8/;

use Fcntl qw/:flock/;
use Time::HiRes qw/ usleep /;

my $VERSION = '0.22';

my $vim_bin = '/usr/bin/vim';

my $lock_file = '/var/lock/svim.lock';

my $server;             # server name
my $run_in_term;        # flag 'run in new terminal'

# terminal emulator
my $term_bin = $ENV{TERMINAL} || '/usr/bin/x-terminal-emulator';

sub help {
    require Pod::Usage;
    Pod::Usage::pod2usage(-verbose => 99);
}

sub options {
    my $opt = shift;

    if ($opt eq '-t') {
        $run_in_term = 1;
    } else {
        $server = $opt;
    }

    $server = shift unless $server;

    return @_;
}

sub get_term_cmd {
    return $term_bin, '-name', "Vim_$server", '-e';
}

sub get_vim_cmd {
    return $vim_bin, '--servername', $server;
}

sub server_exists {
    open (my $h, '-|', "$vim_bin --serverlist");
    while (my $l = readline $h) {
        chomp $l;
        if ($server eq $l) {
            close $h;
            return 1;
        }
    }
    close $h;
    return undef;
}


sub main {
    help and return 0 unless @_;

    @_ = options(@_);

    die "Server name not specified.\n" unless $server;

    # Preventing race condition
    open my $fh, '>', $lock_file or die "$!";
    until( flock $fh, LOCK_EX|LOCK_NB ) {
        state $i++;
        return 1 if $i >= 10;
        usleep 200 * $i;
    }

    if (server_exists()) {
        # open in a running server
        exec get_vim_cmd(), '--remote-silent', @_;
    } else {
        # run a new server
        if ($run_in_term) {
            exec get_term_cmd(), get_vim_cmd(), @_;
        } else {
            exec get_vim_cmd(), @_;
        }
    }

    0;
}

exit main(@ARGV);

__END__
################################################################################

=head1 NAME

svim.pl - Wrapper for a vim server

=head1 SYNOPSIS

B<svim.pl> [options] [server name] [vim arguments]

=head1 OPTIONS

=over 14

=item B<< -t >>

Run vim server in a new terminal window.

=back

=head1 NOTES

You can determine which terminal emulator will be used by setting the
envirounment variable $TERMINAL. The default is '/usr/bin/x-terminal-emulator'.

=cut

