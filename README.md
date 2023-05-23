# svim

Wrapper for vim servers

## Dependencies

* perl

```
sudo apt-get install perl
```

## Usage

```
svim.pl [options] server name [vim arguments]
svim.pl +A|+a [vim arguments]
svim.pl
```

### Options

* +t - Run a vim server in a new terminal window.
* +T - Run a vim server in a new tmux window.
* +h - Split a tmux window horizontally and run a vim server.
* +v - Split a tmux window vertically and run a vim server.
* +a - Select a server from a list.
* +A - Similar to '+a' but if there is only one server then it will be
selected and if there are no servers, a server named 'A' is started.

### Environment

#### TERM_BIN, TERMINAL
You can determine which terminal emulator will be used by setting one of these
environment variables. The default is '/usr/bin/x-terminal-emulator'.

#### TMUX_BIN
You can point to where the tmux binary is located by setting this environment
variable. The default is '/usr/bin/tmux'.

### Examples

```
svim.pl FOO hello-world
```
Run the FOO vim server and edit 'hello-world' file on it.

```
svim.pl +t BAR
```
Run the BAR vim server in a new terminal window.

```
svim.pl BAR "+call cursor(34,1)" baz.md
```
Edit file `baz.md` on BAR vim server and position the cursor on line 34.

```
svim.pl +A qux.pl
```
Ask to select on which server (FOO or BAR) edit the file 'qux.pl'.

## zsh completion

```
mkdir -p ~/.zsh/functions
cp zsh-completion/_svim.pl ~/.zsh/functions/
```

## aliases in .zshrc

```
alias svils='vim --serverlist'
alias svimls='svils'

alias svi='svim.pl'
alias svim='svi'

alias wsvi='svim +t'
alias wsvim='wsvi'

alias savi='svim +A'
alias savim='savi'

alias tsvi='svim.pl +T'
alias tvsvi='svim.pl +v'
alias thsvi='svim.pl +h'
alias tsvim='tsvi'
alias tvsvim='tvsvi'
alias thsvim='thsvi'
```

# update-desktop-vi-server.pl

Handling desktop files for vim servers

![screenshot01](screen01.png)

## Usage

Add the following lines to your .vimrc:

```
if has("autocmd")
    autocmd VimEnter * silent execute "!update-desktop-vi-server.pl&" | redraw!
    autocmd VimLeave * !update-desktop-vi-server.pl 1
endif
```

