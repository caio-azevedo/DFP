download_and_extract_dfp <- function(year) {
  unzip_dir <- sprintf("dfp_cia_aberta_%s", year)

  # Cria a pasta se ela não existir
  if (!dir.exists(unzip_dir)) {
    dir.create(unzip_dir)

  # Define o URL do arquivo com base no ano
  url <- sprintf("https://dados.cvm.gov.br/dados/CIA_ABERTA/DOC/DFP/DADOS/dfp_cia_aberta_%s.zip", year)

  # Define o caminho local onde o arquivo será salvo
  destfile <- sprintf("dfp_cia_aberta_%s.zip", year)

  # Usa a função download.file para baixar o arquivo
  download.file(url, destfile)

  # Descompacta o arquivo na pasta especificada
  unzip(destfile, exdir = unzip_dir)

  # O arquivo ZIP pode ser removido após a descompactação
  file.remove(destfile)
  }
  }

