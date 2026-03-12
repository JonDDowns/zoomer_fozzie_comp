# Zoomerjoin and Fuzzyjoin: Performance Tradeoffs

A repo with code examples for some comparative benchmarking between `zoomerjoin`
and `fozziejoin`. Goal is to identify use cases for each.

## Getting Started

### Installing R Dependencies

Requires a functioning Rust toolchain and R version 4.5.

First, clone the repo and make it the working directory:

```sh
git clone https://github.com/JonDDowns/zoomer_fozzie_comp
cd ./zoomer_fozzie_comp
```

Next, use `renv` to restore the workspace.

```r
# install.packages('renv')
library(renv)
renv::restore()
```

Note that a specific commit of `fozziejoin` is being installed from GitHub.
CRAN is not used for this package.

### Download Dime Contributors .Rdata File

https://data.stanford.edu/dime

Place in root folder of project.

### Run Benchmark Script

```sh
Rscript compare_large.R
```

## Findings

Findings are reported from my local machine. Results will vary based on
hardware.

### Jaccard String Joins

In initial testing, `zoomerjoin` was faster for jaccard distances at sufficient
scale (joining two dfs with 100,000 rows). Based on these results, I revisited
the implementation for Jaccard string joins in `fozziejoin` and discovered a
more efficient strategy.

![Benchmark plot for Jaccard String Join](./benchmark_plot_nband_350.png)

#### New Fozziejoin Jaccard Join Strategy

##### Create Nested HashMap Structure for Right-Hand Side

For each item in the right-hand side of the join, we first generate a HashSet
of unique q-grams in the item. Then we sort right-hand values into a HashMap
whose keys are the size of the HashSet and whose values are a reverse q-gram
index.

##### Search Nested HashMap for All Values in Left-Hand Side

For each item in the left-hand side of the join, we generate a HashSet of
q-grams and record its length. Then, we use the length of this set and
the `max_distance` parameter to determine the maximum and minimum lengths
of q-grams in the right-hand side that could potentially match the current
value. Next, we search the nested HashMap to identify any the indices of
any values from the right-hand side that could potentially match the current
query. We construct the Jaccard distance from the size of left-hand q-gram,
the size of the right-hand q-gram, and the number of matches between the
two q-grams. This value is compared to the `max_distance` threshold, and values
at or below this threshold are kept.
