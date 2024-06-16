# Pacotes -----------------------------------------------------------------

library(tidyverse)
library(openxlsx)
library(moments)


# Limpando ----------------------------------------------------------------

rm(list=ls())


# list functions ----------------------------------------------------------
my_R_files <- list.files(path ="functions", pattern = '*.R',
                         full.names = TRUE)

# Load all functions in R  ------------------------------------------------
sapply(my_R_files, source)



# Tipo de balanço ---------------------------------------------------------

bp <- c("BPA","BPP")

# Sumário de contas por empresas ------------------------------------------

dados <- read_dfp(2022, "BPP")

source("R/cad_cia.R")


# Resolvendo o problema da empresa TC.SA ----------------------------------

dados <- dados |>
  filter(ORDEM_EXERC=="ÚLTIMO")



# Adicionado os setores ---------------------------------------------------

cad_cia <- semi_join(cad_cia,dados,by=c("CD_CVM"))

dados <- inner_join(dados,cad_cia)

# Listar todos os objetos no ambiente que começam com "cad" ---------------

objetos_cad <- ls(pattern = "^cad")


# Remover esses objetos ---------------------------------------------------

rm(list = objetos_cad, objetos_cad)


# Criando a base somente de bancos ----------------------------------------

bancos <- dados |>
  filter(SETOR_ATIV=="Bancos")

# Retirando os bancos da base ---------------------------------------------

dados <- dados |>
  filter(SETOR_ATIV!="Bancos")

# Qtde de empresas listadas na B3 -----------------------------------------

empresas <- dados |>
  distinct(DENOM_CIA)


# Identificar observações duplicadas em todas as colunas ------------------

duplicadas <- dados[duplicated(dados), ]
empresas_duplicadas <- data.frame("n"=unique(duplicadas$DENOM_CIA))


# Identificar observações triplicadas em todas as colunas ------------------

triplicadas <- duplicadas[duplicated(duplicadas), ]
empresas_triplicadas <- data.frame("n"=unique(triplicadas$DENOM_CIA))



# excluindo as observações duplicadas -------------------------------------

dados <- dados |>
  distinct()


# Salvando ----------------------------------------------------------------

openxlsx::write.xlsx(dados,"data/dfp_corrigido_BPA_con_2022.xlsx")

openxlsx::write.xlsx(bancos,"data/dfp_bancos_BPA_con_2022.xlsx")



# Qtde de contas diferentes -----------------------------------------------

contas <- dados |>
  distinct(CD_CONTA) |>
  pull()


# Qtde de terminologias diferentes -----------------------------------------------

terminologias <- dados |>
  distinct(DS_CONTA, CD_CONTA)

terminologias_unica <- terminologias |>
  distinct(DS_CONTA)


# Sumário -----------------------------------------------------------------

sumario <- bind_rows(count(empresas),count(empresas_duplicadas),
                     count(empresas_triplicadas), count(as.data.frame(contas)),
                     count(terminologias_unica),
                     round(count(terminologias_unica)/count(as.data.frame(contas)),2))

row.names(sumario) <- c("Nº de empresas",
                        "Nº de emp. com informações duplicadas",
                        "Nº de emp. com informações triplicadas",
                        "Nº de contas diferentes",
                        "Nº de terminologias diferentes",
                        "Média de terminologias por conta")

