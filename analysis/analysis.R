# Imports
library(data.table);
library(matrixStats);

# Read data files
js_data <- read.csv(file = "data-generation/javascript-data.csv");
# Find list size to execution time median rows.
time_func <- function(n, k1, k2) {
  n * log10(n) * k1 + n * k2
};
js_data_refined <- data.frame(ID = js_data[, 1],
Medians = rowMedians(as.matrix(js_data[, -1])));
x <- js_data_refined[, 1];
y <- js_data_refined[, 2];
jpeg(file = "out/js-plot.jpeg")
plot(x, y,
xlab = "User list size", ylab = "Execution time (s)");
curve(time_func(x, 1, 1), add = TRUE);
fit <- nls(y~time_func(x, k1, k2), start = list(k1 = 1, k2 = 2))
dev.off();
print(fit)


wasm_data <- read.csv(file = "data-generation/webasm-data.csv");
wasm_data_refined <- data.frame(ID = wasm_data[, 1],
Medians = rowMedians(as.matrix(wasm_data[, -1])));
x <- wasm_data_refined[, 1];
y <- wasm_data_refined[, 2];
jpeg(file = "out/wasm-plot.jpeg")
plot(x, y,
xlab = "User list size", ylab = "Execution time (s)");
curve(time_func(x, 1, 1), add = TRUE);
fit <- nls(y~time_func(x, k1, k2), start = list(k1 = 1, k2 = 1))
dev.off();
print(fit)