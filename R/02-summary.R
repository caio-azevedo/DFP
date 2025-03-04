dados_bp <- list()

for (i in seq_along(bp)) {

  dados <- read_dados(bp[i])

  # Remover duplicatas
  dados <- dados |> distinct()

  # Filtragem dos dados para resolver o problema com TC S.A.
  dados_ <- dados |> filter(ORDEM_EXERC == "ÚLTIMO", DENOM_CIA != "TC S.A.")
  tc_sa  <- dados |> filter(ORDEM_EXERC == "ÚLTIMO", VERSAO == "3", DENOM_CIA == "TC S.A.")

  # Combina os dados e armazena na lista
  dados_bp[[i]] <- bind_rows(dados_, tc_sa)

  # Remover variáveis temporárias
  rm(dados_, tc_sa)
}






