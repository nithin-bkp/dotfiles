if status is-interactive

    function kec -d "Create resources defined in given file"
      ke create -f $argv[1] -n vsmaps
    end

    function ked -d "Delete all resource in the given file"
      ke delete -f $argv[1] -n vsmaps
    end

    function pv -d "Manage pyenv virtualenv envs"
      if [ "$argv[1]" = "create" ]
        pyenv virtualenv 3.11.4 $argv[2]
      else if [ "$argv[1]" = "delete" ]
        pyenv virtualenv-delete $argv[2]
      else if [ "$argv[1]" = "list" ]
        pyenv virtualenvs
      else if [ "$argv[1]" = "act" ]
        pyenv activate $argv[2]
      else if [ "$argv[1]" = "dact" ]
        pyenv deactivate
      else
        echo invalid command $argv[1] not known
      end
    end

    # dotfile aliases
    alias fc='nvim ~/.config/fish/config.fish'
    alias alc='nvim ~/.config/alacritty/alacritty.toml'
    alias txn='tmux -u new -s'
    alias txa='tmux -u a -t'
    alias tls='tmux ls'
    alias nvc='cd ~/.config/nvim && nvim'
    alias tmc='nvim ~/.config/tmux/tmux.conf'
    alias i3c='nvim ~/.config/i3/config'
    alias sshc='nvim ~/.ssh/config'

    # Git Aliases
    alias gs='git status'
    alias grs='git restore --staged'
    alias gco='git checkout'
    alias gsl='git stash list'
    alias gsp='git stash pop'
    alias gwt='wp && cd code/worktrees'
    alias gwa='git worktree add'
    alias gwr='git worktree remove'
    alias gl='git log'
    alias gpu='git pull upstream'
    alias gpo='git push origin'
    alias gds='git diff --staged'
    alias gd='git diff'
    alias gcm='git commit -m'

    # workdir aliases
    alias cairo="cd ~/projects/wprojects/code/cairo"
    alias rosario="cd ~/projects/wprojects/code/rosario/notification/"
    alias wp="cd ~/projects/wprojects/"
    alias pp="cd ~/projects/pprojects"
    alias vsmaps="cd ~/projects/wprojects/vsmaps/"

    # Kubectl alias
    alias ke='kubectl'
    alias kegp='ke get pods -n vsmaps'
    alias kelv='ke exec -it cairo-cairo-0 bash -n vsmaps'
    alias keln='ke exec -it cairo-vunode-0 bash -n vsmaps'
end

pyenv init - | source
