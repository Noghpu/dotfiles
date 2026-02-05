if type -q jj
    abbr --add tug --command jj 'bookmark move --from "heads(::@- & bookmarks())" --to @-'
end
