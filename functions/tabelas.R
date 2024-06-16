# Função para processar e imprimir cada tabela
tabelas_BPA <- function(table, index) {
  tab_x <- xtable(table)
  file_name <- glue("Tabelas/BPA_tabela{index}.tex")
  print(tab_x, file = file_name, compress = FALSE, include.rownames = FALSE)
}

tabelas_BPP <- function(table, index) {
  tab_x <- xtable(table)
  file_name <- glue("Tabelas/BPP_tabela{index}.tex")
  print(tab_x, file = file_name, compress = FALSE, include.rownames = FALSE)
}
