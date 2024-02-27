# Script to generate noised frequency data based on a given MAF freq file.

# Check if MAF freq file path and sample size are provided as command-line arguments.
if (length(commandArgs(trailingOnly = TRUE)) < 2) {
  stop("Please provide the MAF file path and sample size as command-line arguments.")
}

# Get the MAF freq file path and sample size from the command line arguments.
maf_file <- commandArgs(trailingOnly = TRUE)[1]
sample_size <- as.numeric(commandArgs(trailingOnly = TRUE)[2])

setwd("path/to/freq/file")

# Read MAF file 
maf <- read.table(maf_file)
freqs <- as.numeric(unlist(maf[1]))

# Define the logit function for logistic regression.
logit <- function(x) {
  log(x / (1 - x))
}

# Generate noised frequencies with standard deviation 0.5.
noised_freqs <- 1 / (1 + exp(-rnorm(sample_size, mean = logit(freqs), sd = 0.5)))

# Adjust frequencies above 0.5.
to_replace <- which(noised_freqs > 0.5)
noised_freqs[to_replace] <- 1 - noised_freqs[to_replace]

# Write noised frequencies to file with "_noise05" suffix.
output_file <- paste0(gsub("\\.mafs$", "", basename(maf_file)), "_noise05")
write.table(noised_freqs, file = output_file, sep = "\t", row.names = FALSE, quote = FALSE, col.names = FALSE)

# Generate noised frequencies with standard deviation 1.
noised_freqs <- 1 / (1 + exp(-rnorm(sample_size, mean = logit(freqs), sd = 1)))

# Adjust frequencies above 0.5.
to_replace <- which(noised_freqs > 0.5)
noised_freqs[to_replace] <- 1 - noised_freqs[to_replace]

# Write noised frequencies to file with "_noise1" suffix.
output_file <- paste0(gsub("\\.mafs$", "", basename(maf_file)), "_noise1")
write.table(noised_freqs, file = output_file, sep = "\t", row.names = FALSE, quote = FALSE, col.names = FALSE)
