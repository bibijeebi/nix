function rmdupes --description "Remove duplicate files using fclones"
    argparse 'h/help' -- $argv
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

complete -c rmdupes -f -a "(__fish_complete_directories)"
complete -c rmdupes -s h -l help -d "Show help message"
