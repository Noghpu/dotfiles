if type -q passage; and test -r ~/.passage/identities
    set -gx EXA_API_KEY (passage show api/exa 2>/dev/null)
    set -gx JINA_API_KEY (passage show api/jina 2>/dev/null)
    set -gx PARALLEL_API_KEY (passage show api/parallel 2>/dev/null)
end
