#!/usr/bin/env bash

# The output of this script is as follows:
# 1. One line "checking commits between: <start_commit> <end_commit>"
# 2. One line for each commit message that is not well-formed
# 3. One line with the value of "is_breaking_change" (true/false)

set -euo pipefail

# Colors
export YLW='\033[1;33m'
export RED='\033[0;31m'
export GRN='\033[0;32m'
export BLU='\033[0;34m'
export BLD='\033[1m'
export RST='\033[0m'

# Clear line
export CLR='\033[2K'

parse_commits() {

    BASE_BRANCH=${BASE_BRANCH:-main}

    start_commit=${1:-origin/${BASE_BRANCH}}
    end_commit=${2:-HEAD}
    is_breaking_change=false
    exit_code=0

    echo -e "${GRN}Checking commits between:${RST} $start_commit $end_commit"
    # Run the loop in the current shell using process substitution
    while IFS= read -r message || [ -n "$message" ]; do
        # Check if commit message follows conventional commits format
        if [[ $message =~ ^(build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test)(\(.*\))?(\_|!):.*$ ]]; then
            # Check for breaking changes
            if [[ ${BASH_REMATCH[3]} == *'!'* ]]; then
                is_breaking_change=true
            fi
        else
            echo -e "${YLW}Commit message is ill-formed:${RST} $message"
            exit_code=1
        fi
    done < <(git log --format=%s "$start_commit".."$end_commit")

    echo "$is_breaking_change"
    exit ${exit_code}
}

parse_commits "$@"
