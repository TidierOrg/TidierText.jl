module TestTidierText


using TidierText
using Test
using Documenter

DocMeta.setdocmeta!(TidierText, :DocTestSetup, :(using TidierText); recursive=true)

doctest(TidierText)

end
