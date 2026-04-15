# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
  fasd
)

source $ZSH/oh-my-zsh.sh

# Reset xterm "modifyOtherKeys" to classic mode.
# tmux default-terminal "tmux-256color" (+ iTerm2) otherwise emits
# Ctrl-<letter> as CSI 27;5;<code>~ which zsh does not decode by default,
# producing garbled output like ';5;119~' after `source ~/.zshrc`.
if [[ -t 1 ]]; then
  printf '\e[>4;0m'
fi

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Setup Neovim
export EDITOR=/usr/local/bin/nvim

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Setup homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Setup starship
eval "$(starship init zsh)"

# Setup Fuzzy Finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Setup alias
alias vim="nvim"
alias vi="nvim"
alias vimdiff="nvim -d"
alias cat="bat" # Replace cat to bat
alias top="ytop"
alias du="dust"
alias time="hyperfine"

# Custom function
function ccd { mkdir -p "$1" && cd "$1" }

# ---------------------------------------------------------------------
# Per-machine project paths, AWS profiles, terraform/kubectl aliases
# live in ~/.zshrc.local (see ## Secrets in README.md). Sourced below.
# ---------------------------------------------------------------------

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/johan/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/johan/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/johan/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/johan/google-cloud-sdk/completion.zsh.inc'; fi

# Setup custom binary path
export PATH="$HOME/.local/bin:$PATH"

# Setup direnv
eval "$(direnv hook zsh)"

# Setup kubectl editor
export KUBE_EDITOR='code --wait'

# Setup alias for grep
alias grep="ggrep --color=auto"
#-----------------------------------------------
# install fd
#-----------------------------------------------
# https://github.com/sharkdp/fd/releases
# wget --no-check-certificate -O fd_pkg.deb <url>
# sudo dpkg -i fd_pkg.deb && rm -f fd_pkg.deb
#
#-----------------------------------------------
# install fzf
#-----------------------------------------------
# git clone --depth 1 https://github.com/junegunn/fzf.git ~/.zsh/.fzf
# ~/.zsh/.fzf/install
# ---------
if [ "$(command -v fzf)" = "" ]; then
    if [ -d $HOME/.zsh/.fzf/ ]; then
        # if [[ ! "$PATH" == *${HOME}/.zsh/.fzf/bin* ]]; then fi
        if ! grep -q "$HOME/.zsh/.fzf/bin" <<< "$PATH"; then
            export PATH="$HOME/.zsh/.fzf/bin:$PATH"
        fi
    fi
fi
if [ -n "$(command -v fzf)" ]; then
    # export FZF_DEFAULT_OPTS='--color=bg+:#293739,bg:#1B1D1E,border:#808080,spinner:#E6DB74,hl:#7E8E91,fg:#F8F8F2,header:#7E8E91,info:#A6E22E,pointer:#A6E22E,marker:#F92672,fg+:#F8F8F2,prompt:#F92672,hl+:#F92672'
    export FZF_DEFAULT_OPTS='--color=bg+:#293739,bg:#1B1D1E,border:#808080,spinner:#E6DB74,hl:#F92672,fg:#F8F8F2,header:#7E8E91,info:#A6E22E,pointer:#A6E22E,marker:#F92672,fg+:#F8F8F2,prompt:#F92672,hl+:#F92672'
    # Auto-completion
    # ---------------
    if [ -d $HOME/.zsh/.fzf/ ]; then
        [[ $- == *i* ]] && source "$HOME/.zsh/.fzf/shell/completion.zsh" 2> /dev/null
        # Key bindings
        source "$HOME/.zsh/.fzf/shell/key-bindings.zsh"
    elif [ -d /opt/homebrew/ ]; then
        WHICH_CMD=$(/bin/bash -c "which which")
        fzf_bin_path=$($WHICH_CMD "fzf")
        fzf_sympath=$(greadlink -f $fzf_bin_path)
        fzf_realpath=$(dirname $(dirname $fzf_sympath))

        [[ $- == *i* ]] && source "$fzf_realpath/shell/completion.zsh" 2> /dev/null
        # Key bindings
        source "$fzf_realpath/shell/key-bindings.zsh"
    fi

    # fzf file search command
    # -----------------------
    if [ "$(command -v fd)" != "" ]; then
        # export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --no-ignore'

        # ignore binary file
        export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --no-ignore -X grep -lI .'
        # .git 디렉토리를 제외하고 검색
        # export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --no-ignore --exclude .git'
        # export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --no-ignore --color=always --exclude .git'

    else
        # export FZF_DEFAULT_COMMAND=''
        # export FZF_DEFAULT_COMMAND='find . -type f'
        # ignore binary file
        export FZF_DEFAULT_COMMAND='find . -type f -exec grep -lI . {} \;'
    fi
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

fpath+=~/.zfunc; autoload -Uz compinit; compinit

alias uvenv="source .venv/bin/activate"


# ---------------------------------------------------------------------
# Modular dotfiles (managed by GNU Stow from ~/repo/dotfiles)
#   ~/.zshrc.d/*        : versioned helpers (git, docker, k8s, go, ...)
#   ~/.aliases          : versioned shared aliases
#   ~/.zshrc.local      : per-machine override (NOT in dotfiles repo)
#   ~/.zshrc.local.d/*  : per-machine override snippets (NOT in repo)
#   ~/.aliases.local    : per-machine aliases override (NOT in repo)
# ---------------------------------------------------------------------
if [[ -d ~/.zshrc.d ]]; then
	for f in ~/.zshrc.d/*(N); do
		source "$f"
	done
fi
[ -f ~/.aliases ] && source ~/.aliases
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
if [[ -d ~/.zshrc.local.d ]]; then
	for f in ~/.zshrc.local.d/*(N); do
		source "$f"
	done
fi
[ -f ~/.aliases.local ] && source ~/.aliases.local


# Task Master aliases added on 8/22/2025
alias tm='task-master'
alias taskmaster='task-master'

# bun completions
[ -s "/Users/johan/.bun/_bun" ] && source "/Users/johan/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

alias claude-mem='bun "/Users/johan/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'
