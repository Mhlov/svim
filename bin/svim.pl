#!/usr/bin/perl
#===============================================================================
#  DESCRIPTION: Wrapper for a vim server
#
#         TODO: 
#
#       AUTHOR: ΜΗΛΟΝ
#      CREATED: 09-04-2020 12:15
#      LICENSE: Artistic License 1.0
#===============================================================================
use v5.10;
use strict;
use warnings;
use utf8;
use open qw/:std :utf8/;

use Fcntl qw/:flock/;
use Time::HiRes qw/ usleep /;

use DDP;

my $VERSION = '0.23';

my $vim_bin = '/usr/bin/vim';

my $lock_file = '/var/lock/svim.lock';

my $server;             # server name
my $run_in_term;        # flag 'run in a new terminal window'
my $ask;

# terminal emulator
my $term_bin = $ENV{TERMINAL} || '/usr/bin/x-terminal-emulator';

sub help {
    require Pod::Usage;
    Pod::Usage::pod2usage(-verbose => 99);
}

sub options {
    while (my $opt = shift) {
        if ($opt =~ /^\+[taA]+$/) {
            $run_in_term = 1    if $opt =~ /t/;
            $ask = 1            if $opt =~ /a/;
            $ask = 'auto'       if $opt =~ /A/;
        }
        elsif (not $ask) {
            $server = $opt;
            last;
        }
        else {
            unshift @_, $opt;
            last;
        }
    }

    return @_;
}

sub get_term_cmd {
    return $term_bin, '-name', "Vim_$server", '-e';
}

sub get_vim_cmd {
    return $vim_bin, '--servername', $server;
}

sub get_serverlist {
    my @list;
    open (my $h, '-|', "$vim_bin --serverlist");
    while (my $l = readline $h) {
        chomp $l;
        push @list, $l;
    }
    close $h;
    return \@list;
}

sub server_exists {
    my $serverlist = get_serverlist;
    while (my $s_name = shift @$serverlist) {
        if ($server eq $s_name) {
            return 1;
        }
    }
    return undef;
}

sub ask_server_name {
    my $name;
    my $serverlist = get_serverlist;
    if ($ask eq 'auto' and @$serverlist == 1) {
        $name = $serverlist->[0];
    }
    elsif (@$serverlist) {
        print "Type a number of a server and press return.\n";
        for my $i (0 .. $#{ $serverlist }) {
            printf "%d: %s\n", $i+1, $serverlist->[$i];
        }
        my $n = <STDIN>;

        exit unless defined $n;

        chomp $n;

        if ($n eq '') {
            # TODO: chose last or first?
            exit;
        }
        else {
            --$n;
            die "Out of a range\n"
                if $n < 0 or $n > $#{ $serverlist };
            $name = $serverlist->[$n];
        }
    }
    return $name;
}


sub main {
    help and return 0 unless @_;

    @_ = options(@_);

    $server = ask_server_name if $ask;

    die "Server name not specified.\n" unless $server;

    # Preventing race condition
    open my $fh, '>', $lock_file or die "$!";
    until( flock $fh, LOCK_EX|LOCK_NB ) {
        state $i++;
        return 1 if $i >= 10;
        usleep 200 * $i;
    }

    if (server_exists) {
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

B<svim.pl> [options] server_name [vim arguments]

B<svim.pl> +A|+a [vim arguments]

=head1 OPTIONS

=over 14

=item B<< +t >>

Run vim server in a new terminal window.

=item B<< +a >>

Select a server from a list.

=item B<< +A >>

Similar to B<<+a>> but if there is only one server, it will be selected.

=back

=head1 NOTES

You can determine which terminal emulator will be used by setting the
envirounment variable $TERMINAL. The default is '/usr/bin/x-terminal-emulator'.

=cut

