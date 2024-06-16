# Pacotes -----------------------------------------------------------------

library(tidyverse)
library(openxlsx)
library(xtable)
library(moments)


# Limpando ----------------------------------------------------------------

rm(list=ls())


# Função para calcular a moda ---------------------------------------------

source("functions/moda.R")

# Tipo de balanço ---------------------------------------------------------

bp <- c("BPA","BPP")

# Sumário de contas por empresas ------------------------------------------
tab <- map(bp, ~ {
  file_path <- sprintf("data/dfp_corrigido_%s_con_2022.xlsx", .x)
  read.xlsx(file_path) |>
  group_by(DENOM_CIA) |>
  summarise("Freq"=n()) |>
  reframe("Mínimo"=min(Freq),
          "Máximo"=max(Freq),
          "Média"=round(mean(Freq),2),
          "Mediana"=median(Freq),
          "Moda"=Moda(Freq),
          "Desvio Padrão"=round(sd(Freq),2),
          "Primeiro quartil"=quantile(Freq,0.25),
          "Terceiro quartil"=quantile(Freq,0.75),
          "Assimetria" = skewness(Freq),
          "Curtose" = kurtosis(Freq))|>
  pivot_longer(cols = everything(),
               names_to = "Estatística",
               values_to = "Valor")
})


# Combinar resultados -----------------------------------------------------

sumario <- bind_cols(tab) |>
  select(-3) |>
  rename("Estatística"=1, "BPA"=2, "BPP"=3)



# Função para processar e imprimir a tabela -------------------------------

sumario <- xtable(sumario)
print(sumario, "Tabelas/sumario.tex", compress = FALSE, include.rownames = FALSE,type = "latex")
