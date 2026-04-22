#
# ~/.bashrc
#

# Stop here if not running interactively
[[ $- != *i* ]] && return


#~/.config/ghostty/config/
#theme = Dracula+
# window-width = 100
# window-height = 30

# Load autocomplete
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi


# Ghostty Shell Integration
if [ -n "${GHOSTTY_RESOURCES_DIR}" ]; then
    builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/bash/ghostty.bash"
fi

# Run fast fetch
if [ -f /usr/bin/fastfetch ]; then
    fastfetch
fi

# --- CLEAR LOGIC ---
CLEAR_EXECUTED=0

alias c='CLEAR_EXECUTED=1; command clear'
alias clear='CLEAR_EXECUTED=1; command clear'
bind -x '"\C-l": clear'

# PS1 BUILD
# How many directory levels to show before truncating with '...'
export PROMPT_DIRTRIM=3

# PS1 BUILD
build_prompt() {
    # 0. Capture exit code IMMEDIATELY
    local exit_code=$? 

    # 1. FAST GIT BRANCH & DIRTY CHECK
    local branch=""
    local dirty=""
    if branch=$(git branch --show-current 2>/dev/null); then
        if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
            dirty=" "
        fi
    fi

    # 2. BACKGROUND GRADIENT (Standard 256-color grays)
    local bg1="\[\e[48;5;234m\]"
    local bg2="\[\e[48;5;236m\]"
    local bg3="\[\e[48;5;238m\]"
    
    local f_bg1="\[\e[38;5;234m\]"
    local f_bg2="\[\e[38;5;236m\]"
    local f_bg3="\[\e[38;5;238m\]"
    
    local bg_reset="\[\e[0m\]"
    
    # 3. GHOSTTY THEME-NATIVE TEXT COLORS
    local txt_user="\[\e[1;36m\]"   # Bold Cyan
    local txt_path="\[\e[1;34m\]"   # Bold White 
    local txt_branch="\[\e[1;35m\]" # Bold Green
    local txt_dirty="\[\e[1;33m\]"  # Bold Yellow
    local sep=""

# 4. DYNAMIC EXIT CAP (Avanzato con più codici)
    local cap_bg cap_fg cap_txt
    if [[ $exit_code -eq 0 ]]; then
        # 0: Successo (Verde)
        cap_bg="\[\e[42m\]" 
        cap_fg="\[\e[32m\]" 
        cap_txt="\[\e[1;30m\]  " 
    
    elif [[ $exit_code -eq 130 ]]; then
        # 130: Interrotto con Ctrl+C (Giallo)
        cap_bg="\[\e[43m\]" 
        cap_fg="\[\e[33m\]" 
        cap_txt="\[\e[1;30m\]  " 
    
    elif [[ $exit_code -eq 127 ]]; then
        # 127: Comando non trovato / Typo (Magenta)
        cap_bg="\[\e[45m\]" 
        cap_fg="\[\e[35m\]" 
        cap_txt="\[\e[1;30m\]  " # Icona Punto Interrogativo
    
    elif [[ $exit_code -eq 126 ]]; then
        # 126: Permesso Negato (Blu/Ciano)
        cap_bg="\[\e[46m\]" 
        cap_fg="\[\e[36m\]" 
        cap_txt="\[\e[1;30m\]  " # Icona Lucchetto
    
    else
        # Qualsiasi altro errore, come 1 o 2 (Rosso)
        cap_bg="\[\e[41m\]" 
        cap_fg="\[\e[31m\]" 
        cap_txt="\[\e[1;30m\]  ${exit_code} " 
    fi

    

    # --- SMART NEWLINE ---
    local p_start="\n"
    if [[ "$CLEAR_EXECUTED" == "1" ]]; then
        p_start=""
        CLEAR_EXECUTED=0
    fi

    # --- BUILD ---
    # Start directly with the User block
    local prompt="${p_start}${bg1}${txt_user}  \u "
    prompt+="${f_bg1}${bg2}${sep}${txt_path}  \w "

    # Check where the gray ribbon ends so the transition to the Color Cap is seamless
    local last_fg
    if [[ -n "$branch" ]]; then
        prompt+="${f_bg2}${bg3}${sep}${txt_branch}  ${branch}${txt_dirty}${dirty} "
        last_fg="${f_bg3}" # Transition out of Git Gray
    else
        last_fg="${f_bg2}" # Transition out of Path Gray
    fi

    # Join the last gray block to the Colored Status Cap
    prompt+="${last_fg}${cap_bg}${sep}"
    
    # Print the status icon/code inside the colored cap
    prompt+="${cap_txt}"

    # The final Powerline separator fading perfectly into your terminal background
    prompt+="${bg_reset}${cap_fg}${sep}${bg_reset} "

    export PS1="${prompt}"
}
PROMPT_COMMAND=build_prompt



alias sudo='sudo '

# 1. Autocompletion Behavior
bind 'set completion-ignore-case on'      # Ignore uppercase/lowercase when hitting Tab
bind 'set completion-map-case on'         # Treat hyphens (-) and underscores (_) as the same
bind 'set show-all-if-ambiguous on'       # Show all options on the first Tab hit

# 2. Autocompletion Visuals
bind 'set colored-stats on'               # Add colors to the autocomplete list
bind 'set colored-completion-prefix on'   # Highlight the letters you already typed
bind 'set mark-directories on'            # Add a slash (/) to the end of folder names in the list

# Aliases
if command -v eza >/dev/null 2>&1; then
    alias ls='eza'
    alias ll='eza -l --icons --git'
    alias la='eza -a'
    alias lt='eza --tree --level=2 --icons'
else
    alias ls='ls --color=auto'
    alias la='ls -a --color=auto'
fi

if command -v bat >/dev/null 2>&1; then
    alias cat='bat --paging=never'             
fi


alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -color=auto'
alias dmesg='dmesg --color=rel'

alias mkdir='mkdir -pv'
alias cp='cp -v'
alias mv='mv -v'

alias sudocode='sudoedit'
export SUDO_EDITOR="code --wait"

alias ai='aichat -s ai'
