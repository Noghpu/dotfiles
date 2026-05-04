export def qwen [...args: string] {
    if (which codex | is-empty) {
        error make { msg: "qwen: codex is required" }
    }

    let agents_file = ((pwd) | path join "AGENTS.md")
    let guidance_file = ($nu.home-dir | path join ".codex" "skills" "qwen-guidance" "AGENTS.md")
    let injected = (not ($agents_file | path exists)) and ($guidance_file | path exists)

    if $injected {
        cp $guidance_file $agents_file
    }

    ^codex --profile ollama ...$args
    let exit_code = $env.LAST_EXIT_CODE

    if $injected {
        rm -f $agents_file
    }

    if $exit_code != 0 {
        exit $exit_code
    }
}

export def apply_typing_templates [
    target: path = "."
] {
    if (which git | is-empty) {
        error make { msg: "apply_typing_templates: git is required" }
    }

    let tmp = "/tmp/typing-tpl"
    if ($tmp | path exists) {
        rm -rf $tmp
    }

    ^git clone --depth 1 https://github.com/Noghpu/python-typing-templates $tmp
    mkdir $target
    ls $tmp | each {|entry| cp -r $entry.name $target }
    rm -rf $tmp
}
