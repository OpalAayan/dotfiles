# ==============================================================================
# POWERLEVEL10K INSTANT PROMPT
# (Must stay at the very top of ~/.zshrc)
# ==============================================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ==============================================================================
# OH MY ZSH SETUP
# ==============================================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins (keep this list minimal for speed)
plugins=(git zsh-autosuggestions)

# Set system PATH before sourcing OMZ
export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin"

source $ZSH/oh-my-zsh.sh

# ==============================================================================
# FZF INTEGRATION
# ==============================================================================
# Check if fzf is installed, then load bindings and completion
if (( $+commands[fzf] )); then
  source <(fzf --zsh)
fi

# ==============================================================================
# JAVA SETUP (Java 24)
# ==============================================================================
export JAVA_HOME=/usr/lib/jvm/java-24-openjdk  
export PATH="$JAVA_HOME/bin:$PATH"

# JavaFX SDK
export JAVAFX_HOME="$HOME/.local/lib/javafx-sdk-24.0.1/lib"
export CLASSPATH=$CLASSPATH:$JAVAFX_HOME

# Optional: Switch to Java 17 (Uncomment when needed)
# export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
# export PATH=$JAVA_HOME/bin:$PATH

# ==============================================================================
# PATH CONFIGURATION
# ==============================================================================
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# ==============================================================================
# POWERLEVEL10K CONFIG
# ==============================================================================
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ==============================================================================
# NVM (NODE VERSION MANAGER) - LAZY LOAD
# ==============================================================================
# This loads NVM only when you type 'node', 'npm', or 'nvm' to save startup time.
export NVM_DIR="$HOME/.nvm"
function nvm node npm {
  unfunction nvm node npm
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
  "$0" "$@"
}

# ==============================================================================
# ALIASES
# ==============================================================================
alias code='code 2>/dev/null'                            # VS Code silence
alias bluej="~/.local/lib/bluej/bluej"                   # Manual BlueJ
alias rmpc="~/.config/hypr/scripts/rmpc_music.sh"        # RMPC Music
alias cmus='(cd ~/Music && command cmus)'                # CMUS music dir
alias bt-battery="bluetoothctl info E3:5F:23:22:BF:DD | grep 'Battery Percentage'"
alias flappy='(cd "/home/aayanopal/Documents/JAVA CODES/1Real devCooking/FlappyBirdxd" && javac FlappyApp.java && java FlappyApp &> /dev/null) && echo "fuck you" | lolcat'


# ==============================================================================
# FUNCTIONS
# ==============================================================================
OsAge() {
    local pacman_log="/var/log/pacman.log"
    
    if [[ ! -r "$pacman_log" ]]; then
        echo "  OS age: Unknown (cannot read $pacman_log)"
        return 1
    fi

    local raw_date
    raw_date=$(head -n 1 "$pacman_log" | awk -F '[[]|[]]' '{print $2}')

    if [[ -z "$raw_date" ]]; then
        echo "  OS age: Unknown (no date found)"
        return 1
    fi

    local install_epoch
    install_epoch=$(date -d "$raw_date" +%s)
    local now_epoch
    now_epoch=$(date +%s)
    local age_days
    age_days=$(( (now_epoch - install_epoch) / 86400 ))

    local formatted_date
    formatted_date=$(date -d "$raw_date" +"%b %d, %Y at %I:%M %p")

    echo "  OS age: $age_days days (since $formatted_date)"
}

# ==============================================================================
# MAGIC ENTER (ALT + ENTER for New Line)
# ==============================================================================
function magic-enter {
  if [[ -n $BUFFER ]]; then
    LBUFFER+=$'\n'
  else
    zle accept-line
  fi
}
zle -N magic-enter
bindkey '^[^M' magic-enter
bindkey '^[^J' magic-enter

# Hide secondary prompt for cleaner multiline look
PROMPT2=' '

# ==============================================================================
# GPU COMPATIBILITY FIXES
# ==============================================================================
# Gaslight Ghostty into thinking we have OpenGL 4.6 (Fixes Intel HD 4000 crash)
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLSL_VERSION_OVERRIDE=460

# ==============================================================================
# NIX SUPPORT
# ==============================================================================
if [ -e /etc/profile.d/nix.sh ]; then
  source /etc/profile.d/nix.sh
fi


export PATH="$HOME/.nix-profile/bin:$PATH"
