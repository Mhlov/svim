#!/usr/bin/perl
#===============================================================================
#  DESCRIPTION: Wrapper for vim servers
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

#use DDP;

my $VERSION = '0.24';

my $vim_bin = '/usr/bin/vim';

my $lock_file = '/var/lock/svim.lock';

my $server;             # server name
my $run_in_term;        # flag 'run in a new terminal window'
my $ask;
my $run_in_tmux;

# terminal emulator
my $term_bin =
    $ENV{TERM_BIN} || $ENV{TERMINAL} || '/usr/bin/x-terminal-emulator';

my $tmux_bin = $ENV{TMUX_BIN} || '/usr/bin/tmux';

sub help {
    require Pod::Usage;
    Pod::Usage::pod2usage(-verbose => 99, -exitval => 'NOEXIT');
}

sub options {
    while (my $opt = shift) {
        if ($opt =~ /^\+[tTvhaA]+$/) {
            $run_in_term = 1    if $opt =~ /t/;
            $run_in_tmux = 'w'  if $opt =~ /T/;
            $run_in_tmux = 'h'  if $opt =~ /h/;
            $run_in_tmux = 'v'  if $opt =~ /v/;
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

sub get_tmux_cmd {
    if ($run_in_tmux eq 'h') {
        return $tmux_bin, 'split-window', '-h';
    }
    elsif ($run_in_tmux eq 'v') {
        return $tmux_bin, 'split-window';
    } else {
        return $tmux_bin, 'new-window';
    }
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
    elsif ($ask eq 'auto' and @$serverlist == 0) {
        $name = 'A';
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
        }
        elsif ($run_in_tmux) {
            exec get_tmux_cmd(), get_vim_cmd(), @_;
        }
        else {
            exec get_vim_cmd(), @_;
        }
    }

    0;
}

exit main(@ARGV);

__END__
################################################################################

=head1 NAME

svim.pl - Wrapper for vim servers

=head1 SYNOPSIS

B<svim.pl> [options] server_name [vim arguments]

B<svim.pl> +A|+a [vim arguments]

B<svim.pl>

=head1 OPTIONS

=over 6

=item B<< +t >>

Run a vim server in a new terminal window.

=item B<< +T >>

Run a vim server in a new tmux window.

=item B<< +h >>

Split a tmux window horizontally and run a vim server.

=item B<< +v >>

Split a tmux window vertically and run a vim server.

=item B<< +a >>

Select a server from a list.

=item B<< +A >>

Similar to B<<+a>> but if there is only one server then it will be selected
and if there are no servers, a server named <A> is started.

=back

=head1 ENVIRONMENT

=over 6

=item TERM_BIN, TERMINAL

You can determine which terminal emulator will be used by setting one of these
environment variables. The default is '/usr/bin/x-terminal-emulator'.

=item TMUX_BIN

You can point to where the tmux binary is located by setting this environment
variable. The default is '/usr/bin/tmux'.

=back

=cut

