# Pacotes -----------------------------------------------------------------

library(tidyverse)
library(openxlsx)


# Limpando ----------------------------------------------------------------

rm(list=ls())


# Lendo um arquivo CSV ----------------------------------------------------

dados <- read.csv("dfp_cia_aberta_2022/dfp_cia_aberta_BPA_con_2022.csv", sep = ";",
                  fileEncoding = "latin1")

dados <- dados %>%
  filter(ORDEM_EXERC=="ÚLTIMO")


# Identificar observações duplicadas em todas as colunas ------------------

duplicadas <- dados[duplicated(dados), ]


# excluindo as observações duplicadas -------------------------------------

dados <- unique(dados)


# Qtde de empresas listadas na B3 -----------------------------------------

empresas <- unique(dados$DENOM_CIA)
length(empresas)


# Qtde de contas diferentes -----------------------------------------------

contas <- unique(dados$CD_CONTA)
length(contas)


# Loop --------------------------------------------------------------------

tabela<- list()

for (i in c(1:length(contas))) {
  tabela[[i]] <- dados %>%
    filter(CD_CONTA==contas[i]) %>%
    count(DS_CONTA) %>%
    mutate(Cod=contas[i])

  i <- i + 1
}

df_bpa<-do.call(rbind,tabela)

rm(tabela)

# Salvando ----------------------------------------------------------------

#openxlsx::write.xlsx(df_bpa,"df_BPA.xlsx")


# DF para auxiliar gráficos -----------------------------------------------

x<-df_bpa |>
  group_by(Cod) |>
  summarise(empresas=sum(n))

y<-df_bpa |>
  count(Cod)

df<-left_join(x,y)

rm(x,y)


# Ramificações ------------------------------------------------------------

df <- df |>
  mutate(ramificacao = case_when(
    nchar(Cod)==1 ~ "1",
    nchar(Cod)==4 ~ "2",
    nchar(Cod)==7 ~ "3",
    nchar(Cod)==10 ~ "4",
    nchar(Cod)==13 ~ "5",
    )) |>
  relocate(ramificacao, .before = empresas) |>
  rename("nomenclatura"=n)

avaliacao <- df|>
  filter(nomenclatura > 1) |>
  mutate(aval = nomenclatura/empresas) |>
  mutate(nível = if_else(aval <= 0.10,1,
                  if_else(aval > 0.10 & aval<=0.20,2,
                    if_else(aval > 0.2 & aval <= 0.4,3,
                      if_else(aval > 0.4 & aval <= 0.6, 4,
                        if_else(aval >0.6 & aval < 1,5,
                          if_else(aval == 1 & empresas > 10,5,0))))))) |>
  arrange(desc(nível),ramificacao,desc(nomenclatura)) |>
  select(-aval)


# Tabelas -----------------------------------------------------------------


tab <- df |>
  group_by(ramificacao) |>
  summarise("media"=mean(nomenclatura),
            "mínimo" = min(nomenclatura),
            "máximo" = max(nomenclatura),
            "mediana" = median(nomenclatura))

tab2 <- df |>
  filter(empresas>=47) |>
  group_by(ramificacao) |>
  summarise("media"=mean(nomenclatura),
            "mínimo" = min(nomenclatura),
            "máximo" = max(nomenclatura),
            "mediana" = median(nomenclatura))

tab3 <- df |>
  filter(ramificacao=="5",
         empresas>=47, nomenclatura==1) |>
  left_join(df_bpa,by = join_by(Cod)) |>
  select(-n)


tab4 <- df |>
  filter(ramificacao=="4",
         empresas>=47, nomenclatura==1) |>
  left_join(df_bpa,by = join_by(Cod)) |>
  select(-n)

# Gráficos ----------------------------------------------------------------


