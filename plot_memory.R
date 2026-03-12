library(ggplot2)
source("helpers.R")
config <- load_config()

# Initialize an empty list to store data frames
data_list <- list()

# Loop through each file
files <- c('zoomer_memory.txt', 'fozzie_memory.txt')
for (file in files) {
  infn <- file.path('results', file)
  cols <- c('TIME', 'AMPM', 'UID', 'PID', 'minflts', 'majflts', 'VSZ', 'RSS', 'PCTMEM', 'COMMAND')

  # Read the data
  dat <- read.table(file=infn, skip=1, header=FALSE, fill=TRUE)
  colnames(dat) <- cols

  # Filter for 'R' commands, make other columns
  dat <- dat[dat$COMMAND == 'R', ]
  dat$package <- gsub("_.*", "", file)
  row.names(dat) <- NULL
  dat$obs <- as.numeric(row.names(dat))
  dat$RSS <- as.numeric(dat$RSS) / 1024^2
  dat$VSZ <- as.numeric(dat$RSS) / 1024^2

  # Store the filtered data in the list
  data_list[[file]] <- dat
}

# Combine all data frames into one
combined_data <- do.call(rbind, data_list)
row.names(combined_data) <- NULL

n <- max(config$SAMPLE_SIZE)

# Plotting RSS vs Timestamp
title <- sprintf("Memory Utilization by Second, fozziejoin and zoomerjoin (n=%d)", n)
plt <- ggplot(combined_data, aes(x=obs, y=RSS, group=package, color=package)) +
  geom_point() + 
  geom_line() + 
  labs(title=title, x="Seconds since script call", y="Resident Set Size (GB)") +
  theme_minimal()
ggsave("results/memory_plot.png", plt)
