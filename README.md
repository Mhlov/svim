# svim

Wrapper for vim server

## Dependecies

* perl

```
sudo apt-get install perl
```

## Usage

```
svim.pl [options] server name [vim arguments]
svim.pl +A|+a [vim arguments]
```

### Options

* +t - Run vim server in a new terminal window
* +a - Select a server from a list
* +A - Similar to "+a", but if there is only one server, it will be selected.

### Examples

```
svim.pl FOO hello-world
```
Run FOO vim server and edit 'hello-world' file.

```
svim.pl +t BAR
```
Run BAR vim server in a new terminal window.

```
svim.pl BAR "+call cursor(34,1)" baz.md
```
Edit file `baz.md` in BAR vim server and position the cursor in the 34 line.

```
svim.pl +A qux.pl
```
Ask to select on which server (FOO or BAR) open 'qux.pl' file.

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

alias tsvi='tmux new-window svim.pl'
alias tvsvi='tmux split-window svim.pl'
alias thsvi='tmux split-window -h svim.pl'
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

