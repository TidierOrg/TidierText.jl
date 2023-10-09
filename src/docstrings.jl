const docstring_get_stopwords = 
"""
    get_stopwords()

Returns a DataFrame containing English stopwords.

# Returns
- `DataFrame` with a single column `word`, each row containing a stopword.

# Examples
```jldoctest
julia> get_stopwords();
```
"""

const docstring_antijoin = 
"""
    @antijoin(df1, df2)

Performs an anti-join operation on `df1` and `df2`, returning rows from `df1` that do not have matching rows in `df2`.

# Arguments
- `df1`: The left DataFrame.
- `df2`: The right DataFrame.

# Returns
- A new DataFrame containing the result of the anti-join operation.

# Examples
```jldoctest
julia> df1 = DataFrame(ID = [1, 2, 3, 4, 5], Name = ["A", "B", "C", "D", "E"]);
       df2 = DataFrame(ID = [3, 4, 5, 6, 7], Test = ["C", "D", "E", "F", "G"]);

julia> @antijoin(df1, df2)
2×2 DataFrame
 Row │ ID     Name   
     │ Int64  String 
─────┼───────────────
   1 │     1  A
   2 │     2  B

```
"""
const docstring_bind_tf_idf = 
"""
    @bind_tf_idf(df, term_col, document_col, n)

Calculates TF-IDF values for the specified columns of `df`.

# Arguments
- `df`: The input DataFrame.
- `term_col`: The column containing terms.
- `document_col`: The column containing document identifiers.
- `n`: The column containing term frequencies.

# Returns
- A new DataFrame containing TF, IDF, and TF-IDF values.

# Examples
```jldoctest
julia> df = DataFrame(
       doc_id = [1, 1, 2, 2, 3, 3], 
       term = ["apple", "banana", "apple", "cherry", "banana", "date"],
       n = [1, 4, 6, 4, 9, 8]);

julia> @bind_tf_idf(df, doc_id, term, n)
6×6 DataFrame
 Row │ doc_id  term    n      tf        idf       tf_idf   
     │ Int64   String  Int64  Float64   Float64   Float64  
─────┼─────────────────────────────────────────────────────
   1 │      1  apple       1  0.142857  0.693147  0.099021
   2 │      1  banana      4  0.307692  0.693147  0.213276
   3 │      2  apple       6  0.857143  0.693147  0.594126
   4 │      2  cherry      4  1.0       0.693147  0.693147
   5 │      3  banana      9  0.692308  0.693147  0.479871
   6 │      3  date        8  1.0       0.693147  0.693147
```
"""

const docstring_unnest_tokens = 
"""
    @unnest_tokens(df, output_col, input_col, to_lower=false)

Tokenizes the text in `input_col` of `df` into separate words, outputting the result to `output_col`.

# Arguments
- `df`: The input DataFrame.
- `output_col`: The name of the output column to store the tokens.
- `input_col`: The name of the input column containing text to tokenize.
- `to_lower`: A boolean indicating whether to convert text to lowercase before tokenizing.

# Returns
- A new DataFrame with the tokenized text.

# Examples
```jldoctest
julia> @unnest_tokens(df, word, text)
10×2 DataFrame
 Row │ doc    word      
     │ Int64  SubStrin… 
─────┼──────────────────
   1 │     1  The
   2 │     1  quick
   3 │     1  brown
   4 │     1  fox
   5 │     1  jumps.
   6 │     2  One
   7 │     2  column
   8 │     2  and
   9 │     2  the
  10 │     2  one
  11 │     2  row?

julia> @unnest_tokens(df, word, text, to_lower = true)
11×2 DataFrame
 Row │ doc    word      
     │ Int64  SubStrin… 
─────┼──────────────────
   1 │     1  the
   2 │     1  quick
   3 │     1  brown
   4 │     1  fox
   5 │     1  jumps.
   6 │     2  one
   7 │     2  column
   8 │     2  and
   9 │     2  the
  10 │     2  one
  11 │     2  row?
```
"""

const docstring_unnest_regex =
"""
    @unnest_regex(df, output_col, input_col, pattern="\\s+", to_lower=false)

Splits the text in `input_col` of `df` based on a regex `pattern`, outputting the result to `output_col`.

# Arguments
- `df`: The input DataFrame.
- `output_col`: The name of the output column to store the result.
- `input_col`: The name of the input column containing text to split.
- `pattern`: The regex pattern to use for splitting text.
- `to_lower`: A boolean indicating whether to convert text to lowercase before splitting.

# Returns
- A new DataFrame with the text split based on the regex pattern.

# Examples
```jldoctest
julia> df = DataFrame(text = ["The quick brown fox jumps.", "One column and the one row?"],
                      doc = [1, 2])

julia> @unnest_regex(df, word, text, "\\s+")
10×2 DataFrame
 Row │ doc    word      
     │ Int64  SubStrin… 
─────┼──────────────────
   1 │     1  The
   2 │     1  quick
   3 │     1  brown
   4 │     1  fox
   5 │     1  jumps.
   6 │     2  One
   7 │     2  column
   8 │     2  and
   9 │     2  the
  10 │     2  one
  11 │     2  row?

julia> @unnest_regex(df, word, text,  "\\s+", to_lower = true)
11×2 DataFrame
 Row │ doc    word      
     │ Int64  SubStrin… 
─────┼──────────────────
   1 │     1  the
   2 │     1  quick
   3 │     1  brown
   4 │     1  fox
   5 │     1  jumps.
   6 │     2  one
   7 │     2  column
   8 │     2  and
   9 │     2  the
  10 │     2  one
  11 │     2  row?
```
"""

const docstring_unnest_ngrams =
"""
    @unnest_ngrams(df, output_col, input_col, n, to_lower=false)

Creates n-grams from the text in `input_col` of `df`, outputting the result to `output_col`.

# Arguments
- `df`: The input DataFrame.
- `output_col`: The name of the output column to store the n-grams.
- `input_col`: The name of the input column containing text.
- `n`: The size of the n-grams.
- `to_lower`: A boolean indicating whether to convert text to lowercase before creating n-grams.

# Returns
- A new DataFrame with the n-grams.

# Examples
```jldoctest
julia> df = DataFrame(
        text = [
        "The quick brown fox jumps.",
        "The sun rises in the east."],  doc = [1, 2]);

julia> @unnest_ngrams(df, term, text, 2)
9×2 DataFrame
 Row │ doc    term        
     │ Int64  String      
─────┼────────────────────
   1 │     1  The quick
   2 │     1  quick brown
   3 │     1  brown fox
   4 │     1  fox jumps
   5 │     2  The sun
   6 │     2  sun rises
   7 │     2  rises in
   8 │     2  in the
   9 │     2  the east

julia> @unnest_ngrams(df, term, text, 2, to_lower = true)
9×2 DataFrame
 Row │ doc    term        
     │ Int64  String      
─────┼────────────────────
   1 │     1  the quick
   2 │     1  quick brown
   3 │     1  brown fox
   4 │     1  fox jumps
   5 │     2  the sun
   6 │     2  sun rises
   7 │     2  rises in
   8 │     2  in the
   9 │     2  the east   
```
"""

const docstring_unnest_character_shingles = 
"""
    @unnest_character_shingles(df, output_col, input_col, n, to_lower=false, strip_non_alphanum = false)

Creates character shingles of size `n` from the text in `input_col` of `df`, outputting the result to `output_col`.

# Arguments
- `df`: The input DataFrame.
- `output_col`: The name of the output column to store the character shingles.
- `input_col`: The name of the input column containing text.
- `n`: The size of the character shingles.
- `to_lower`: A boolean (defaults false) indicating whether to convert text to lowercase before creating character shingles.
- `strip_non_alphanum`: Optional boolean, defualts to false that strips non alphanumeric characters

# Returns
- A new DataFrame with the character shingles.

# Examples
```jldoctest
julia>   df = DataFrame(
        text = [
        "The fox runs.",
        "The sun rises."],  doc = [1, 2]);
        
julia>  @unnest_character_shingles(df, term, text, 10, to_lower = false, strip_non_alphanum = true)
7×2 DataFrame
 Row │ doc    term     
     │ Int64  String   
─────┼─────────────────
   1 │     1  Thefoxru
   2 │     1  hefoxrun
   3 │     1  efoxruns
   4 │     2  Thesunri
   5 │     2  hesunris
   6 │     2  esunrise
   7 │     2  sunrises

julia>  @unnest_character_shingles(df, term, text, 10, to_lower = true, strip_non_alphanum = false)
9×2 DataFrame
 Row │ doc    term      
     │ Int64  String    
─────┼──────────────────
   1 │     1  thefoxru
   2 │     1  hefoxrun
   3 │     1  efoxruns
   4 │     1  foxruns.
   5 │     2  thesunri
   6 │     2  hesunris
   7 │     2  esunrise
   8 │     2  sunrises
   9 │     2  sunrises.
```
"""

const docstring_unnest_characters = 
"""
    @unnest_characters(df, output_col, input_col, to_lower=false, strip_non_alphanum = false)

Splits the text in `input_col` of `df` into separate characters, outputting the result to `output_col`.

# Arguments
- `df`: The input DataFrame.
- `output_col`: The name of the output column to store the characters.
- `input_col`: The name of the input column containing text.
- `to_lower`: A boolean indicating whether to convert text to lowercase before splitting.
- `strip_non_alphanum`: Optional boolean, defualts to false that strips non alphanumeric characters

# Returns
- A new DataFrame with the text split into characters.

# Examples
```jldoctest
julia>  julia>  df = DataFrame(
        text = [
        "The quick.",
        "Nice."],  doc = [1, 2]);

julia>  @unnest_characters(df, term, text, to_lower = false)
 Row │ doc    term 
     │ Int64  Char 
─────┼─────────────
   1 │     1  T
   2 │     1  h
   3 │     1  e
   4 │     1
   5 │     1  q
   6 │     1  u
   7 │     1  i
   8 │     1  c
   9 │     1  k
  10 │     1  .
  11 │     2  N
  12 │     2  i
  13 │     2  c
  14 │     2  e
  15 │     2  .


julia> @unnest_characters(df, term, text, to_lower = true, strip_non_alphanum = true)
13×2 DataFrame
 Row │ doc    term 
     │ Int64  Char 
─────┼─────────────
   1 │     1  t
   2 │     1  h
   3 │     1  e
   4 │     1
   5 │     1  q
   6 │     1  u
   7 │     1  i
   8 │     1  c
   9 │     1  k
  10 │     2  n
  11 │     2  i
  12 │     2  c
  13 │     2  e
```
"""