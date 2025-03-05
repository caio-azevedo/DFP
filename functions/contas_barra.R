fonte <- "Times New Roman"

contas_barra_1 <- function(cd){

  text <- dados_bp[[1]] |>
    filter(CD_CONTA==cd) |>
    pull(DS_CONTA)

  nomenclatura <- tolower(text)
  nomenclatura <- stri_trans_general(nomenclatura, "Latin-ASCII")
  base <- data.frame(nomenclatura)


  base <- base|>
    group_by(nomenclatura) |>
    summarise("Freq"=n()) |>
    arrange(desc(Freq)) |>
    slice_head(n=8) |>
    mutate(Cod_fator = forcats::fct_reorder(nomenclatura,
                                            Freq))
  MAX <- max(base$Freq)
  base |>
    ggplot() +
    aes(x = Freq, y = Cod_fator) +
    geom_col(fill = "#076fa2",
             color = "black",
             show.legend = FALSE, width = 0.8)+
    scale_x_continuous(limits = c(0,MAX),
                       expand = c(0, 0),
                       position = "top") +
    scale_y_discrete(expand = expansion(add = c(0, 0.5))) +
    theme(panel.background = element_rect(fill = "white"),
          panel.grid.major.x = element_line(color = "#A8BAC4", size = 0.3),
          axis.ticks.length = unit(0, "mm"),
          axis.title = element_blank(),
          axis.line.y.left = element_line(color = "black"),
          axis.text.y = element_blank(),
          axis.text.x = element_text(family = fonte, size = 25)) +
    geom_shadowtext(data = subset(base, Freq <= 0.4*MAX),
                    aes(Freq, y = Cod_fator, label = Cod_fator),
                    hjust = 0,
                    nudge_x = 0.3,
                    colour = "#076fa2",
                    bg.colour = "white",
                    bg.r = 0.2,
                    family = fonte,
                    size = 12) +
    geom_text(
      data = subset(base, Freq > 0.4*MAX),
      aes(0, y = Cod_fator, label = Cod_fator),
      hjust = 0,
      nudge_x = 0.3,
      colour = "white",
      family = fonte,
      size = 12) +
    theme(
      plot.title = element_text(
        family = fonte,
        face = "bold",
        size = 22
      ),
      plot.subtitle = element_text(
        family = fonte,
        size = 20)) +
    theme(
      plot.margin = margin(0.02, 0.02, 0.05, 0.01, "npc")
    )
}

contas_barra_2 <- function(cd){

  text <- dados_bp[[2]] |>
    filter(CD_CONTA==cd) |>
    pull(DS_CONTA)

  nomenclatura <- tolower(text)
  nomenclatura <- stri_trans_general(nomenclatura, "Latin-ASCII")
  base <- data.frame(nomenclatura)


  base <- base|>
    group_by(nomenclatura) |>
    summarise("Freq"=n()) |>
    arrange(desc(Freq)) |>
    slice_head(n=8) |>
    mutate(Cod_fator = forcats::fct_reorder(nomenclatura,
                                            Freq))
  MAX <- max(base$Freq)
  base |>
    ggplot() +
    aes(x = Freq, y = Cod_fator) +
    geom_col(fill = "#4C9900",
             color = "black",
             show.legend = FALSE, width = 0.8)+
    scale_x_continuous(limits = c(0,MAX),
                       expand = c(0, 0),
                       position = "top") +
    scale_y_discrete(expand = expansion(add = c(0, 0.5))) +
    theme(panel.background = element_rect(fill = "white"),
          panel.grid.major.x = element_line(color = "#A8BAC4", size = 0.3),
          axis.ticks.length = unit(0, "mm"),
          axis.title = element_blank(),
          axis.line.y.left = element_line(color = "black"),
          axis.text.y = element_blank(),
          axis.text.x = element_text(family = fonte, size = 25)) +
    geom_shadowtext(data = subset(base, Freq <= 0.4*MAX),
                    aes(Freq, y = Cod_fator, label = Cod_fator),
                    hjust = 0,
                    nudge_x = 0.3,
                    colour = "#4C9900",
                    bg.colour = "white",
                    bg.r = 0.2,
                    family = fonte,
                    size = 12) +
    geom_text(
      data = subset(base, Freq > 0.4*MAX),
      aes(0, y = Cod_fator, label = Cod_fator),
      hjust = 0,
      nudge_x = 0.3,
      colour = "white",
      family = fonte,
      size = 12) +
    theme(
      plot.title = element_text(
        family = fonte,
        face = "bold",
        size = 22
      ),
      plot.subtitle = element_text(
        family = fonte,
        size = 20)) +
    theme(
      plot.margin = margin(0.02, 0.02, 0.05, 0.01, "npc")
    )
}
