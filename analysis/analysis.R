library(data.table);
library(matrixStats);
js_data <- read.csv(file = "data-generation/javascript-data.csv");
data <- data.frame(ID = js_data[, 1],
Medians = rowMedians(as.matrix(js_data[, -1])));
jpeg(file = "out/plot.jpeg")
plot(data[, 1], data[, 2],
xlab = "User list size", ylab = "Execution time (s)");
dev.off();
print(data);