# Pacotes -----------------------------------------------------------------

library(tidyverse)
library(openxlsx)
library(extrafont)
library(ggthemes)
library(xtable)
library(glue)
library(patchwork)
library(grid)
library(shadowtext)
library(stringi)
library(moments)
library(GetFREData)




# Limpando ----------------------------------------------------------------

rm(list=ls())


# list functions ----------------------------------------------------------
my_R_files <- list.files(path ="functions", pattern = '*.R',
                         full.names = TRUE)

# Load all functions in R  ------------------------------------------------
sapply(my_R_files, source)


# Lendo os arquivos ----------------------------------------------------

bp <- c("BPA","BPP")
df_list <- list()

source("R/cad_cia.R")

# Inicialize uma lista para armazenar os resultados


for (i in 1:2) {
  # Leia os dados
  dados <- read_dfp(2022, bp[i])

  # Filtrar dados e resolver problemas específicos
  dados_ <- dados |>
    filter(ORDEM_EXERC == "ÚLTIMO", DENOM_CIA != "TC S.A.")

  tc_sa <- dados |>
    filter(ORDEM_EXERC == "ÚLTIMO", VERSAO == "3", DENOM_CIA == "TC S.A.")

  # Reintegrar dados corrigidos
  dados <- bind_rows(dados_, tc_sa) |>
    distinct()

  # Adicionar setores
  cad_cia <- semi_join(cad_cia, dados, by = c("CD_CVM"))
  dados <- inner_join(dados, cad_cia)

  # Criar base somente de bancos
  bancos <- dados |>
    filter(SETOR_ATIV == "Bancos" |
             DENOM_CIA %in% c("BRAZILIAN FINANCE E REAL ESTATE S.A.",
                              "XP INVESTIMENTOS S.A."))

  # Remover bancos da base principal
  dados <- dados |>
    filter(SETOR_ATIV != "Bancos") |>
    filter(!DENOM_CIA %in% c("BRAZILIAN FINANCE E REAL ESTATE S.A.",
                             "XP INVESTIMENTOS S.A."))

  # Quantidade de contas diferentes
  contas <- dados |>
    distinct(CD_CONTA) |>
    pull()

  # Criar data frame por conta
  df_bpa <- map_dfr(contas, ~ {
    dados %>%
      filter(CD_CONTA == .x) %>%
      count(DS_CONTA) %>%
      mutate(Cod = .x)
  })

  # Processar resultados
  x <- df_bpa |>
    group_by(Cod) |>
    summarise(empresas = sum(n))

  y <- df_bpa |>
    count(Cod)

  df <- left_join(x, y)

  # Adicionar nível e filtrar
  df_list[[i]] <- df |>
    mutate(nivel = case_when(
      nchar(Cod) == 1 ~ "1",
      nchar(Cod) == 4 ~ "2",
      nchar(Cod) == 7 ~ "3",
      nchar(Cod) == 10 ~ "Quatro",
      nchar(Cod) == 13 ~ "Cinco",
    )) |>
    relocate(nivel, .before = empresas) |>
    rename("terminologias" = n) |>
    filter(nivel %in% c("Quatro", "Cinco"))
}

# Após o loop, combine os resultados em um único data frame, se necessário
base <- bind_rows(df_list)

rm(list = setdiff(ls(),"base"))

base <- base |>
  mutate(df = factor(case_when(
    substr(Cod,1,1)=="1" ~ "ativo",
    substr(Cod,1,1)=="2" ~ "passivo"
  )),.before = terminologias) |>
  mutate(circ = factor(case_when(
    substr(Cod,4,4)=="1" ~ "circulante",
    substr(Cod,4,4)=="2" ~ "não circulante",
    substr(Cod,4,4)=="3" ~ "PL"
  )),.before = terminologias) |>
  mutate(grupo = ifelse(terminologias < 5 & empresas > 400,FALSE,TRUE),.before = terminologias) |>
  mutate(nivel = as.factor(nivel)) |>
  mutate(bp = factor(paste(df,circ)))




# Salvando ----------------------------------------------------------------

#openxlsx::write.xlsx(df,"data/df_BPA_art2.xlsx")


#Pacotes utilizados
pacotes <- c("plotly","tidyverse","knitr","kableExtra","fastDummies","reshape2",
             "lmtest","splines","jtools","questionr","MASS","pscl","overdisp")

if(sum(as.numeric(!pacotes %in% installed.packages())) != 0){
  instalador <- pacotes[!pacotes %in% installed.packages()]
  for(i in 1:length(instalador)) {
    install.packages(instalador, dependencies = T)
    break()}
  sapply(pacotes, require, character = T)
} else {
  sapply(pacotes, require, character = T)
}


##############################################################################
#           EXEMPLO 02 - OBSERVAÇÃO DA BASE DE DADOS atrasos_bneg            #
##############################################################################


#Visualização da distribuição da variável dependente
base |>
    ggplot() +
    geom_histogram(aes(x = terminologias, fill = after_stat(count)),
                   bins = 11, color = "black") +
    labs(x = "Número de terminologias",
         y = "Frequência") +
    scale_fill_gradient("Contagem", low = "darkorchid", high = "orange") +
    theme_bw()



modelo_bneg <- glm.nb(formula = terminologias ~  empresas + nivel + df + cluster_H,
                      data = base)

# Modelo ZI Binomial Negativo
zi.nbin.glm <- zeroinfl(terminologias-1 ~  empresas + nivel + bp| cluster_K,
                        data = base,
                        dist = "negbin")

#Observando os parâmetros do modelo
summary(zi.nbin.glm)
#função glm.nb do pacote MASS

#Parâmetros do modelo
summary(modelo_bneg)


#Extração do valor do LL
logLik(zi.nbin.glm)

#LR Test
lrtest(zi.nbin.glm)

#Extração do valor do LL
logLik(modelo_bneg)

#LR Test - função lrtest do pacote lmtest
#(likelihood ratio test para comparação dos LL's entre modelos)
lrtest(modelo_bneg)


##############################################################################
#                             PLOTAGENS                                      #
##############################################################################
#Adicionando os fitted values de u à base de dados atrasos_bneg
base$u <- modelo_bneg$fitted.values

#Adicionando os fitted values de u_inf do zi.nbin.glm à base de
#dados
base$u_inf <- zi.nbin.glm$fitted.values



ggplot(base, aes(x = empresas, y = terminologias)) +
  geom_point(color = "bisque4", alpha = 0.7) +
  geom_smooth(aes(x = empresas, y = u, color = "Estimação Binomial Negativo"),
              method = "loess", se=F, size = 1) +
  geom_smooth(aes(x = empresas, y = u_inf, color = "Estimação ZI Binomial Negativo"),
              method = "loess", se=F, size = 1) +
  labs(x = "Empresas",
       y = "Terminologias", color = "Modelos:") +
  scale_color_manual("Modelos:",
                     values = c("steelblue", "green", "darkorchid4", "orange")) +
  theme_bw()

#Decréscimo nos LL's dos modelos
models.ll <- data.frame(`Negative Binomial Model`=logLik(modelo_bneg),
                        `ZI Negative Binomial Model`=logLik(zi.nbin.glm))

models.ll










