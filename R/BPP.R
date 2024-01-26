library(tidyverse)
library(descr)
library(openxlsx)

rm(list=ls())


# Lendo um arquivo CSV com a função read.csv()
dados <- read.csv("dfp_cia_aberta_2022/dfp_cia_aberta_BPP_con_2022.csv", sep = ";",
                  fileEncoding = "latin1")

dados <- dados %>%
  filter(ORDEM_EXERC=="ÚLTIMO")

# Identificar observações duplicadas em todas as colunas
duplicadas <- dados[duplicated(dados), ]

# excluindo as observações duplicadas
dados <- unique(dados)

# Qtade de empresas listadas na B3
empresas <- unique(dados$DENOM_CIA)
length(empresas)

# Qtade de contas diferentes
contas <- unique(dados$CD_CONTA)
length(contas)


tabela<- list()

for (i in c(1:length(contas))) {
  tabela[[i]] <- dados %>%
    filter(CD_CONTA==contas[i]) %>%
    count(DS_CONTA) %>%
    mutate(Cod=contas[i])

  i <- i + 1
}

df_bpp<-do.call(rbind,tabela)


#openxlsx::write.xlsx(df_bpp,"df_BPP.xlsx")
