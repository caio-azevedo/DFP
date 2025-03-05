# Import aux_tables script --------------------------------------------------
source("R/auxiliares/aux_tables.R")

# Tabela 2: Alguns exemplos de denominações associadas a diversos códigos de conta
tab2 <- list()
for (i in 1:2) {

tab2[[i]] <- ds_bp[[i]] |>
  group_by(Cod) |>
  summarise("Freq"=n(),
            "uso"=sum(n)) |>
  arrange(desc(Freq)) |>
  slice_head(n=20)
}

tab2 <- full_join(tab2[[1]], tab2[[2]], by = "Cod")
tab2 <- arrange(tab2, Cod)
tab2 <- tab2[c(16,21,18,19,24,28,26,27,31,34),]

tab2 <- rename(tab2, "Terminologia"= 1, "Contas diferentes Ativo" = 2, "Uso Ativo" = 3,
               "Contas diferentes Passivo" = 4, "Uso Passivo" = 5)

# Limpeza opcional para objetos começando com "ds_"
rm(list = ls(pattern = "^ds_"))


# Tabela 3: Quantidade de terminologias diferentes
tab3 <- list()
for (i in 1:2) {

tab3[[i]] <-  data.frame("Tipo"= tipo,
                    "(1)" = term_unica[[i]], "(2)" = term[[i]])
}

tab3 <- left_join(tab3[[1]], tab3[[2]], by = "Tipo")

tab3 <- rename(tab3, "Tipo" = 1, "Ativo (1)" = 2 , "Ativo (2)" = 3,
               "Passivo (1)" = 4, "Passivo (2)" = 5)

# Limpeza opcional para objetos começando com "term"
rm(list = ls(pattern = "^term"))
rm(tipo)

# Tabela 4: Número de terminologias por código de conta de acordo com o nível
tab4 <- list()
for(i in 1:2) {

tab4[[i]] <- df[[i]] |>
  group_by(ramificacao) |>
  summarise("media"=round(mean(nomenclatura),2),
            "mínimo" = round(min(nomenclatura),2),
            "máximo" = round(max(nomenclatura),2),
            "mediana" = round(median(nomenclatura),2))
}

tab4 <- left_join(tab4[[1]], tab4[[2]], by = "ramificacao")

tab4 <- rename(tab4, "Nível" = 1, "Média" = 2, "Mínimo" = 3, "Máximo" = 4, "Mediana" = 5,
               "Média Passivo" = 6, "Mínimo Passivo" = 7, "Máximo Passivo" = 8, "Mediana Passivo" = 9)

# Tabela 5: Alguns exemplos de contas do quarto nível com apenas uma terminologia utilizada
tab5 <- list()

for (i in 1:2) {

tab5[[i]] <- df[[i]] |>
  filter(ramificacao=="4",
         empresas>=47, nomenclatura==1) |>
  left_join(df_bp[[i]],by = join_by(Cod)) |>
  select(-c(n, ramificacao, nomenclatura))
}

tab5 <- rbind(tab5[[1]][1:5,],tab5[[2]][1:3,])

tab5 <- rename(tab5, "Cod." = 1, "Empresas" = 2, "Terminologias" = 3)

# Tabela 6: Alguns exemplos de contas do quinto nível com apenas uma terminologia utilizada
tab6 <- list()

for (i in 1:2) {

  tab6[[i]] <- df[[i]] |>
    filter(ramificacao=="5",
           empresas>=47, nomenclatura==1) |>
    left_join(df_bp[[i]],by = join_by(Cod)) |>
    select(-c(n, ramificacao, nomenclatura))
}

tab6 <- rbind(tab6[[1]][1:5,],tab6[[2]][1:3,])

tab6 <- rename(tab6, "Cod." = 1, "Empresas" = 2, "Terminologias" = 3)


# Tabela de frequência
tab <- list()

for (i in 1:2) {

tab[[i]] <- df[[i]] |>
  filter(ramificacao==5) |>
  arrange(desc(nomenclatura)) |>
  slice_head(n=10) |>
  select(-ramificacao)
}

tab <- do.call(cbind,tab)

# Exportando tabelas em Tex -----------------------------------------------

tab_list <- list(tab, tab2, tab3, tab4, tab5, tab6)

walk2(tab_list, seq_along(tab_list), tabelas_BP)

# Exportando tabelas em xlxs -----------------------------------------------
write_xlsx(tab_list, path = "Tabelas/tabelas.xlsx")
