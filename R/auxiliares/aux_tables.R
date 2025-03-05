df_bp <- list()
df <-  list()
ds_bp <- list()
term <- list()
term_unica <- list()
contas <- list()

for (i in 1:2) {

dados <- dados_bp[[i]]

# Qtde de contas diferentes -----------------------------------------------

contas[[i]] <- dados |>
  distinct(CD_CONTA) |>
  pull()

# Qtde de empresas listadas na CVM-----------------------------------------

empresas <- dados |>
  distinct(DENOM_CIA)


# Loop --------------------------------------------------------------------
df_bp[[i]] <- map_dfr(contas[[i]], ~ {
  dados %>%
    filter(CD_CONTA == .x) %>%
    count(DS_CONTA) %>%
    mutate(Cod = .x)
})


# Salvando ----------------------------------------------------------------

#openxlsx::write.xlsx(df_bpa,"data/df_BPA.xlsx")


# DF para auxiliar tabelas e gráficos -------------------------------------

x<-df_bp[[i]] |>
  group_by(Cod) |>
  summarise(empresas=sum(n))

y<-df_bp[[i]] |>
  count(Cod)

df[[i]]<-left_join(x,y)

rm(x,y)


# Ramificações ------------------------------------------------------------

df[[i]] <- df[[i]] |>
  mutate(ramificacao = case_when(
    nchar(Cod)==1 ~ "1",
    nchar(Cod)==4 ~ "2",
    nchar(Cod)==7 ~ "3",
    nchar(Cod)==10 ~ "4",
    nchar(Cod)==13 ~ "5",
  )) |>
  relocate(ramificacao, .before = empresas) |>
  rename("nomenclatura"=n)



# Auxiliar para a Tabela de terminologias ---------------------------------

terminologias <- dados |>
  distinct(DS_CONTA, CD_CONTA)

terminologias_unica <- dados |>
  distinct(DS_CONTA)

# Qtde de terminologias desconsiderando diferenças entre maiúsculo --------

terminologias_minuscula <- terminologias |>
  mutate("DS_CONTA"= tolower(DS_CONTA)) |>
  distinct(DS_CONTA, CD_CONTA)

terminologias_minuscula_unica <- terminologias |>
  mutate("DS_CONTA"= tolower(DS_CONTA)) |>
  distinct(DS_CONTA)

# Qtde de terminologias desconsiderando diferenças de acentuação ----------

terminologias_acento <- terminologias |>
  mutate("DS_CONTA"= stri_trans_general(DS_CONTA, "Latin-ASCII")) |>
  distinct(DS_CONTA, CD_CONTA)

terminologias_acento_unica <- terminologias |>
  mutate("DS_CONTA"= stri_trans_general(DS_CONTA, "Latin-ASCII")) |>
  distinct(DS_CONTA)


# Qtde de terminologias desconsiderando diferenças de acentuação e --------

term_acento_min <- terminologias |>
  mutate("DS_CONTA"= tolower(DS_CONTA),
         "DS_CONTA"= stri_trans_general(DS_CONTA, "Latin-ASCII")) |>
  distinct(DS_CONTA, CD_CONTA)

term_acento_min_unica <- terminologias |>
  mutate("DS_CONTA"= tolower(DS_CONTA),
         "DS_CONTA"= stri_trans_general(DS_CONTA, "Latin-ASCII")) |>
  distinct(DS_CONTA)


# Formando a tabela
term[[i]] <- bind_rows(count(terminologias),
                  count(terminologias_acento),
                  count(terminologias_minuscula),
                  count(term_acento_min))


term_unica[[i]] <- bind_rows(count(terminologias_unica),
                        count(terminologias_acento_unica),
                        count(terminologias_minuscula_unica),
                        count(term_acento_min_unica))


tipo <- c("Qtde de terminologias diferentes",
          "Qtde de term. desconsiderando diferenças entre maiúsculo e minúsculo",
          "Qtde de term. desconsiderando diferenças de acentuação",
          "Qtde de term. desconsiderando diferenças de acentuação e
          maiúsculo/minúsculo")

# Auxiliar para a tabela de terminologias com contas diferentes -----------------

ds_conta <- terminologias_unica |>
  pull()

ds_bp[[i]] <- map_dfr(ds_conta, ~{
  dados |>
    filter(DS_CONTA==.x) |>
    count(CD_CONTA) |>
    mutate(Cod = .x)
})

ds_bp[[i]] <- ds_bp[[i]] |>
  mutate(ramificacao = case_when(
    nchar(CD_CONTA)==1 ~ "1",
    nchar(CD_CONTA)==4 ~ "2",
    nchar(CD_CONTA)==7 ~ "3",
    nchar(CD_CONTA)==10 ~ "4",
    nchar(CD_CONTA)==13 ~ "5",
  )) |>
  relocate(ramificacao, .before = n)

}
