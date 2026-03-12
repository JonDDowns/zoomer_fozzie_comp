library(fozziejoin)

# Load helper functions and common parameters
source("helpers.R")
config <- load_config()
n <- max(config$SAMPLE_SIZES)

# Load dime data
dimedat <- load_dime()

data <- fozzie_string_join(
    dimedat[1:n, ],
    dimedat[1:n, ],
    method = "jaccard",
    max_dist = config$DIST_THRESH,
    q = config$QGRAM_WIDTH,
    by = 'name',
    nthread = config$NUM_THREADS
)

log_message(sprintf("Fozzie run complete with %s rows returned\n", nrow(data)))
quit("no", 0)
