contas_barra2 <- function(ram){
  contas <- df |>
    filter(ramificacao==ram) |>
    arrange(desc(nomenclatura)) |>
    slice_head(n=10) |>
    pull(Cod)

  for (i in c(1:10)) {
    contas_barra(contas[i])
    purrr::walk(contas[i],
                ~ ggsave(filename = glue('Figuras/{.x}.png'),
                         dpi = 500,
                         width = 16, height = 10))
  }
}
