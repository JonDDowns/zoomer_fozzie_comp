library(zoomerjoin)
library(fozziejoin)
library(dplyr)
library(purrr)
library(tidyr)
library(microbenchmark)
library(ggplot2)

# Key parameters for the zoomerjoin function
N_BANDS <- 350
BAND_WIDTH <- 1

# Set up sample sizes
N <- seq(5e4, 1.1e5, 1e4)
names(N) <- N

# Retrieve from https://data.stanford.edu/dime
orig_fn <- './dime_contributors_1979_2024.rdata'
fast_fn <- './dime_contributors.Rds'

# Load times are long
# Let's do most of the preprocessing and save it in an uncompressed file
if(!file.exists(fast_fn)) {
    print("No fast file...creating")
    load(orig_fn)
    keep_cols <- c('bonica.cid', 'most.recent.contributor.name')
    out <- na.omit(contribs[, keep_cols])

    set.seed(42)
    samp_idx <- sample(nrow(contribs), 1e6)
    dimedat <- out[samp_idx, ]

    saveRDS(dimedat, fast_fn, compress=FALSE)
} else {
    print("Loading fast file")
    dimedat <- readRDS(fast_fn)
}

names(dimedat) <- c("id_1", "name")

# Get time and memory use statistics for fozziejoin when performing jaccard join
fozzie_jaccard_bench <- function(n) {
  time <- microbenchmark(
    data <- fozzie_string_join(dimedat[1:n, ],
      dimedat[1:n, ],
      method = "jaccard",
      max_dist = .6,
      q = 4,
      by='name'
    ),
    times = 5
  )$time %>%
    median()

  return(list('time' = time, 'nrows' = nrow(data)))
}

print("Running fozzie")
fozzie_jacard_benches <- purrr::map_df(N, fozzie_jaccard_bench, .id = "n")
fozzie_jacard_benches$package <- "fozziejoin"

# Get time and memory use statistics for zoomerjoin when performing jaccard join
zoomer_jaccard_bench <- function(n) {
  time <- microbenchmark(
    data <- jaccard_inner_join(dimedat[1:n, ], dimedat[1:n, ],
      by = "name", band_width = BAND_WIDTH,
      n_bands = N_BANDS, threshold = .7,
      n_gram_width = 4
    ),
    times = 5
  )$time %>%
    median()

  return(list('time' = time, 'nrows' = nrow(data)))
}

print("Running zoomer")
zoomer_jacard_benches <- purrr::map_df(N, zoomer_jaccard_bench, .id = "n")
zoomer_jacard_benches$package <- "zoomerjoin"

# Combine and pivot
jaccard_benches <- bind_rows(fozzie_jacard_benches, zoomer_jacard_benches)

bench_csv_fn <- sprintf("jaccard_benches_nband_%s_bandwidth_%s.csv", N_BANDS, BAND_WIDTH)
print(sprintf("Writing bench results to %s", bench_csv_fn))
write.csv(jaccard_benches, bench_csv_fn)

sim_data <- jaccard_benches %>%
  pivot_longer(-c('package', 'n')) %>%
  mutate(value = ifelse(name == 'time', value / 10^9, value))

print("Making chart")
ggplot(sim_data, aes(x = as.numeric(n), y = value, color = package)) +
  geom_line(aes(group = package)) + 
  geom_point() +
  labs(title = "Performance Comparison by Join Type",
       x = "n (Sample Size)",
       y = "Value") +
  theme(legend.position = "bottom") +
  facet_wrap(name ~ ., scale='free')

plot_name <- sprintf('benchmark_plot_nband_%s_bandwidth_%s.png', N_BANDS, BAND_WIDTH)
print(sprintf("Saving plot at %s", plot_name))
ggsave(plot_name, width=11, height=8)

