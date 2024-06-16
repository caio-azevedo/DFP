library(tidyverse)
library(openxlsx)
library(glue)
library(GetFREData)  # Assumindo que a função `read_dfp` vem deste pacote

# Carregar funções personalizadas e dados das empresas
source("R/cad_cia.R")

# Definição dos tipos de balanço
bp <- c("BPA", "BPP")

# Função para criar sumário
create_summary <- function(dados, tipo) {
  sumario <- tibble(
    Descrição = c(
      "Nº de empresas",
      "Nº de emp. com informações duplicadas",
      "Nº de emp. com informações triplicadas",
      "Nº de contas diferentes",
      "Nº de terminologias diferentes",
      "Média de terminologias por conta"
    ),
    Valor = c(
      n_distinct(dados$DENOM_CIA),
      dados |> filter(duplicated(dados)) |> distinct(DENOM_CIA) |> n_distinct(),
      dados |> filter(duplicated(dados)) |> filter(duplicated(dados)) |> distinct(DENOM_CIA) |> n_distinct(),
      n_distinct(dados$CD_CONTA),
      dados |> select(DS_CONTA, CD_CONTA) |> distinct() |> n_distinct(DS_CONTA),
      round(dados |> select(DS_CONTA, CD_CONTA) |> distinct(DS_CONTA) |> n_distinct() / n_distinct(dados$CD_CONTA), 2)
    )
  )
  write.xlsx(sumario, glue("data/sumario_{tipo}_con_2022.xlsx"))
  return(sumario)
}

# Processamento dos dados e geração de sumários
dados_lista <- map(bp, ~ {
  dados <- read_dfp(2022, .x) |>
    filter(ORDEM_EXERC == "ÚLTIMO") |>
    inner_join(semi_join(cad_cia, cad_cia |> filter(CD_CVM == .x), by = "CD_CVM"), by = "CD_CVM")

  bancos <- dados |> filter(SETOR_ATIV == "Bancos")
  dados_nao_bancos <- dados |> filter(SETOR_ATIV != "Bancos")

  write.xlsx(dados_nao_bancos, glue("data/dfp_corrigido_{.x}_con_2022.xlsx"))
  write.xlsx(bancos, glue("data/dfp_bancos_{.x}_con_2022.xlsx"))

  sumario <- create_summary(dados_nao_bancos, .x)

  list(dados = dados_nao_bancos, bancos = bancos, sumario = sumario)
})

# Limpeza final opcional para objetos começando com "cad"
rm(list = ls(pattern = "^cad"))

