function apply_typing_templates
    git clone --depth 1 https://github.com/Noghpu/python-typing-templates /tmp/typing-tpl \
        && cp -rf /tmp/typing-tpl/ . \
        && rm -rf /tmp/typing-tpl
end
