read_dados <- function(bp) {
  file_path <- sprintf("data/dfp_corrigido_%s_con_2022.xlsx",
                       bp)

  dados <- read.xlsx(file_path)
  # Retorna os dados lidos
  return(dados)
}
