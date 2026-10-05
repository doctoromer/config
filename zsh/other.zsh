# Rust

rt() {
    local run_ignored="true"
    local test_name=""
    local ignored_flag=""

    while getopts "i" opt; do
    case $opt in
        i) run_ignored="false" ;;
    esac
    done
    shift $((OPTIND - 1))

    test_name="$1"

    if [ -z "$test_name" ]; then
    echo "Please provide a test name."
    return 1
    fi

    [ "$run_ignored" = "true" ] && ignored_flag=(--run-ignored all)

    RUST_BACKTRACE=1 cargo nextest run --features rewrite-tracker,  -v -E "test(/$test_name$/)" $ignored_flag --no-capture | tee log1.log && \
        cat log1.log | sed -r "s/\x1B\[[0-9;]*[mK]//g" > log1_stripped.log
    notify-send 'FINISHED COMPILATION!!!'
}

fixrust() {
    cargo clippy --fix --allow-dirty --allow-staged --all-targets --all-features && cargo fmt
}

# Other

alias dc='docker compose'

show() {
  local query="$*" file
  local -a matches
  matches=("${(@f)$(find . -type f -iname '*.md' -print 2>/dev/null | sort | fzf --filter="$query")}")
  matches=("${(@)matches:#}")
  case ${#matches[@]} in
    0) printf 'No markdown files match: %s\n' "$query" >&2; return 1 ;;
    1) file=${matches[1]} ;;
    *) file=$(printf '%s\n' "${matches[@]}" | fzf --query "$query") || return ;;
  esac
  mdcat -p --columns 150 --margin "$file"
}
