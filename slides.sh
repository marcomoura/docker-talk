#!/bin/bash

# Copyright (c) 2017 Stanislav Kontar
# License: MIT
#
# Inspired by https://github.com/fxn/tkn

CODE_STYLE="breeze"
SECTION_DECORATION=" ❧❦☙ "
LEN_DECORATION="${#SECTION_DECORATION}"

FORMATTING=(
    "<b>" $( tput bold )
    "<s>" $( tput smso )
    "<i>" $( tput sitm )
    "<u>" $( tput smul )
    "<r>" $( tput sgr0 )
    "<R>" $( tput setaf 196 )
    "<G>" $( tput setaf 82 )
    "<B>" $( tput setaf 39 )
    "<Y>" $( tput setaf 226 )
    "<V>" $( tput setaf 129 )
    "<E>" $( tput setaf 248 )
)
NR_FORMATTING="${#FORMATTING[@]}"
for (( i = 0; i < NR_FORMATTING; i += 2 )); do
    SED_DELETE+=" -e s/${FORMATTING[i]}//g"
    SED_REPLACE+=" -e s/${FORMATTING[i]}/${FORMATTING[i + 1]}/g"
done


prepare_terminal() {
    # Get terminal values, clean terminal and remove cursor
    rows=$( tput lines )
    columns=$( tput cols )
    tput clear
    tput civis
}


restore_terminal() {
    # Clean terminal and show cursor again
    tput clear
    tput cnorm  
}


show_slide() {
    local i
    prepare_terminal
    
    # Compute vertical padding
    lines_padding=$(( (rows - nr_lines) / 2 ))
    (( (rows - nr_lines) % 2 && lines_padding++ ))  # Round up
    
    # Center slide type
    if [[ "$format" == "center" ]]; then
        for (( i = 0; i < lines_padding; i++ )); do
            echo 
        done
        
        for (( i = 0; i < nr_lines; i++ )); do
            # Compute horizontal padding for every line
            filler=$(( (columns - ${#clear_lines[i]} ) / 2 ))
            (( (columns - ${#clear_lines[i]} ) % 2 && filler++ ))  # Round up

            printf "%${filler}s" " "
            echo -e "${lines[i]}"
        done
        
    # Block slide type
    elif [[ "$format" == "block" ]]; then
        for (( i = 0; i < lines_padding; i++ )); do
            echo
        done
        
        # Compute horizontal paddig for whole block
        longest=0
        for (( i = 0; i < nr_lines; i++ )); do
            if (( ${#clear_lines[i]} > longest )); then
                longest=${#clear_lines[i]}
            fi
        done
        filler=$(( (columns - longest) / 2 ))
        (( (columns - longest) % 2 && filler++ ))  # Round up
        
        for (( i = 0; i < nr_lines; i++ )); do
            printf "%${filler}s" " "
            echo -e "${lines[i]}"
        done

    # Code slide type
    elif [[ "$format" =~ code ]]; then
        # Perform code formatting
        text=$( local IFS=$'\n'; echo "${raw_lines[*]}"; )
        formatted_text=$( highlight -S "$code" -s "$CODE_STYLE" -O xterm256 <<< "$text" )
        readarray -t formatted_lines <<< "$formatted_text"

        for (( i = 0; i < lines_padding; i++ )); do
            echo
        done
        
        # Compute horizontal paddig for whole code block
        longest=0
        for (( i = 0; i < nr_lines; i++ )); do
            if (( ${#raw_lines[i]} > longest )); then
                longest=${#raw_lines[i]}
            fi
        done
        filler=$(( (columns - longest) / 2 ))
        (( (columns - longest) % 2 && filler++ ))  # Round up
        
        for (( i = 0; i < nr_lines; i++ )); do
            printf "%${filler}s" " "
            echo -e "${formatted_lines[i]}"
        done

    # Section slide type
    elif [[ "$format" == "section" ]]; then
        # Shorter vertical padding because of decorations
        for (( i = 0; i < lines_padding - 2; i++ )); do
            echo 
        done

        # Compute horizontal decoration padding
        longest=0
        for (( i = 0; i < nr_lines; i++ )); do
            if (( ${#clear_lines[i]} > longest )); then
                longest=${#clear_lines[i]}
            fi
        done
        line_filler=$(( (columns - longest) / 2 - 1 ))
        (( (columns - longest) % 2 && line_filler++ ))  # Round up
        line_length=$(( (longest - LEN_DECORATION) / 2 + 1 ))
        (( (longest - LEN_DECORATION) % 2 && line_length++ ))  # Round up

        # Upper decoration
        printf "%${line_filler}s" " "
        for (( i = 0; i < line_length; i++ )); do
            printf "─"
        done
        printf "%s" "$SECTION_DECORATION"
        for (( i = 0; i < line_length; i++ )); do
            printf "─"
        done
        echo
        echo

        for (( i = 0; i < nr_lines; i++ )); do
            # Compute horizontal padding for every line
            filler=$(( (columns - ${#clear_lines[i]}) / 2 ))
            (( (columns - ${#clear_lines[i]}) % 2 && filler++ ))  # Round up
            # Also need to move one char right if line is one character longer
            (( (longest - LEN_DECORATION) % 2 && filler++ ))  
            
            printf "%${filler}s" " "
            echo -e "${lines[i]}"
        done

        # Lower decoration
        echo       
        printf "%${line_filler}s" " "
        for (( i = 0; i < line_length; i++ )); do
            printf "─"
        done
        printf "%s" "$SECTION_DECORATION"
        for (( i = 0; i < line_length; i++ )); do
            printf "─"
        done
        
    # Unknown slide type
    else
        for (( i = 0; i < nr_lines; i++ )); do
            echo -e "${lines[i]}"
        done
    fi
}


load_slide() {
    n="$1"
    slide_file="${slides[n]}"
    filename="${slide_file##*/}"
    
    format=$( head -n 1 "$slide_file" )
    raw_text=$( tail -n +3 "$slide_file" )
    
    if [[ "$format" =~ code ]]; then
        # Get highlighting type
        code=$( sed -r -n 's/^code[[:space:]]+(.*)$/\1/p' <<< "$format" )
    else
        # Apply formatting
        clear_text=$( sed $SED_DELETE <<< "$raw_text" )
        text=$( sed $SED_REPLACE <<< "$raw_text" )
    fi
    
    readarray -t raw_lines <<< "$raw_text"
    readarray -t clear_lines <<< "$clear_text"
    readarray -t lines <<< "$text"
    
    nr_lines=${#raw_lines[@]}    
    # Ignore empty lines at the end of the slide
    while [[ "${raw_lines[nr_lines - 1]}" == "" ]] && (( nr_lines > 0 )); do
        (( nr_lines-- ))
    done   
}


check_slide() {
    local i
    # Check if slide fits in the terminal
    if (( nr_lines > rows - 2 )); then
        echo "Slide '$slide_file' too tall."
        return 1
    fi
    for (( i = 0; i < nr_lines; i++ )); do
        if (( ${#clear_lines[i]} > columns - 4 )); then
            echo "Slide '$slide_file' too wide."
            return 1
        fi
    done
    return 0
}


read_slides() {
    local i
    prepare_terminal
    
    # Prepare list of slides
    directory="${1:-example}"
    directory="${directory%%/}"
    i=0
    for file in ${directory}/slide_*; do
        slides[i++]="$file"
    done
    nr_slides="${#slides[@]}"
    
    # Check if all slides will fit in the terminal
    for (( i = 0; i < nr_slides; i++ )); do
        load_slide "$i"
        if ! check_slide; then
            return 1
        fi
    done
    return 0
}


show_status() {
    local i
    skip=$(( rows - nr_lines - lines_padding - 1 ))
    if [[ "$format" == "section" ]]; then
        (( skip-- ))
    fi
    for (( i = 0; i < skip; i++ )); do
        echo
    done
    status_slide="$(( slide + 1 ))/$nr_slides [$filename]"
    status_time=$( date +"%-k:%M" )
    status_filler=$(( columns - ${#status_slide} - ${#status_time} - 2 ))
    printf " %s%s%${status_filler}s%s%s" "$( tput setaf 240 )" "$status_slide" " " "$status_time" "$( tput sgr0 )"
}

hide_mouse_cursor() {
    if [[ "$unclutter_installed" ]]; then
        unclutter -idle 1 &
        PID="$!"
    fi
}

show_mouse_cursor() {
    if [[ "$unclutter_installed" ]]; then
        kill "$PID"
        sleep 0.1
    fi
}


# Check if syntax highlighter is installed
if ! command -v highlight &> /dev/null; then
    echo "'highlight' command is required, but not installed. Exiting."
    exit 1
fi

# Check if unclutter is installed
if command -v unclutter &> /dev/null; then
    unclutter_installed=true
fi

slide=0  # Current slide
status=0  # Status line
read_slides "$1"
should_show="!$?"

hide_mouse_cursor

while true; do
    # Do not allow current slide number outside bounds
    (( slide < 0 )) && slide=0
    (( slide >= nr_slides )) && slide=$(( nr_slides - 1 ))

    # Only show slide if checks passed
    if (( should_show )); then
        load_slide "$slide"
        show_slide
        if (( status )); then
            show_status
        fi
    fi
    
    # Read just one key press
    read -rsn1 response
    
    # Handle arrows, Page Up, Page Down, Home, End, and ESC
    if [[ "$response" == $'\x1b' ]]; then
        read -rsn1 -t 0.1 response
        if [[ "$response" == "[" ]]; then
            read -rsn1 -t 0.1 response
            if [[ "$response" == "D" || "$response" == "5" ]]; then
                (( slide-- ))
            elif [[ "$response" == "C" || "$response" == "6" ]]; then
                (( slide++ ))
            elif [[ "$response" == "A" || "$response" == "H"  ]]; then
                (( slide = 0 ))
            elif [[ "$response" == "B" || "$response" == "F" ]]; then
                (( slide = nr_slides - 1 ))
            fi
        else
            break
        fi
    # Space or Enter, K
    elif [[ "$response" == "" || "$response" == "k" ]]; then
        (( slide++ ))
    # Backspace, J
    elif [[ "$response" == $'\x7F' || "$response" == "j" ]]; then
        (( slide-- ))
    # R
    elif [[ "$response" == "r" ]]; then
        read_slides "$1"
        should_show="!$?"
    # B
    elif [[ "$response" == "b" ]]; then
        should_show=$(( ! should_show ))
        prepare_terminal
    # S
    elif [[ "$response" == "s" ]]; then
        (( status = ! status ))
    # Q
    elif [[ "$response" == "q" ]]; then
        break
    # P
    elif [[ "$response" == "p" ]]; then   
        # Check if ImageMagick is installed
        if ! command -v import &> /dev/null && ! command -v convert &> /dev/null; then
            echo "ImageMagick is required, but not installed. Export to PDF disabled."
            sleep 2
        # Check if xprop is installed
        elif ! command -v xprop &> /dev/null; then
            echo "'xprop' is required, but not installed. Export to PDF disabled."
            sleep 2
        else
            mkdir -p export
            active_window=$( xprop -root 32x '\t$0' _NET_ACTIVE_WINDOW | cut -f 2 ) 
            for (( i = 0; i < nr_slides; i++ )); do
                load_slide "$i"
                show_slide
                sleep 0.1
                import -window "$active_window" "export/${filename}.png"
            done
            convert "export/*.png" "${directory}.pdf"
            restore_terminal
            break
        fi
    fi
done

show_mouse_cursor
restore_terminal
