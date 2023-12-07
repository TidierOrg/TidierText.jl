# TidierText.jl

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/TidierOrg/TidierData.jl/blob/main/LICENSE)
[![Build Status](https://github.com/TidierOrg/TidierText.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/TidierOrg/TidierText.jl/actions/workflows/CI.yml?query=branch%3Amain)

<img src="https://raw.githubusercontent.com/TidierOrg/TidierText.jl/main/docs/src/assets/TidierText_logo.png" align="right" style="padding-left:10px;" width="150"/>

## What is TidierText.jl

TidierText.jl is a 100% Julia implementation of the R tidytext package. The purpose of the package is to make it easy analyze text data using DataFrames.

An extensive guide to tidy text analysis by Julia Silge and David Robinson is available here: [https://www.tidytextmining.com/](https://www.tidytextmining.com).

## Installation

For the development version:

```julia
using Pkg
Pkg.add(url="https://github.com/TidierOrg/TidierText.jl")
```

## What functions does TidierText.jl support?

- `@bind_tf_idf()`
- `@unnest_tokens()`
- `@unnest_regex()`
- `@unnest_characters()`
- `@unnest_ngrams()`
- `get_stopwords()`
- `tidy()`
- `nma_words`

## How does the package work?

### Let's load the package and read in the UCLA Fall 2018 course dataset.

```julia
using TidierData
using TidierText

using CSV

courses = CSV.read(download("https://vincentarelbundock.github.io/Rdatasets/csv/openintro/ucla_f18.csv"), DataFrame)
```

### What are the course names?

```julia
@chain courses begin
  @select(id = rownames, course)
  @slice(1:10)
end
```

```
10×2 DataFrame
 Row │ id     course                            
     │ Int64  String                            
─────┼──────────────────────────────────────────
   1 │     1  Leadership Laboratory
   2 │     2  Heritage and Values
   3 │     3  Team and Leadership Fundamentals
   4 │     4  Air Force Leadership Studies
   5 │     5  National Security Affairs/Prepar…
   6 │     6  Introduction to Black Studies
   7 │     7  African American Musical Heritage
   8 │     8  UCLA Centennial Initiative: Arth…
   9 │     9  UCLA Centennial Initiative: Soci…
  10 │    10  Student Research Program
```

### Let's tokenize the course names and convert them to lowercase.

```julia
tokens = @chain courses begin
  @select(id = rownames, course)
  @slice(1:10)
  @unnest_tokens(word, course, to_lower = true)
end;

@chain tokens @slice(1:10)
```

```
10×2 DataFrame
 Row │ id     word         
     │ Int64  SubStrin…    
─────┼─────────────────────
   1 │     1  leadership
   2 │     1  laboratory
   3 │     2  heritage
   4 │     2  and
   5 │     2  values
   6 │     3  team
   7 │     3  and
   8 │     3  leadership
   9 │     3  fundamentals
  10 │     4  air
```

### Let's add the term frequency, inverse document frequency, and the tf-idf.

```julia
@chain tokens begin
  @count(id, word)
  @bind_tf_idf(word, id, n)
  @slice(1:10)
end
```

```
10×6 DataFrame
 Row │ id     word          n      tf        idf       tf_idf   
     │ Int64  SubStrin…     Int64  Float64   Float64   Float64  
─────┼──────────────────────────────────────────────────────────
   1 │     1  leadership        1  0.5       1.20397   0.601986
   2 │     1  laboratory        1  0.5       2.30259   1.15129
   3 │     2  heritage          1  0.333333  1.60944   0.536479
   4 │     2  and               1  0.333333  0.916291  0.30543
   5 │     2  values            1  0.333333  2.30259   0.767528
   6 │     3  team              1  0.25      2.30259   0.575646
   7 │     3  and               1  0.25      0.916291  0.229073
   8 │     3  leadership        1  0.25      1.20397   0.300993
   9 │     3  fundamentals      1  0.25      2.30259   0.575646
  10 │     4  air               1  0.25      2.30259   0.575646
```
