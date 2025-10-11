#!/usr/bin/env bash
# =============================================================================
# Hyprland Keybinding Cheatsheet Generator - Enhanced Edition
# =============================================================================
# This script dynamically parses your hyprland.conf to extract keybindings
# and pairs them with human-readable descriptions from a TSV file.
# Features category headers, improved formatting, and visual polish.
# The result is displayed in a searchable fuzzel interface.
# =============================================================================

# Configuration paths
HYPRLAND_CONFIG="${HOME}/.config/hypr/hyprland.conf"
DESCRIPTIONS_FILE="${HOME}/.config/hypr/keybind_descriptions.tsv"

# ANSI color codes for header styling
COLOR_HEADER=""  
COLOR_SEPARATOR=""
COLOR_RESET=""

# Check if required files exist
if [[ ! -f "$HYPRLAND_CONFIG" ]]; then
    echo "Error: Hyprland config not found at $HYPRLAND_CONFIG" >&2
    exit 1
fi

if [[ ! -f "$DESCRIPTIONS_FILE" ]]; then
    echo "Warning: Descriptions file not found at $DESCRIPTIONS_FILE" >&2
    echo "Creating template file..." >&2
    # We'll continue without it and use raw commands as fallback
fi

# =============================================================================
# Step 1: Load descriptions into associative array
# =============================================================================
declare -A descriptions

if [[ -f "$DESCRIPTIONS_FILE" ]]; then
    while IFS=$'\t' read -r cmd desc; do
        # Skip empty lines and comments (lines starting with #)
        [[ -z "$cmd" || "$cmd" =~ ^# ]] && continue
        descriptions["$cmd"]="$desc"
    done < "$DESCRIPTIONS_FILE"
fi

# =============================================================================
# Step 2: Parse variables from hyprland.conf
# =============================================================================
declare -A variables

# Extract variable definitions (format: $varname = value)
while IFS= read -r line; do
    if [[ "$line" =~ ^\$([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*=[[:space:]]*(.+) ]]; then
        var_name="${BASH_REMATCH[1]}"
        var_value="${BASH_REMATCH[2]}"
        # Trim whitespace
        var_value="${var_value#"${var_value%%[![:space:]]*}"}"
        var_value="${var_value%"${var_value##*[![:space:]]}"}"
        variables["$var_name"]="$var_value"
    fi
done < "$HYPRLAND_CONFIG"

# =============================================================================
# Step 3: Parse keybindings from hyprland.conf with category support
# =============================================================================
declare -a keybindings_with_categories
current_category=""

# Function to clean and format key combinations with proper spacing
format_keys() {
    local keys="$1"
    
    # Replace variables (e.g., $mainMod -> SUPER)
    for var in "${!variables[@]}"; do
        keys="${keys//\$$var/${variables[$var]}}"
    done
    
    # Replace mainMod without $ (some configs use it directly)
    keys="${keys//mainMod/SUPER}"
    
    # Clean up modifiers - make them uppercase and consistent
    keys="${keys//SUPER_/SUPER + }"
    keys="${keys//Super/SUPER}"
    keys="${keys//CTRL/CTRL}"
    keys="${keys//ALT/ALT}"
    keys="${keys//SHIFT/SHIFT}"
    
    # Handle spaces in keys properly
    keys="${keys// /_SPACE_}" # Temporarily mark spaces
    
    # Clean up the final key combination
    if [[ "$keys" =~ ([^,]+),(.+) ]]; then
        modifiers="${BASH_REMATCH[1]}"
        key="${BASH_REMATCH[2]}"
        
        # Clean whitespace from both parts
        modifiers="${modifiers#"${modifiers%%[![:space:]]*}"}"
        modifiers="${modifiers%"${modifiers##*[![:space:]]}"}"
        key="${key#"${key%%[![:space:]]*}"}"
        key="${key%"${key##*[![:space:]]}"}"
        
        # Restore spaces in key names
        key="${key//_SPACE_/ }"
        modifiers="${modifiers//_SPACE_/ }"
        
        # Format with proper plus signs
        if [[ -n "$modifiers" && "$modifiers" != "" ]]; then
            # Ensure consistent spacing around plus signs
            formatted="${modifiers} + ${key}"
            # Clean up multiple spaces and ensure single space around +
            formatted=$(echo "$formatted" | sed 's/  */ /g' | sed 's/ *+ */\ + /g')
            echo "$formatted"
        else
            echo "${key//_SPACE_/ }"
        fi
    else
        # No comma found, single key or modifier
        echo "${keys//_SPACE_/ }"
    fi
}

# Function to create a formatted header
create_header() {
    local title="$1"
    local header_line="━━━━ ${title} ━━━━"
    echo -e "${COLOR_HEADER}${header_line}${COLOR_RESET}"
}

# Parse the config file line by line
while IFS= read -r line; do
    # Check for category header comments
    if [[ "$line" =~ ^[[:space:]]*#CHEATSHEET_HEADER[[:space:]]+(.+) ]]; then
        current_category="${BASH_REMATCH[1]}"
        # Add header to output
        keybindings_with_categories+=("HEADER|${current_category}")
        continue
    fi
    
    # Skip regular comments and empty lines
    [[ "$line" =~ ^[[:space:]]*#[^C] ]] && continue
    [[ -z "${line// }" ]] && continue
    
    # Match bind, binde, bindr lines (skip bindm for mouse)
    if [[ "$line" =~ ^[[:space:]]*bind[er]?[[:space:]]*= ]]; then
        # Skip mouse bindings
        [[ "$line" =~ ^[[:space:]]*bindm ]] && continue
        
        # Parse the line - split by comma carefully
        if [[ "$line" =~ bind[er]?[[:space:]]*=[[:space:]]*([^,]+),[[:space:]]*([^,]+),[[:space:]]*(.+) ]]; then
            modifiers="${BASH_REMATCH[1]}"
            key="${BASH_REMATCH[2]}"
            command="${BASH_REMATCH[3]}"
            
            # Clean up whitespace
            modifiers="${modifiers#"${modifiers%%[![:space:]]*}"}"
            modifiers="${modifiers%"${modifiers##*[![:space:]]}"}"
            key="${key#"${key%%[![:space:]]*}"}"
            key="${key%"${key##*[![:space:]]}"}"
            command="${command#"${command%%[![:space:]]*}"}"
            command="${command%"${command##*[![:space:]]}"}"
            
            # Format the keys with proper spacing
            if [[ -n "$modifiers" && "$modifiers" != "" ]]; then
                formatted_keys=$(format_keys "$modifiers, $key")
            else
                formatted_keys=$(format_keys "$key")
            fi
            
            # Look up description or use fallback
            if [[ -n "${descriptions[$command]}" ]]; then
                description="${descriptions[$command]}"
            else
                # Fallback: clean up the command for display
                description="→ $command"
                # Make exec commands more readable
                description="${description//exec, /Run: }"
                description="${description//exec,/Run:}"
            fi
            
            # Store the keybinding with category marker
            keybindings_with_categories+=("BINDING|${formatted_keys}|${description}")
        fi
    fi
done < "$HYPRLAND_CONFIG"

# =============================================================================
# Step 4: Format and organize the output
# =============================================================================

# First pass: find maximum key length for alignment
max_key_length=0
for entry in "${keybindings_with_categories[@]}"; do
    if [[ "$entry" =~ ^BINDING\|([^|]+)\| ]]; then
        key="${BASH_REMATCH[1]}"
        if [[ ${#key} -gt $max_key_length ]]; then
            max_key_length=${#key}
        fi
    fi
done

# Add padding for better readability
max_key_length=$((max_key_length + 2))

# Second pass: create formatted output with headers
output=""
current_section=""
bindings_in_section=()

for entry in "${keybindings_with_categories[@]}"; do
    if [[ "$entry" =~ ^HEADER\|(.+) ]]; then
        # Output previous section's bindings if any
        if [[ ${#bindings_in_section[@]} -gt 0 ]]; then
            # Sort bindings in this section
            IFS=$'\n' sorted=($(sort <<<"${bindings_in_section[*]}"))
            unset IFS
            for binding in "${sorted[@]}"; do
                output="${output}${binding}\n"
            done
            output="${output}\n"  # Add spacing after section
            bindings_in_section=()
        fi
        
        # Add new header
        header_title="${BASH_REMATCH[1]}"
        header=$(create_header "$header_title")
        output="${output}${header}\n"
        
    elif [[ "$entry" =~ ^BINDING\|([^|]+)\|(.+) ]]; then
        key="${BASH_REMATCH[1]}"
        desc="${BASH_REMATCH[2]}"
        
        # Format with proper alignment
        formatted_line=$(printf "%-${max_key_length}s %s" "$key" "$desc")
        bindings_in_section+=("$formatted_line")
    fi
done

# Output any remaining bindings
if [[ ${#bindings_in_section[@]} -gt 0 ]]; then
    IFS=$'\n' sorted=($(sort <<<"${bindings_in_section[*]}"))
    unset IFS
    for binding in "${sorted[@]}"; do
        output="${output}${binding}\n"
    done
fi

# Handle case where no categories were defined - show all bindings under "All Keybindings"
if [[ ! "$output" =~ "━━━━" ]]; then
    output=""
    header=$(create_header "All Keybindings")
    output="${header}\n"
    
    # Collect all bindings
    all_bindings=()
    for entry in "${keybindings_with_categories[@]}"; do
        if [[ "$entry" =~ ^BINDING\|([^|]+)\|(.+) ]]; then
            key="${BASH_REMATCH[1]}"
            desc="${BASH_REMATCH[2]}"
            formatted_line=$(printf "%-${max_key_length}s %s" "$key" "$desc")
            all_bindings+=("$formatted_line")
        fi
    done
    
    # Sort and add to output
    IFS=$'\n' sorted=($(sort <<<"${all_bindings[*]}"))
    unset IFS
    for binding in "${sorted[@]}"; do
        output="${output}${binding}\n"
    done
fi

# =============================================================================
# Step 5: Display in fuzzel
# =============================================================================

# Note: fuzzel doesn't fully support ANSI colors, but some styling will show
# Remove the trailing newline and pipe to fuzzel 20lines and 85 width is perfect 
echo -ne "$output" | fuzzel \
    --dmenu \
    --lines 20 \
    --width 85 \
    --prompt "🔍 Keybindings: " \
    --no-exit-on-keyboard-focus-loss \
    --font "monospace:size=11" \
    --background "1e1e2eDD" \
    --text-color "cdd6f4FF" \
    --match-color "f38ba8FF" \
    --selection-color "313244FF" \
    --selection-text-color "cdd6f4FF" \
    --border-width 2 \
    --border-color "b4befeFF" \
    --horizontal-pad 15 \
    --vertical-pad 10