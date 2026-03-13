# jj (Jujutsu) aliases

if (which jj | is-empty) { return }

def tug [] {
    jj bookmark move --from "heads(::@- & bookmarks())" --to @-
}
