library(tidyverse)
library(openxlsx)
library(glue)


# Limpando ----------------------------------------------------------------

rm(list=ls())


# list functions ----------------------------------------------------------
my_R_files <- list.files(path ="functions", pattern = '*.R',
                         full.names = TRUE)

# Load all functions in R  ------------------------------------------------
sapply(my_R_files, source)

# Carregando funções personalizadas e dados das empresas
source("R/cad_cia.R")

# Definição dos tipos de balanço
bp <- c("BPA", "BPP")

# Definindo a função de criação de sumário
create_summary <- function(dados, tipo) {
  sumario <- tibble(
    Descrição = c("Nº de empresas", "Nº de emp. com informações duplicadas",
                  "Nº de emp. com informações triplicadas",
                  "Nº de contas diferentes", "Nº de terminologias diferentes",
                  "Média de terminologias por conta"),
    Valor = c(
      n_distinct(dados$DENOM_CIA),
      n_distinct(dados %>% filter(duplicated(.)) %>% distinct(DENOM_CIA)),
      n_distinct(dados %>% filter(duplicated(.)) %>% filter(duplicated(.)) %>% distinct(DENOM_CIA)),
      n_distinct(dados$CD_CONTA),
      n_distinct(dados %>% select(DS_CONTA, CD_CONTA) %>% distinct(DS_CONTA)),
      round(n_distinct(dados %>% select(DS_CONTA, CD_CONTA) %>% distinct(DS_CONTA)) / n_distinct(dados$CD_CONTA), 2)
    )
  )
  write.xlsx(sumario, glue("data/sumario_{tipo}_con_2022.xlsx"))
  return(sumario)
}

# Processamento e geração de sumários
dados_lista <- map(bp, ~ {
  # Leitura e filtragem dos dados
  dados <- read_dfp(2022, .x) %>%
    filter(ORDEM_EXERC == "ÚLTIMO") %>%
    inner_join(semi_join(cad_cia, ., by = "CD_CVM"))

  # Segmentação dos dados em bancos e não bancos
  bancos <- dados %>% filter(SETOR_ATIV == "Bancos"| DENOM_CIA %in% c("BRAZILIAN FINANCE E REAL ESTATE S.A.",
                                                                  "XP INVESTIMENTOS S.A."))
  dados_nao_bancos <- dados %>% filter(SETOR_ATIV != "Bancos") %>%
    filter(!DENOM_CIA %in% c("BRAZILIAN FINANCE E REAL ESTATE S.A.",
                             "XP INVESTIMENTOS S.A."))

  # Salvamento dos dados processados
  write.xlsx(dados_nao_bancos, glue("data/dfp_corrigido_{.x}_con_2022.xlsx"))
  write.xlsx(bancos, glue("data/dfp_bancos_{.x}_con_2022.xlsx"))

  # Criação e salvamento de sumários
  sumario <- create_summary(dados_nao_bancos, .x)

  # Retorno dos dados processados e sumário
  list(dados = dados_nao_bancos, bancos = bancos, sumario = sumario)
})

# Limpeza final opcional para objetos começando com "cad"
rm(list = ls(pattern = "^cad"))
