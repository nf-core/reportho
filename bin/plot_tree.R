#!/usr/bin/env Rscript

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

library(treeio)
library(ggtree)
library(ggplot2)

fgcolor_dark <- "#dddddd"
fgcolor_light <- "#333333"
bgcolor <- "transparent"

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 3) {
    print("Usage: Rscript plot_tree.R <treefile> <prefix> <method>")
    quit(status = 1)
}

tree <- read.tree(args[1])

p_dark <- ggtree(tree, color = fgcolor_dark) +
    geom_tiplab(color = fgcolor_dark) +
    theme_tree() +
    theme(panel.background = element_rect(color = bgcolor, fill = bgcolor), plot.background = element_rect(color = bgcolor, fill = bgcolor))

ggsave(paste0(args[2], "_", args[3], "_tree_dark.png"), dpi = 300, height = 16, width = 8)

p_light <- ggtree(tree, color = fgcolor_light) +
    geom_tiplab(color = fgcolor_light) +
    theme_tree() +
    theme(panel.background = element_rect(color = bgcolor, fill = bgcolor), plot.background = element_rect(color = bgcolor, fill = bgcolor))

ggsave(paste0(args[2], "_", args[3], "_tree_light.png"), dpi = 300, height = 16, width = 8)
