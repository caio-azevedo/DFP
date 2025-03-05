# Gráficos ----------------------------------------------------------------
df_graf <- df[[2]]

# 5 ramificações ----------------------------------------------------------

graf1 <- df_graf |>
  filter(ramificacao==5) |>
  arrange(desc(nomenclatura)) |>
  slice_head(n=10) |>
  mutate(Cod_fator = forcats::fct_reorder(Cod,
                                          nomenclatura)) |>
  ggplot() +
  aes(x = nomenclatura, y = Cod_fator) +
  geom_col(fill = "#4C9900",,
           color = "black",
           show.legend = FALSE) +
  scale_x_continuous(breaks = seq(0,270,30), limits = c(0,270)) +
  ggthemes::scale_color_hc() +
  labs(title = "Quinto Nível",
       x = "Quantidade de terminologias utilizadas",
       y = "Código da conta") +
  geom_label(aes(label = nomenclatura), size=10) + tema


# 4 ramificações ----------------------------------------------------------

graf2 <- df_graf |>
  filter(ramificacao==4) |>
  arrange(desc(nomenclatura)) |>
  slice_head(n=10) |>
  mutate(Cod_fator = forcats::fct_reorder(Cod,
                                          nomenclatura)) |>
  ggplot() +
  aes(x = nomenclatura, y = Cod_fator) +
  geom_col(fill = "#4C9900",
           color = "black",
           show.legend = FALSE) +
  scale_x_continuous(breaks=seq(0,135,15), limits = c(0,135)) +
  ggthemes::scale_color_hc() +
  labs(title = "Quarto Nível",
       x = "Quantidade de terminologias utilizadas",
       y = "Código da conta") +
  geom_label(aes(label = nomenclatura), size= 10) + tema

# Boxplot -----------------------------------------------------------------

graf3 <- df_graf |>
  filter(ramificacao > 1) |>
  ggplot()+
  aes(x = nomenclatura , y = ramificacao) +
  geom_boxplot(outlier.size = 3) +
  scale_x_continuous(breaks=seq(0,270,30)) +
  ggthemes::scale_color_economist() +
  labs(x = "Qtde de terminologias utilizadas",
       y = "Nível") + tema


graf4 <- df_graf |>
  filter(ramificacao > 1, empresas > 47) |>
  ggplot()+
  aes(x = nomenclatura , y = ramificacao) +
  geom_boxplot(outlier.size = 3) +
  scale_x_continuous(breaks=seq(0,270,30)) +
  ggthemes::scale_color_hc() +
  labs(x = "Qtde de terminologias utilizadas",
       y = "Nível") + tema


graf5 <- df_graf |>
  filter(ramificacao > 1) |>
  ggplot()+
  aes(x = nomenclatura, y = empresas,
      color = ramificacao)+
  geom_point(size=5) +
  scale_x_continuous(breaks=seq(0,270,30)) +
  ggthemes::scale_color_hc() +
  tema +
  labs(x = "Qtde de terminologias utilizadas",
       y = "Qtde de empresas")

fig3 <- df_graf |>
  filter(ramificacao > 3) |>
  ggplot()+
  aes(x = nomenclatura, y = empresas)+
  geom_point(size=6, colour = "#4C9900") + facet_wrap(~ ramificacao, nrow = 2) +
  scale_x_continuous(breaks=seq(0,270,30)) +
  ggthemes::scale_color_hc() +
  tema + theme(strip.text = element_text(size = 30,
                                         family = "Verdana",
                                         face = "bold",
                                         color = "white"),
               strip.background = element_rect(
                 fill = "#4C9900"
               )) +
  labs(x = "Qtde de terminologias utilizadas",
       y = "Qtde de empresas") +guides(color = "none") +
  scale_color_canva()
# Patchwork ---------------------------------------------------------------

fig1 <- graf2 + graf1  + plot_layout(axis_titles  = "collect") & tema


graf6 <- graf3 + graf4 + plot_layout(ncol = 2,
                                     axis_titles  = "collect") & tema

fig2 <- graf6 / graf5 + plot_annotation(
  tag_levels = "I",tag_suffix = ")") +
  plot_layout(nrow = 2, axis_titles  = "collect") &
  tema

# Salvando os gráficos ----------------------------------------------------

lista_g <- list()
lista_fig <- list(fig1,fig2,fig3)

for (i in 1:3) {
  nome <- paste0("BPP_fig", i)
  lista_g <- c(lista_g, nome)
}

purrr::walk2(lista_fig, lista_g,
             ~ ggsave(plot = .x,
                      filename = glue('Figuras/BPP/{.y}.png'),
                      dpi = 500,
                      width = 16, height = 10))

# Gráficos das contas -----------------------------------------------------

for (i in c(4,5)) {
  contas_barra_bpp(i)
}
