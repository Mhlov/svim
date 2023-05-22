#compdef svim.pl

_arguments \
    '1: :->first_arg'\
    '2: :->second_arg'\
    '*: := _path_files'

case $state in
    first_arg)
        local current
        current=$words[CURRENT]
        if [[ ${current} == "+" ]]; then
            _arguments \
                '+t[Run vim server in a new terminal window]' \
                '+T[Run a vim server in a new tmux window.]' \
                '+h[Split a tmux window horizontally and run a vim server.]' \
                '+v[Split a tmux window vertically and run a vim server.]' \
                '+a[Select a server from a list]' \
                '+A[Similar to <+a> but if there is only one server, it will be selected]'
        else
            _alternative \
                "servers:vim servers:($(vim --serverlist))"
        fi
    ;;
    second_arg)
        local prev
        prev=$words[CURRENT-1]
        if [[ $prev == "+t" || $prev == "+T" || $prev == "+h" || $prev == "+v" ]]
        then
            _alternative \
                "servers:vim servers:($(vim --serverlist))"
        else
            _path_files
        fi
    ;;
esac

