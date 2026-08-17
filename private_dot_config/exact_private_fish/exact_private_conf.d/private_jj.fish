status is-interactive; or return

if type -q jj
    abbr --add tug --command jj 'bookmark move --from "heads(::@- & bookmarks())" --to @-'
end
