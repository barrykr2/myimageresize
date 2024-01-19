#!/bin/bash

# Check if the required number of arguments is provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <new_size_percentage> <destination_folder> [-i] [-a | <file1> <file2> ...]"
    echo "    If there is a duplicate file these are the following overwrite options:"
    echo "        y = yes overwrite existing file"
    echo "        n = don't overwrite existing file"
    echo "        a = yes overwrite ALL existing files"
    echo "        d = don't overwrite ALL existing files"
    echo "        q = quite process"
    exit 1
fi

# Extract command-line arguments
new_size="$1"
destination_folder="$2"
overwrite_all=false
skip_remaining=false

# Check for the -i flag
if [ "$3" == "-i" ]; then
    overwrite_all=true
    shift
fi

shift 2

# Check if the destination folder exists, create if not
if [ ! -d "$destination_folder" ]; then
    mkdir -p "$destination_folder"
fi

# Resize function
resize_image() {
    for file; do
        output_file="$destination_folder/$(basename "$file")"
        
        # Check if the file already exists
        if [ -e "$output_file" ]; then
            if [ "$overwrite_all" == true ]; then
                # Overwrite all without asking
                echo "Resizing $file"
                convert "$file" -resize "$new_size%" "$output_file"
            else
                if [ "$skip_remaining" == true ]; then
                    echo "Skipping $file"
                else
                    # Ask for user input
                    read -p "File '$output_file' already exists. Overwrite? (y/n/a/d/q): " response
                    case "$response" in
                        y)
                            echo "Resizing $file"
                            convert "$file" -resize "$new_size%" "$output_file"
                            ;;
                        a)
                            echo "Resizing $file"
                            convert "$file" -resize "$new_size%" "$output_file"
                            overwrite_all=true
                            ;;
                        n)
                            echo "Skipping existing $file"
                            continue
                            ;;
                        d)
                            echo "Skipping all remaining existing files."
                            skip_remaining=true
                            echo "Skipping $file"
                            continue
                            ;;
                        q)
                            echo "Exiting the script."
                            exit 0
                            ;;
                        *)
                            echo "Invalid option. Skipping $file"
                            continue
                            ;;
                    esac
                fi
            fi
        else
            echo "Resizing $file"
            convert "$file" -resize "$new_size%" "$output_file"
        fi
    done
}

# Check if the "-a" flag is present
if [ "$1" == "-a" ]; then
    # Process all JPEG files in the current directory
    resize_image *.jpg
else
    # Process specified files
    resize_image "$@"
fi

echo "V9 Resizing complete."

