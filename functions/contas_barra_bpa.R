contas_barra_bpa <- function(ram){
  contas <- df |>
    filter(ramificacao==ram) |>
    arrange(desc(nomenclatura)) |>
    slice_head(n=10) |>
    pull(Cod)

  for (i in c(1:10)) {
    contas_barra(contas[i])
    purrr::walk(contas[i],
                ~ ggsave(filename = ifelse(ram==4,glue('Figuras/BPA/Quarta/{.x}.png'),
                                           glue('Figuras/BPA/Quinta/{.x}.png')),
                         dpi = 200,
                         width = 16, height = 10))
  }
}
