#!/bin/bash

check_dialog_installed() {
    if ! command -v dialog &>/dev/null; then
        echo "The 'dialog' package is not installed. Attempting to install it..."

        if command -v apt &>/dev/null; then
            sudo apt update && sudo apt install -y dialog
        elif command -v yum &>/dev/null; then
            sudo yum install -y dialog
        elif command -v pacman &>/dev/null; then
            sudo pacman -S --noconfirm dialog
        else
            echo "No compatible package manager found. Please install 'dialog' manually."
            exit 1
        fi
    fi
}

check_dialog_installed

memories=()
cleared_memories=()

show_progress() {
    local memory="$1"
    local messages=("Reflecting on memories..." "Dusting away the past..." "Erasing traces..." "Letting go gracefully..." "Making space for new beginnings...")
    local progress=0

    while [[ $progress -lt 100 ]]; do
        sleep 0.1
        ((progress += RANDOM % 5 + 1))
        ((progress = progress > 100 ? 100 : progress))
        local msg="${messages[(progress / 25) % ${#messages[@]}]}"
        echo "$progress" | dialog --title "Clearing \"$memory\"" --gauge "$msg\nProgress: $progress%" 7 50
    done

    echo "100" | dialog --title "Clearing \"$memory\"" --gauge "Done! 🎉\nProgress: 100%" 7 50
    cleared_memories+=("$memory")
    sleep 1  
}

dialog --title "Welcome" --msgbox "Welcome to the Memory Clearing Tool! This script allows you to release memories you may no longer need. Let’s make space for new experiences." 10 50

user_name=$(dialog --inputbox "To start, please tell me your name:" 8 50 3>&1 1>&2 2>&3 3>&-)
clear
if [[ -z "$user_name" ]]; then
    dialog --msgbox "No name entered. Exiting." 5 40
    clear
    exit 1
fi

dialog --msgbox "Hello, $user_name. Let’s take a journey to let go of some memories." 8 50
dialog --msgbox "This tool is meant to help you release memories that may be holding you back." 8 50

while true; do
    memory=$(dialog --inputbox "What memory would you like to release?\n(e.g., an old regret, a missed opportunity, or a painful goodbye)\n\nType 'done' to finish." 12 60 3>&1 1>&2 2>&3 3>&-)
    [[ "$memory" == "done" ]] && break
    [[ -n "$memory" ]] && memories+=("$memory")
done

if [[ ${#memories[@]} -eq 0 ]]; then
    dialog --msgbox "It seems there are no memories to clear today. Take care, $user_name!" 7 50
    clear
    exit 0
fi

selected_memories=$(dialog --checklist "Select memories to clear [Press Space]:" 15 60 8 \
    $(for i in "${!memories[@]}"; do echo "$i" "${memories[$i]}" off; done) \
    3>&1 1>&2 2>&3 3>&-)

if [[ -z "$selected_memories" ]]; then
    dialog --msgbox "No memories selected for clearing." 6 50
else
    dialog --title "Confirmation" --yesno "Are you ready to let go of these memories, $user_name?" 7 50
    response=$?
    if [[ $response -eq 1 ]]; then
        dialog --msgbox "No worries. Keep them for as long as you need." 7 50
        clear
        exit 0
    fi

    for i in $selected_memories; do
        show_progress "${memories[$i]}"
    done

    dialog --msgbox "Clearing complete! You've let go of:\n\n$(printf '%s\n' "${cleared_memories[@]}")\n\nWishing you peace and space for new memories." 15 60
fi

dialog --title "Goodbye" --msgbox "Thank you for using the Memory Clearing Tool, $user_name.\nTake a deep breath and enjoy your fresh start." 8 50
clear
exit 0

