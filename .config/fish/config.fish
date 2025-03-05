if status is-interactive
  set EDITOR nvim 
  bind \ce edit_command_buffer
  function fish_vi_cursor --on-variable fish_bind_mode
    switch $fish_bind_mode
      case default
        echo -en "\e[2 q" # block cursor
      case insert
        echo -en "\e[6 q" # line cursor
      case visual
        echo -en "\e[2 q" # block cursor
    end
  end

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

  function remove_path
    if set -l index (contains -i "$argv" $fish_user_paths)
      set -e fish_user_paths[$index]
      echo "Removed $argv from the path"
    end
  end

  # dotfile aliases
  alias fsc='nvim ~/.config/fish/config.fish'
  alias alc='nvim ~/.config/alacritty/alacritty.toml'
  alias txn='tmux -u new -s'
  alias txa='tmux -u a -t'
  alias tls='tmux ls'
  alias nvc='cd ~/.config/nvim && nvim'
  alias tmc='nvim ~/.config/tmux/tmux.conf'
  alias i3c='nvim ~/.config/i3/config'
  alias sshc='nvim ~/.ssh/config'
  alias nvimk='NVIM_APPNAME="nvim-kickstart" nvim'

  # Git Aliases
  alias g='git'
  alias gb='git branch'
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
  alias f8c="flake8 --exclude pluto,lib,vu_auth_provider,venv,muscat --per-file-ignores="map/daq/daemon/daq_daemon.py:F821" --count  --show-source --statistics --max-line-length=90 --ignore=F401,F841,W503,W605,E501,F811,F405,E203,E266,E265,E402"
  alias f8d="flake8 . --count --ignore=E203,E722,W503 --statistics  --max-line-length=90  --exclude=common/airflow,pipeline/modules/operation_modules/period_detection_module.py"
  alias denver="cd ~/projects/wprojects/code/denver"
  alias rosario="cd ~/projects/wprojects/code/rosario/notification/"
  alias rooney="cd ~/projects/wprojects/code/rosario/rooney/"
  alias wp="cd ~/projects/wprojects/"
  alias tools="cd ~/projects/wprojects/tools/"
  alias pp="cd ~/projects/pprojects"
  alias vsmaps="cd ~/projects/wprojects/vsmaps/"

  # Kubectl alias
  alias ke='kubectl'
  alias kegp='ke get pods -n vsmaps'
  alias kelv='ke exec -it cairo-cairo-0 bash -n vsmaps'
  alias keln='ke exec -it cairo-vunode-0 bash -n vsmaps'
  alias keld='ke exec -it (kegp | grep denver | awk \'{print $1}\') bash -n vsmaps'
  alias kedl='ke logs -f (kegp | grep denver | awk \'{print $1}\') -n vsmaps'
  alias kelch='ke exec -it chi-clickhouse-vusmart-0-0-0 -n vsmaps -- bash'
  alias kelg='ke logs -f (kegp | grep nairobi | awk \'{print $1}\') -n vsmaps'
  alias cbkp='make clean && make build/linux/amd64/clickhouse-backup build/linux/arm64/clickhouse-backup && ke cp build/linux/amd64/clickhouse-backup chi-clickhouse-vusmart-0-0-0:/usr/local/bin/clickhouse-backup -n vsmaps'

  # Docker aliases
  alias dimg='docker images'
  alias dc='docker ps'
  alias dca='docker ps -a'
  alias drmi='docker rmi'
  alias drm='docker rm'

  alias full='xrandr --output HDMI-1 --auto --same-as eDP-1'
end

pyenv init - | source
