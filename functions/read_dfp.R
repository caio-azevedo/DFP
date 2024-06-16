read_dfp <- function(ano, balanco) {
  download_and_extract_dfp(ano)
  # Constrói o caminho do arquivo com base no ano
  file_path <- sprintf("dfp_cia_aberta_%s/dfp_cia_aberta_%s_con_%s.csv",
                       ano, balanco, ano)

  # Lê o arquivo CSV
  dados <- read.csv(file_path, sep = ";", fileEncoding = "latin1")

  # Retorna os dados lidos
  return(dados)
}


