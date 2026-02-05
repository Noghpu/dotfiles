if type -q chezmoi
    abbr -a cm chezmoi
    abbr -a cmca "chezmoi add . && chezmoi git add . && chezmoi git commit -- -a -m 'update'"
end
