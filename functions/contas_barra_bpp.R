contas_barra_bpp <- function(ram){
  contas_ord <- df_graf |>
    filter(ramificacao==ram) |>
    arrange(desc(nomenclatura)) |>
    slice_head(n=10) |>
    pull(Cod)

  for (i in c(1:10)) {
    contas_barra_2(contas_ord[i])
    purrr::walk(contas_ord[i],
                ~ ggsave(filename = ifelse(ram==4,glue('Figuras/BPP/Quarta/{.x}.png'),
                                           glue('Figuras/BPP/Quinta/{.x}.png')),
                         dpi = 200,
                         width = 16, height = 10))
  }
}
