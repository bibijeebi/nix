function autogit
    # Check if we're in a git repository
    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "Error: Not a git repository"
        return 1
    end

    # Stage changes
    git add .

    # Get status and check if there are changes to commit
    set -l status (git status -s)
    if test -z "$status"
        echo "No changes to commit"
        return 0
    end

    # Get commit message from AI
    set -l message (aichat "Respond with and only with a suitable message for a git commit with this status:\n\n$status")
    if test -z "$message"
        echo "Error: Failed to generate commit message"
        return 1
    end

    # Commit changes
    if not git commit -m "$message"
        echo "Error: Failed to commit changes"
        return 1
    end

    # Pull changes (with error handling)
    if not git pull
        echo "Error: Failed to pull changes"
        return 1
    end

    # Push changes (with error handling)
    if not git push
        echo "Error: Failed to push changes"
        return 1
    end

    echo "Successfully committed, pulled, and pushed changes"
    return 0
end
