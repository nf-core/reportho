#!/usr/bin/env Rscript

suppressMessages(library(ggplot2))
suppressMessages(library(reshape2))
suppressMessages(library(dplyr))
suppressMessages(library(ggVennDiagram))

# Command line arguments
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
    print("Usage: Rscript comparison_plots.R <input_file> <prefix>")
    quit(status = 1)
}

# Styles
text_color <- "#DDDDDD"
bg_color <- "transparent"
font_size <- 16

# Load the data
data <- read.csv(args[1], header = TRUE, stringsAsFactors = FALSE)

# Melt the data keeping ID and score
melted_data <- melt(data, id.vars = c("id", "id_format", "score"), variable.name = "method", value.name = "support") %>%
    filter(support == 1) %>%
    select(-support)

# make a crosstable
crosstable <- dcast(melted_data, method ~ score)

# melt it
melted_crosstable <- melt(crosstable, id.vars = "method", variable.name = "score", value.name = "count")

# Plot the data
p <- ggplot(melted_crosstable, aes(x = method, y = count, fill = score)) +
    geom_bar(stat = "identity", position = "stack") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(title = "Support for predictions", x = "Database", y = "Number of orthologs", fill = "Support") +
    scale_fill_manual(values = c("#59B4C3", "#74E291", "#8F7AC2", "#EFF396", "#FF9A8D")) +
    theme(legend.position = "right",
        text = element_text(size = font_size, color = text_color),
        axis.text.x = element_text(size = font_size, color = text_color),
        axis.text.y = element_text(size = font_size, color = text_color),
        plot.background = element_rect(color = bg_color, fill = bg_color),
        panel.background = element_rect(color = bg_color, fill = bg_color))

ggsave(paste0(args[2], "_supports.png"), plot = p, width = 6, height = 10, dpi = 300)

# Make a Venn diagram
venn.data <- list()
for (i in colnames(data)[4:ncol(data)-1]) {
    hits <- (data %>% filter(data[, i] == 1) %>% select(id))$id
    venn.data[[i]] <- hits
}
venn.plot <- ggVennDiagram(venn.data, set_color = text_color) +
    theme(legend.position = "none",
        text = element_text(size = font_size, color = text_color),
        plot.background = element_rect(color = bg_color, fill = bg_color),
        panel.background = element_rect(color = bg_color, fill = bg_color))
ggsave(paste0(args[2], "_venn.png"), plot = venn.plot, width = 6, height = 6, dpi = 300)

# Make a plot with Jaccard index for each pair of methods
jaccard <- data.frame(method1 = character(), method2 = character(), jaccard = numeric())
for (i in 4:ncol(data)-1) {
    for (j in 4:ncol(data)-1) {
        if (i == j) {
            next
        }
        method1 <- colnames(data)[i]
        method2 <- colnames(data)[j]
        hits1 <- (data %>% filter(data[, i] == 1) %>% select(id))$id
        hits2 <- (data %>% filter(data[, j] == 1) %>% select(id))$id
        jaccard <- rbind(jaccard, data.frame(method1 = method1, method2 = method2, jaccard = length(intersect(hits1, hits2)) / length(union(hits1, hits2))))
    }
}
p <- ggplot(jaccard, aes(x = method1, y = method2, fill = jaccard)) +
    geom_tile() +
    geom_text(aes(label = round(jaccard, 2)), size=5) +
    scale_fill_gradient(low = "#59B4C3", high = "#EFF396") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(title = "Jaccard Index", x = "", y = "", fill = "Jaccard Index") +
    theme(legend.position = "right",
        text = element_text(size = font_size, color = text_color),
        axis.text.x = element_text(size = font_size, color = text_color),
        axis.text.y = element_text(size = font_size, color = text_color),
        plot.background = element_rect(color = bg_color, fill = bg_color),
        panel.background = element_rect(color = bg_color, fill = bg_color))

ggsave(paste0(args[2], "_jaccard.png"), plot = p, width = 6, height = 6, dpi = 300)
