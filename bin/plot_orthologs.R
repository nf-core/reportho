#!/usr/bin/env Rscript

suppressMessages(library(ggplot2))
suppressMessages(library(reshape2))
suppressMessages(library(tidyverse))
suppressMessages(library(ggVennDiagram))

# Command line arguments
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
    print("Usage: Rscript comparison_plots.R <input_file> <output_dir>")
    quit(status = 1)
}

# Styles
text_color <- "#DDDDDD"
bg_color <- "#333333"

# Load the data
data <- read.csv(args[1], header = TRUE, stringsAsFactors = FALSE)

# Melt the data keeping ID and score
melted_data <- melt(data, id.vars = c("ID", "score"), variable.name = "method", value.name = "support") %>%
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
    labs(title = "Support for predictions", x = "Database", y = "Count", fill = "Support") +
    scale_fill_manual(values = c("#59B4C3", "#74E291", "#EFF396")) +
    theme(legend.position = "right",
        text = element_text(size = 12, color = text_color),
        axis.text.x = element_text(color = text_color),
        axis.text.y = element_text(color = text_color),
        plot.background = element_rect(fill = bg_color),
        panel.background = element_rect(fill = bg_color))

ggsave(paste0(args[2], "/supports.png"), plot = p, width = 6, height = 10, dpi = 300)

# Make a Venn diagram
oma.hits <- (data %>% filter(oma == 1) %>% select(ID))$ID
panther.hits <- (data %>% filter(panther == 1) %>% select(ID))$ID
inspector.hits <- (data %>% filter(inspector == 1) %>% select(ID))$ID
venn.data <- list(OMA = oma.hits, Panther = panther.hits, OrthoInspector = inspector.hits)
venn.plot <- ggVennDiagram(venn.data, set_color = text_color) +
    theme(legend.position = "none",
        text = element_text(size = 12, color = text_color),
        plot.background = element_rect(fill = bg_color),
        panel.background = element_rect(fill = bg_color))
ggsave(paste0(args[2], "/venn.png"), plot = venn.plot, width = 6, height = 6, dpi = 300)
