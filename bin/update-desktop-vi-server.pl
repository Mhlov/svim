#!/usr/bin/perl -w
#===============================================================================
#  DESCRIPTION: Handling desktop files for vim servers
#
#         TODO: 
#
#       AUTHOR: ΜΗΛΟΝ
#      CREATED: 01-11-2020 07:46
#      LICENSE: Artistic License 1.0
#===============================================================================

# USAGE
# Add the following lines to your .vimrc:
#
#   if has("autocmd")
#       autocmd VimEnter * silent! !update-desktop-vi-server.pl&
#       autocmd VimLeave * !update-desktop-vi-server.pl 1
#   endif

use v5.10;
use utf8;
use strict;
use autodie;
use warnings;

# Unicode
use warnings  qw/FATAL utf8/;
use open      qw/:std :utf8/;
use charnames qw/:full/;
use feature   qw/unicode_strings/;

#use Data::Printer;              # Usage: p @array;
                                # https://metacpan.org/pod/Data::Printer

use POSIX;

my $version = '0.1';

my $desktop_dir = "$ENV{HOME}/.local/share/applications";
my $f_prefix = 'svim-';

my @servers;


sub daemonize
{
    fork and exit;
    POSIX::setsid();
    fork and exit;
    umask 0;
    chdir '/';
    close STDIN;
    close STDOUT;
    close STDERR;
}


sub create_file {
    my $file = shift;
    my $server = shift;

    open my $fh, '>', $file or die $!;

    print $fh <<"__F_END__";
[Desktop Entry]
Type=Application
Name=Vim server $server
GenericName=Text Editor
Comment=Edit text files on vim server $server
Exec=svim.pl $server %f
Terminal=false
Categories=Utility;TextEditor;
Keywords=Text;editor;
NoDisplay=false
MimeType=text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;
Icon=gvim
__F_END__

    close $fh;
}


sub update_servers {
    @servers = () if @servers;
    open (my $h, '-|', 'vim --serverlist');
    while (my $l = readline $h) {
        chomp $l;
        push @servers, $l;
    }
    close $h;
}


sub update_files {
    my $update;
    my $f_prefix_length = length $f_prefix;
    opendir (my $dh, $desktop_dir);

    # remove files with a nonexistent server
    while ( my $file = readdir($dh) ) {
        next unless '.desktop' eq substr $file, -8;
        next unless $f_prefix eq substr $file, 0, $f_prefix_length;
        my($f_server) = $file =~ /^${f_prefix}(.+)\.desktop$/;

        unless ( scalar grep { $_ eq $f_server } @servers ) {
            unlink "$desktop_dir/$file" or die $!;
            $update = 1;
        }
    }

    closedir $dh;

    # make new files
    foreach my $server ( @servers ) {
        my $file = "$desktop_dir/${f_prefix}${server}.desktop";
        if ( not -e $file ) {
            create_file($file, $server);
            $update = 1;
        }
    }

    #update desktop database
    system 'update-desktop-database', $desktop_dir if $update;
}


sub main {
    daemonize();
    my $time = shift;
    sleep $time if $time;

    update_servers;
    update_files;
    0;
}

exit main(@ARGV);

