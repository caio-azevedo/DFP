# Tema gráfico ------------------------------------------------------------
fonte <- "Times New Roman"

extrafont::loadfonts()
tema <- ggthemes::theme_hc() +
  theme(axis.title = element_text(
    family = fonte,
    face = "bold",
    size = 26
  ),
  axis.text = element_text(
    family = fonte,
    size = 20
  ),
  plot.caption = element_text(
    family = fonte,
    face = "bold",
    size = 20,
    hjust = 1
  ),
  legend.text = element_text(
    family = fonte,
    face = "bold",
    size = 20
  ),
  legend.title = element_text(
    family = fonte,
    size = 20 ))
