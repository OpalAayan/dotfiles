# Enable Powerlevel10k instant prompt (should stay close to the top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh base setup
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment and edit PATH if needed
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Plugins (add wisely, too many slow down startup)
plugins=(git zsh-autosuggestions)

# IMPORTANT: Set the base system PATH before sourcing Oh My Zsh
export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin"

source $ZSH/oh-my-zsh.sh

# Load fzf if installed
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Load fzf key bindings and fuzzy completion
source <(fzf --zsh)

# --- Java Default Setup (Java 24) ---
export JAVA_HOME=/usr/lib/jvm/java-24-openjdk  
export PATH="$JAVA_HOME/bin:$PATH"

# --- Optional JavaFX SDK ---
export JAVAFX_HOME=~/Downloads/javafx-sdk-24/lib  
export CLASSPATH=$CLASSPATH:$JAVAFX_HOME

# --- Optional: Switch to Java 17 for tools like BlueJ ---
# Uncomment below when running BlueJ manually
# export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
# export PATH=$JAVA_HOME/bin:$PATH

# Add user bin folders (safe & common)
export PATH="$HOME/.npm-global/bin:$PATH"

# Powerlevel10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

# Random Pokémon color script on shell startup
#pokemon-colorscripts --random

# Other user configurations
# Set your preferred editor
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Add your custom aliases in $ZSH_CUSTOM/*.zsh (e.g. aliases.zsh)

# Optional Nix environment setup
# if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
#   . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
# fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#For bluetooth headphones
alias bt-battery="bluetoothctl info E3:5F:23:22:BF:DD | grep 'Battery Percentage'"

#Os age
OsAge() {
    local pacman_log="/var/log/pacman.log"
    
    # Check if the log file exists and is readable
    if [[ ! -r "$pacman_log" ]]; then
        echo "  OS age: Unknown (cannot read $pacman_log)"
        return 1
    fi

    # Get the first install date from pacman log
    # The 'head -n 1' makes it extra safe for awk
    local raw_date
    raw_date=$(head -n 1 "$pacman_log" | awk -F '[[]|[]]' '{print $2}')

    # Check if a date was actually extracted
    if [[ -z "$raw_date" ]]; then
        echo "  OS age: Unknown (no date found in $pacman_log)"
        return 1
    fi

    # Convert to epoch for age calculation
    local install_epoch
    install_epoch=$(date -d "$raw_date" +%s)
    local now_epoch
    now_epoch=$(date +%s)
    local age_days
    age_days=$(( (now_epoch - install_epoch) / 86400 ))

    # Format date: "Jan 18, 2025 at 08:13 PM"
    local formatted_date
    formatted_date=$(date -d "$raw_date" +"%b %d, %Y at %I:%M %p")

    # Output
    echo "  OS age: $age_days days (since $formatted_date)"
}

#For typy (A minimal monkey type)
export PATH="$HOME/.cargo/bin:$PATH"

#For Vs code
alias code='code 2>/dev/null'