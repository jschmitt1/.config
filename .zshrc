# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/xga718/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

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

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
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
plugins=(git aws)

source $ZSH/oh-my-zsh.sh


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# User configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
alias gs="git status"
alias gd="git diff -v -v"
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# alias feature-dev='git checkout dev && git pull origin dev && git branch -D feature/dev && git checkout -b feature/dev && git push -f origin feature/dev'

function lg() {
    git add .
    git commit -a -m "$*"
    git push -u origin HEAD
}

kp() {
  lsof -t -i:"$*" | xargs kill -9
}

function feature-dev() {
        git checkout dev
        git pull origin dev
        git branch -D feature/dev;
        git checkout -b feature/dev
        perl -MYAML=LoadFile,DumpFile -we "\$y = LoadFile(\"Bogiefile\"); \$y->{pipeline}{tasks}{deploy}{\"dev-aws-lambda\"}{skip} = \"true\"; \$y->{pipeline}{feature_toggles}{always_deploy_to_qa} = \"true\"; DumpFile(\"Bogiefile\", \$y);"
        git commit -am 'allow qa deploy'
        git push -f origin feature/dev
        git checkout dev
}

function get-wft() {
    profile=GR_GG_COF_AWS_500721141842_Developer
    wft_key="x-workforce-authorization-info"
    lambda='llds-provisionLambda'
    region_two='us-east-1'
    region_one='us-west-2'
    wait=5
    attempts=5

    region_query() { echo $(aws logs start-query --log-group-name "/aws/lambda/$lambda" --start-time $(date -v -10M +"%s") --end-time $(date +"%s") --query-string "fields @wft | parse @message \"'$wft_key': '*'\" as @wft | parse @message \"'oauth_resourceowneruid': '*'\" as @user | filter @message like /$wft_key/ and @user like /(?i)$USER/ | sort @timestamp desc | limit 1" --region $1 --profile $profile --query "queryId" --output text); }
    region_results() { echo $(aws logs get-query-results --query-id  $2 --region $1 --profile $profile --query "results[0][?field=='@wft'].value" --output text);}

    n=0
    token='None'
    east_id=$(region_query $region_one)
    while [ "$n" -lt $attempts ] && [ $token = "None" ]; do
        n=$(( n + 1 ))
        echo "Querying in $region_one #$n..."
        token=$(region_results $region_one $east_id)
        [ "$token" = "None" ] || break

        echo "Querying in $region_two #$n..."
        [ -z "$west_id" ] && west_id=$(region_query $region_two)
        token=$(region_results $region_two $west_id)
        [ "$token" = "None" ] || break
        echo "Waiting $wait secs..." & sleep $wait
    done

    if [ "$token" = "None" ]; then
      echo "Not found. Please try again !"
    else
      echo $token | pbcopy
      echo "Worksforce copied to the clipboard !"
    fi
}

export EDITOR='nvim'
export VISUAL="$EDITOR"
n ()
{
    # Block nesting of nnn in subshells
    [ "${NNNLVL:-0}" -eq 0 ] || {
        echo "nnn is already running"
        return
    }

    # The behaviour is set to cd on quit (nnn checks if NNN_TMPFILE is set)
    # If NNN_TMPFILE is set to a custom path, it must be exported for nnn to
    # see. To cd on quit only on ^G, remove the "export" and make sure not to
    # use a custom path, i.e. set NNN_TMPFILE *exactly* as follows:
    #      NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

    # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
    # stty start undef
    # stty stop undef
    # stty lwrap undef
    # stty lnext undef
    #-----
    export NNN_OPENER=~/.config/nnn/plugins/nuke
    export NNN_OPTS="H" # 'H' shows the hidden files. Same as option -H (so 'nnn -deH')
    # export NNN_OPTS="deH" # if you prefer to have all the options at the same place
    export LC_COLLATE="C" # hidden files on top
    export NNN_FIFO="/tmp/nnn.fifo" # temporary buffer for the previews
    export NNN_FCOLORS="AAAAE631BBBBCCCCDDDD9999" # feel free to change the colors
    export NNN_PLUG='p:preview-tui;v:imgview' # many other plugins are available here: https://github.com/jarun/nnn/tree/master/plugins
    export TERMINAL="which tmux"
    #-----
    #
    # The command builtin allows one to alias nnn to n, if desired, without
    # making an infinitely recursive alias
    command nnn -ec

    [ ! -f "$NNN_TMPFILE" ] || {
        . "$NNN_TMPFILE"
        rm -f "$NNN_TMPFILE" > /dev/null
    }
}
# Startup

cofproxy dev

# Add Visual Studio Code (code)
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Startup

cofproxy dev

# added to fix issue with brackets in command
unsetopt nomatch
# Add Visual Studio Code (code)
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
export PATH="$(pyenv root)/shims:$PATH"
export PATH="/usr/local/opt/postgresql@12/bin:$PATH"
export JAVA_HOME="/Library/Java/JavaVirtualMachines/amazon-corretto-8.jdk/Contents/Home"
export QT_ROOT=/usr/local/opt/qt@5
export INSTALLATION_ROOT=/Applications/pgmodeler.app
export PGSQL_ROOT=/usr/local/opt/postgres
export OPENSSL_ROOT=/usr/local/opt/openssl
export DATABASE_USER=postgres
export DATABASE_PASS=postgres
export DOCKER_HOST="unix://$HOME/.colima/docker.sock"

# Created by `pipx` on 2022-07-29 20:26:27
export PATH="$PATH:/Users/xga718/.local/bin"

autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
complete -C '/usr/local/bin/aws_completer' aws
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
