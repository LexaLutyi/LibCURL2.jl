using LibCURL2
using Documenter

DocMeta.setdocmeta!(LibCURL2, :DocTestSetup, :(using LibCURL2); recursive=true)

makedocs(;
    modules=[LibCURL2],
    authors="Samarin Aleksei <liotbiu1@gmail.com> and contributors",
    repo="https://github.com/LexaLutyi/LibCURL2.jl/blob/{commit}{path}#{line}",
    sitename="LibCURL2.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://LexaLutyi.github.io/LibCURL2.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/LexaLutyi/LibCURL2.jl",
    devbranch="main",
)
