library(admixtools)
library(ape)
library(tidyverse)

setwd("your_directory")
# ── Compute f2 statistics ──────────────────────────────────────────────────────
#here you add the prefix of how you plink data is called and the directory where you will include all the f2 calculations
prefix <- "data4tree_pruned"
my_f2_dir <- "f2_pops/"

read_table2 <- readr::read_table

# Extract f2 (only need to run once)
extract_f2(prefix, my_f2_dir, maxmiss=0.1)

# Load f2 blocks
f2_blocks <- f2_from_precomp(my_f2_dir)

# ── Compute pairwise F3 outgroup statistics ────────────────────────────────────
# F3(Yoruba; popA, popB) 
# We need an outgroup - options:

pop1 <- "Yoruba"
pop2 <- pops[pops != pop1]

f3 <- qp3pop(f2_blocks, pop1, pop2, pop2)

# ── Build distance matrix ─────────────────────────────────────────────────────
f3_map <- f3 %>%
  select(pop2, pop3, est) %>%
  pivot_wider(names_from=pop3, values_from=est) %>%
  column_to_rownames("pop2") %>%
  as.matrix()

dist_matrix <- 1 / abs(f3_map)
diag(dist_matrix) <- 0
dist_matrix[is.na(dist_matrix)] <- max(dist_matrix, na.rm=TRUE)
d_mat <- as.dist(dist_matrix)

# ── Build NJ tree ─────────────────────────────────────────────────────────────
#Here you select which population you wan to use as Outgroup to root the tree. It cannot be Yoruba!
tree_nj     <- nj(d_mat)
tree_rooted <- root(tree_nj, outgroup="IBS", resolve.root=TRUE)
write.tree(tree_rooted, file="nj_f3_tree.nwk")



# ── Population metadata ───────────────────────────────────────────────────────
#This is just to make the tree look cute and having colors by the different lineages
pop_meta <- tibble(
  label = pop_order,
  region = c(
    # Mexico
    rep("Mexico", 20),
    # Caribbean Colombia
    rep("Caribbean Colombia", 4),
    # Amazonia
    rep("Amazonia", 3),
    # Andes
    rep("Andes", 3),
    # Southern Cone
    rep("Southern Cone", 2)
  )
)

# Region colors
region_colors <- c(
  "Mexico"               = "#1565C0",
  "Caribbean Colombia"   = "#6A1B9A",
  "Amazonia"             = "#2E7D32",
  "Andes"                = "#E65100",
  "Southern Cone"        = "#B71C1C"
)

# ── Plot clean (no branch lengths) ───────────────────────────────────────────

library(ggtree)
p_clean <- ggtree(tree_rooted,
                  layout        = "rectangular",
                  branch.length = "none",
                  size          = 0.6,
                  color         = "grey40") %<+% pop_meta +
  
  geom_tippoint(aes(color=region), size=3, alpha=0.9) +
  
  geom_tiplab(aes(color=region),
              size        = 3,
              fontface    = "bold",
              offset      = 0.3,
              show.legend = FALSE) +
  
  scale_color_manual(
    values = region_colors,
    name   = "Region",
    guide  = guide_legend(
      override.aes = list(shape=16, size=4, linetype=0, label="")
    )
  ) +
  
  labs(title="Neighbor-joining tree based on outgroup F3 statistics") +
  
  theme_tree2() +
  theme(
    plot.title      = element_text(face="bold", size=13, hjust=0.5),
    legend.position = "right",
    legend.text     = element_text(size=10),
    plot.background = element_rect(fill="white", color=NA),
    plot.margin     = margin(t=10, r=150, b=10, l=10),
    axis.text.x     = element_blank(),
    axis.line.x     = element_blank()
  ) +
  xlim(0, 45)

ggsave("nj_tree_clean.pdf",   p_clean, width=14, height=10)
ggsave("nj_tree_clean.png",   p_clean, width=14, height=10, dpi=300)

# ── Plot with branch lengths ──────────────────────────────────────────────────
p_lengths <- ggtree(tree_rooted,
                    layout = "rectangular",
                    size   = 0.6,
                    color  = "grey40") %<+% pop_meta +
  
  geom_tippoint(aes(color=region), size=3, alpha=0.9) +
  
  geom_tiplab(aes(color=region),
              size        = 3,
              fontface    = "bold",
              offset      = 0.3,
              show.legend = FALSE) +
  
  geom_treescale(x=0, y=1, color="grey40", offset=0.8) +
  
  scale_color_manual(
    values = region_colors,
    name   = "Region",
    guide  = guide_legend(
      override.aes = list(shape=16, size=4, linetype=0, label="")
    )
  ) +
  
  labs(title="Neighbor-joining tree based on outgroup F3 statistics") +
  
  theme_tree2() +
  theme(
    plot.title      = element_text(face="bold", size=13, hjust=0.5),
    legend.position = "right",
    legend.text     = element_text(size=10),
    plot.background = element_rect(fill="white", color=NA),
    plot.margin     = margin(t=10, r=150, b=10, l=10)
  ) +
  xlim(0, max(tree_rooted$edge.length) * 2.5)

ggsave("nj_tree_lengths.pdf", p_lengths, width=14, height=10)
ggsave("nj_tree_lengths.png", p_lengths, width=14, height=10, dpi=300)

print(p_clean)
