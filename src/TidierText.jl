module TidierText

using MacroTools
using StatsBase
using Languages
using DataFrames
using Reexport

include("docstrings.jl")
include("nma.jl")

@reexport using DataFrames: DataFrame

export get_stopwords, @bind_tf_idf, @unnest_characters, @unnest_ngrams, @unnest_regex, @unnest_tokens, tidy, nma_words 

"""
$docstring_get_stopwords
"""
function get_stopwords()
    return DataFrame(word = stopwords(Languages.English()))
end

"""
$docstring_tidy
"""
function tidy(corpus)
    return DataFrame(corpus)
  end

### tokenizers and functions. Macros are below.
function bind_tf_idf(df::DataFrame, term_col::Symbol, document_col::Symbol, n_col::Symbol)
    df_copy = copy(df)
    total_docs = length(unique(df_copy[!, document_col]))

    df_copy[!, :tf] = zeros(size(df_copy, 1))
    df_copy[!, :idf] = zeros(size(df_copy, 1))
    df_copy[!, :tf_idf] = zeros(size(df_copy, 1))
    
    # Calculate Term Frequency (TF)
    for doc in unique(df_copy[!, document_col])
        doc_rows = df_copy[df_copy[!, document_col] .== doc, :]
        total_terms_in_doc = sum(doc_rows[!, n_col])
        
        # Update the TF column directly
        tf_values = doc_rows[!, n_col] ./ total_terms_in_doc
        df_copy[df_copy[!, document_col] .== doc, :tf] = tf_values
    end
    
    # Calculate Inverse Document Frequency (IDF)
    term_table = countmap(df_copy[!, term_col])  # Adjusted this line to match R's table(terms)
    for term in keys(term_table)
        term_count = term_table[term]  # Get term count from the term_table
        
        # Update the IDF column directly
        idf_value = log(total_docs / term_count)
        df_copy[df_copy[!, term_col] .== term, :idf] = fill(idf_value, size(df_copy[df_copy[!, term_col] .== term, :], 1))
    end
    
    # Calculate TF-IDF
    df_copy[!, :tf_idf] = df_copy[!, :tf] .* df_copy[!, :idf]
    
    return df_copy
end

function regex_tokenizer(text::String, pattern="\\s*")
    tokens = split(text, Regex(pattern), keepempty=false)
    stripped_tokens = strip.(tokens)
    #println("Original: ", repr(text))  # Debug line
    #println("Tokens after stripping: ", stripped_tokens)  # Debug line
    return filter(x -> x != "", stripped_tokens)
end

function character_tokenizer(text::String; to_lower=true, strip_non_alphanum::Bool=true)
    to_lower && (text = lowercase(text))
    if strip_non_alphanum
        text = filter.(!ispunct, text)
    end
    return collect(text)
end


function ngram_tokenizer(text::String; n::Int=2, to_lower::Bool=true, strip_non_alphanum::Bool=true)
    to_lower && (text = lowercase(text))
    tokens = split(replace(text, r"[^\w\s]" => ""), r"\s")
    if strip_non_alphanum
        text = filter.(!ispunct, text)
    end
    return [join(tokens[i:i+n-1], " ") for i in 1:length(tokens)-n+1]
end

function punctuation_space_tokenize(text::String; to_lower=true)
    to_lower && (text = lowercase(text))
    return split(replace(text, r"[^\w\s]" => ""), r"\s")
end

function unnest_tokens(df::DataFrame, output_col::Symbol, input_col::Symbol, 
    tokenizer::Function; 
    to_lower::Union{Bool, Nothing}=nothing, 
    strip_non_alphanum::Union{Bool, Nothing}=nothing)
    
    texts = df[!, input_col]
    to_lower = isnothing(to_lower) ? true : to_lower
    strip_non_alphanum = isnothing(strip_non_alphanum) ? true : strip_non_alphanum

    if to_lower
        texts = lowercase.(texts)
    end

    if strip_non_alphanum
        texts = filter.(!ispunct, texts)
    end
    token_list = tokenizer.(texts)

    df = select(df, Not(input_col))
    flat_token_list = reduce(vcat, token_list)
    repeat_lengths = length.(token_list)

    repeat_indices = Vector{Int}(undef, sum(repeat_lengths))
    counter = 1
    @inbounds for i in eachindex(repeat_lengths)
    repeat_indices[counter:counter+repeat_lengths[i]-1] .= i
    counter += repeat_lengths[i]
    end

    new_df = df[repeat_indices, :]
    new_df[!, output_col] = flat_token_list

    return new_df
end


function unnest_regex(df, output_col, input_col; pattern="\\s+", to_lower=true, strip_non_alphanum = true)
    return unnest_tokens(df, output_col, input_col, text -> regex_tokenizer(text, pattern); to_lower=to_lower, strip_non_alphanum = strip_non_alphanum)
end

function unnest_ngrams(df, output_col, input_col, n=2; to_lower=true, strip_non_alphanum=true)
    # Creating a specific tokenizer for the 'n' provided
    function ngram_tokenizer_specific(text::String)
        return ngram_tokenizer(text, n=n, to_lower=to_lower)
    end
    
    # Utilizing unnest_tokens, passing the ngram_tokenizer and argument n
    return unnest_tokens(df, output_col, input_col, ngram_tokenizer_specific; 
                         to_lower=to_lower, strip_non_alphanum = strip_non_alphanum)
end



function unnest_characters(df::DataFrame, output_col::Symbol, input_col::Symbol; to_lower::Bool=true, strip_non_alphanum::Bool=true)
    return unnest_tokens(df, output_col, input_col, 
                         (text, args...) -> character_tokenizer(text; to_lower=to_lower, strip_non_alphanum=strip_non_alphanum); 
                         to_lower=to_lower, strip_non_alphanum=strip_non_alphanum)
end


### Macros

"""
$docstring_bind_tf_idf
"""
macro bind_tf_idf(df, term_col, document_col, n)
    term_col = QuoteNode(term_col)
    document_col = QuoteNode(document_col)
    n = QuoteNode(n)
    
    return quote
        bind_tf_idf($(esc(df)), $term_col, $document_col, $n)
    end
end

"""
$docstring_unnest_tokens
"""
macro unnest_tokens(df, output_col, input_col, args...)
    to_lower_expr = :false
    strip_non_alphanum_expr = :true

    for arg in args
        if isa(arg, Expr) && arg.head == :(=)
            if arg.args[1] == :to_lower
                to_lower_expr = arg.args[2]
            elseif arg.args[1] == :strip_non_alphanum
                strip_non_alphanum_expr = arg.args[2]
            end
        end
    end

    quote
        unnest_regex($(esc(df)), $(QuoteNode(output_col)), $(QuoteNode(input_col)); 
                     to_lower = $to_lower_expr, strip_non_alphanum = $strip_non_alphanum_expr)
    end
end

"""
$docstring_unnest_regex
"""
macro unnest_regex(df, output_col, input_col, pattern="\\s+", args...)
    to_lower_expr = :false
    strip_non_alphanum_expr = :true

    for arg in args
        if isa(arg, Expr) && arg.head == :(=)
            if arg.args[1] == :to_lower
                to_lower_expr = arg.args[2]
            elseif arg.args[1] == :strip_non_alphanum
                strip_non_alphanum_expr = arg.args[2]
            end
        end
    end

    quote
        unnest_regex($(esc(df)), $(QuoteNode(output_col)), $(QuoteNode(input_col)); 
                     pattern = $(pattern), to_lower = $to_lower_expr, strip_non_alphanum = $strip_non_alphanum_expr)
    end
end

"""
$docstring_unnest_ngrams
"""
macro unnest_ngrams(df, output_col, input_col, n, to_lower=false, strip_non_alphanum = true)
    return quote
        unnest_ngrams($(esc(df)), $(QuoteNode(output_col)), $(QuoteNode(input_col)), $(esc(n)); to_lower=$(to_lower), strip_non_alphanum=$(strip_non_alphanum))
    end
end

#"""
#$docstring_unnest_character_shingles
#"""
#macro unnest_character_shingles(df, output_col, input_col, n, to_lower=false, strip_non_alphanum = false)
#    return quote
#        unnest_character_shingles($(esc(df)), $(QuoteNode(output_col)), $(QuoteNode(input_col)), $(esc(n)); to_lower=$(to_lower), strip_non_alphanum=$(strip_non_alphanum) )
#    end
#end

"""
$docstring_unnest_characters
"""
macro unnest_characters(df, output_col, input_col, args...)
    to_lower_expr = :false
    strip_non_alphanum_expr = :true

    for arg in args
        if isa(arg, Expr) && arg.head == :(=)
            if arg.args[1] == :to_lower
                to_lower_expr = arg.args[2]
            elseif arg.args[1] == :strip_non_alphanum
                strip_non_alphanum_expr = arg.args[2]
            end
        end
    end

    quote
        unnest_characters($(esc(df)), $(QuoteNode(output_col)), $(QuoteNode(input_col)); 
                          to_lower = $to_lower_expr, strip_non_alphanum = $strip_non_alphanum_expr)
    end
end


end
