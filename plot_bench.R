library(dplyr)
library(purrr)
library(tidyr)
library(ggplot2)

source("helpers.R")
config <- load_config()

cols <- c('n', 'Time (seconds)', 'Returned Rows (millions)', 'package')
jaccard_benches <- read.csv(config$BENCH_CSV_FN, header=TRUE)
colnames(jaccard_benches) <- cols

sim_data <- jaccard_benches %>%
    pivot_longer(-c('package', 'n'))

log_message("Making chart")
plot <- ggplot(sim_data, aes(x = as.numeric(n)^2 / 1e9, y = value, color = package, linetype = package)) +
    geom_line(aes(group = package)) + 
    geom_point() +
    labs(title = "Performance Comparison by Join Type",
         x = "Total Possible Comparisons (billions)",
         y = "Value") +
    theme_minimal() + 
    theme(legend.position = "bottom") +
    facet_wrap(name ~ ., scale='free') + 
    scale_linetype_manual(values = c("solid", "dashed", "dotted"))

log_message(sprintf("Saving plot at %s", config$PLOT_NAME))
ggsave(config$PLOT_NAME, plot=plot, width=11, height=8)
