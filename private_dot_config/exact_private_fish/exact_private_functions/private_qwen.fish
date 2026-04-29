function qwen --description "Codex with on-prem Qwen (ollama profile + qwen-guidance injected via AGENTS.md)"
    set -l agents_file (pwd)/AGENTS.md
    set -l guidance_file ~/.codex/skills/qwen-guidance/AGENTS.md
    set -l injected 0

    if not test -f $agents_file
        cp $guidance_file $agents_file
        set injected 1
    end

    codex --profile ollama $argv
    set -l exit_code $status

    if test $injected -eq 1
        rm -f $agents_file
    end

    return $exit_code
end
