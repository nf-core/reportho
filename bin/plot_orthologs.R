#!/usr/bin/env Rscript

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

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
text_color_darkmode <- "#DDDDDD"
text_color_lightmode <- "#333333"
bg_color <- "transparent"
font_size <- 16

customize_theme <- function(font_size, text_color, bg_color) {
    theme(legend.position = "right",
        text = element_text(size = font_size, color = text_color),
        axis.text = element_text(size = font_size, color = text_color),
        panel.grid = element_line(color = text_color),
        plot.background = element_rect(color = bg_color, fill = bg_color),
        panel.background = element_rect(color = bg_color, fill = bg_color))
}

theme_dark <- customize_theme(font_size, text_color_darkmode, bg_color)
theme_light <- customize_theme(font_size, text_color_lightmode, bg_color)
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
supports <- ggplot(melted_crosstable, aes(x = method, y = count, fill = score)) +
    geom_bar(stat = "identity", position = "stack") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(title = "Support for predictions", x = "Database", y = "Number of orthologs", fill = "Support") +
    scale_fill_manual(values = c("#59B4C3", "#74E291", "#8F7AC2", "#EFF396", "#FF9A8D"))

supports_dark <- supports + theme_dark

ggsave(paste0(args[2], "_supports_dark.png"), plot = supports_dark, width = 6, height = 10, dpi = 300)

supports_light <- supports + theme_light

ggsave(paste0(args[2], "_supports_light.png"), plot = supports_light, width = 6, height = 10, dpi = 300)

# Make a Venn diagram
venn.data <- list()
for (i in colnames(data)[4:ncol(data)-1]) {
    hits <- (data %>% filter(data[, i] == 1) %>% select(id))$id
    venn.data[[i]] <- hits
}

venn_plot_dark <- ggVennDiagram(venn.data, set_color = text_color_darkmode) +
    theme_dark +
    theme(panel.grid = element_blank(), axis.text = element_text(color = "transparent"), legend.position = "none")

ggsave(paste0(args[2], "_venn_dark.png"), plot = venn_plot_dark, width = 6, height = 6, dpi = 300)

venn_plot_light <- ggVennDiagram(venn.data, set_color = text_color_lightmode) +
    theme_light +
    theme(panel.grid = element_blank(), axis.text = element_text(color = "transparent"), legend.position = "none")

ggsave(paste0(args[2], "_venn_light.png"), plot = venn_plot_light, width = 6, height = 6, dpi = 300)

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

jaccard_plot <- ggplot(jaccard, aes(x = method1, y = method2, fill = jaccard)) +
    geom_tile() +
    geom_text(aes(label = round(jaccard, 2)), size=5) +
    scale_fill_gradient(low = "#59B4C3", high = "#EFF396") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(x = "", y = "", fill = "Jaccard Index")

jaccard_plot_dark <- jaccard_plot + theme_dark

ggsave(paste0(args[2], "_jaccard_dark.png"), plot = jaccard_plot_dark, width = 6, height = 6, dpi = 300)

jaccard_plot_light <- jaccard_plot + theme_light

ggsave(paste0(args[2], "_jaccard_light.png"), plot = jaccard_plot_light, width = 6, height = 6, dpi = 300)
