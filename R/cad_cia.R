url <- "https://dados.cvm.gov.br/dados/CIA_ABERTA/CAD/DADOS/cad_cia_aberta.csv"
cad_cia_aberta <- read.csv(url, sep = ";",
                                    fileEncoding = "latin1")

cad_cia_aberta <- cad_cia_aberta |>
  select(3,10:11,47)

url <- "https://dados.cvm.gov.br/dados/CIA_ESTRANG/CAD/DADOS/cad_cia_estrang.csv"
cad_cia_estrang <- read.csv(url, sep = ";",
                                     fileEncoding = "latin1")

cad_cia_estrang <- cad_cia_estrang |>
  select(3,11:12,49)

cad_cia <- bind_rows(cad_cia_aberta,cad_cia_estrang)

cad_cia <- distinct(cad_cia)



