#!/usr/bin/env Rscript

library(treeio)
library(ggtree)
library(ggplot2)

fgcolor <- "#eeeeee"
bgcolor <- "transparent"

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
    print("Usage: Rscript plot_tree.R <treefile> <prefix>")
    quit(status = 1)
}

tree <- read.tree(args[1])
p <- ggtree(tree, color = fgcolor) + geom_tiplab(color = fgcolor) + theme_tree() + theme(panel.background = element_rect(color = bgcolor, fill = bgcolor), plot.background = element_rect(color = bgcolor, fill = bgcolor))
ggsave(paste0(args[2], "_tree.png"))
