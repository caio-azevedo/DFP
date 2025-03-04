# Função para processar e imprimir cada tabela
tabelas_BP <- function(table, index) {
  tab_x <- xtable(table)
  file_name <- glue("Tabelas/BP_tabela{index}.tex")
  print(tab_x, file = file_name, compress = FALSE, include.rownames = FALSE)
}

