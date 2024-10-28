#!/usr/bin/env nix
#!nix shell github:NixOS/nixpkgs/nixos-unstable#literate
#!nix --command lit --out-dir functions

# --- gcommit.fish
function gcommit --description 'Generate AI-assisted commit message and commit changes'
    argparse h/help -- $argv
    or return

    if set -q _flag_help
        echo "Usage: gcommit"
        echo "Generate an AI-assisted commit message based on git status and commit changes after confirmation"
        return 0
    end

    # Check if we're in a git repository
    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "Error: Not in a git repository" >&2
        return 1
    end

    # Get git status
    set -l git_status (git status --porcelain)
    if test -z "$git_status"
        echo "No changes to commit"
        return 0
    end

    # Get the full status for context
    set -l full_status (git status)

    # Generate commit message using aichat
    set -l commit_msg (echo "Generate a concise git commit message based on this status. Only output the commit message, no quotes or additional text: $full_status" | aichat)

    # Show the proposed commit message and ask for confirmation
    echo "Proposed commit message:"
    echo -----------------------
    echo $commit_msg
    echo -----------------------

    read -l -P "Proceed with commit? [Y/n/e(edit)] " confirm

    switch $confirm
        case "" Y y
            git commit -m "$commit_msg"
        case e E
            echo $commit_msg >/tmp/commit_msg
            $EDITOR /tmp/commit_msg
            set -l edited_msg (cat /tmp/commit_msg)
            git commit -m "$edited_msg"
            rm /tmp/commit_msg
        case '*'
            echo "Commit cancelled"
            return 1
    end
end
# ---


# --- rmdupes.fish
function rmdupes --description 'Remove duplicate files using fclones'
    argparse h/help -- $argv
    or return

    if set -q _flag_help
        echo "Usage: rmdupes [DIRECTORIES...]"
        echo "Remove duplicate files using fclones"
        return 0
    end

    set -l dirs $argv
    test (count $dirs) -eq 0
    and set dirs .

    fclones group $dirs | fclones remove
end
# ---

# --- fish_user_key_bindings.fish
function fish_user_key_bindings
    # Bind Alt-a to start aichat with current command line as input
    bind \ea __fish_aichat_commandline
end
# ---

# --- __fish_aichat_commandline.fish
function __fish_aichat_commandline --description 'Send current commandline to aichat'
    # Save current command line
    set -l cmd (commandline)

    # If command line is empty, let user type their question
    if test -z "$cmd"
        read -P "Ask AI: " -l cmd
    end

    # Only proceed if we have a command
    if test -n "$cmd"
        # Clear current command line
        commandline -r ""

        # Run aichat and get the response
        set -l result (echo $cmd | aichat)

        # Insert the result at the cursor position
        commandline -i -- $result
    end

    commandline -f repaint
end
# ---
