const AFINN_DF = Ref{Union{Nothing, DataFrame}}(nothing)

"""
$docstring_get_sentiment
"""
function get_sentiment()
    if isnothing(AFINN_DF[])
        afinn_path = joinpath(dirname(@__FILE__), "..", "data/AFINN-111.txt")
        rows = []
        open(afinn_path, "r") do file
            for line in eachline(file)
                k, v = split(line, '\t')
                push!(rows, (word=k, value=parse(Int, v)))
            end
        end
        AFINN_DF[] = DataFrame(rows)
    end
    return AFINN_DF[]
end

###
#AFINN SOURCE
# https://www2.imm.dtu.dk/pubdb/pubs/6010-full.html
# Finn Årup Nielsen A new ANEW: Evaluation of a word list for sentiment analysis in microblogs. 
# Proceedings of the ESWC2011 Workshop on 'Making Sense of Microposts': Big things come in small 
# packages 718 in CEUR Workshop Proceedings 93-98. 2011 May. http://arxiv.org/abs/1103.2903.

