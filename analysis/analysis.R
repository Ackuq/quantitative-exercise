# Imports
library(data.table)
library(matrixStats)
# Read data files
js_data <- read.csv(file = "data-generation/javascript-data.csv")

# Find list size to execution time median rows.
time_func <- function(n, k1, k2, c) {
  n * log10(n) * k1 + n * k2 + c
}

# Generate graph for the specified data
create_graphs <- function(data, output_file) {
  x <- data[, 1]
  y <- data[, 2]
  jpeg(file = stringr::str_interp("out/${output_file}-plot.jpeg"))
  plot(x, y,
    xlab = "User list size", ylab = "Execution time (ms)"
  )
  curve(time_func(x, 1, 1, 0), add = TRUE)
  fit <- nls(y ~ time_func(x, k1, k2, c), start = list(k1 = 1, k2 = 1, c = 0))
  dev.off()
  print(fit)
}

# Generate a speedup plot, using Y1/Y2
create_speedup_plot <- function(x, y1, y2) {
  y <- y1 / y2
  reg1 <- lm(y ~ x)
  jpeg(file = "out/speedup-plot.jpeg")
  plot(x, y,
    xlab = "User list size", ylab = "Speedup"
  )
  abline(reg1)
  print(reg1)
  dev.off()
}

# From a file input, generate parsed output
get_data <- function(file) {
  file_data <- read.csv(
    file = file
  )

  y_data <- as.matrix(file_data[, -1])
  x_data <- file_data[, 1]

  medians <- data.frame(
    ID = x_data,
    Medians = rowMedians(y_data)
  )

  return(list(
    "y" = y_data,
    "x" = x_data,
    "median" = medians
  ))
}


js_data <- get_data(file = "data-generation/javascript-data.csv")

wasm_data <- get_data(file = "data-generation/webasm-data.csv")

create_graphs(
  data = js_data$median, output_file = "js"
)

create_graphs(
  data = wasm_data$median, output_file = "wasm"
)

create_speedup_plot(
  x = wasm_median[, 1],
  y1 = js_median[, 2],
  y2 = wasm_median[, 2]
)

confidence_interval <- function(data, file_name) {
  # Standard deviations
  sds <- matrixStats::rowSds(data$y)
  # Means of each row
  means <- rowMeans(data$y)
  # Number of columns (population size)
  columns <- length(data$y) / length(data$x)

  error <- qnorm(0.975) * sds / sqrt(columns)
  error_upper <- means + error
  error_lower <- means - error

  jpeg(file = stringr::str_interp("out/confidence-${file_name}-plot.jpeg"))

  plot(
    data$x,
    error_upper,
    col = "blue",
    type = "l",
    xlab = "User list size",
    ylab = "Execution time (ms)"
  )
  lines(
    data$x,
    error_lower,
    col = "red",
  )
  lines(data$x, means, col = "orange")
  legend(
    x = "topleft",
    legend = c(
      "Mean execution time",
      "Upper confidence value",
      "Lower confidence value"
    ),
    col = c("orange", "blue", "red"),
    lty = 1, cex = 1
  )
  dev.off()
}

confidence_interval(wasm_data, file_name = "wasm")
confidence_interval(js_data, file_name = "js")
