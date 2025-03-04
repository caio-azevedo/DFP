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



# Limpando ----------------------------------------------------------------

rm(list=ls())

# list functions ----------------------------------------------------------
my_R_files <- list.files(path ="functions", pattern = '*.R',
                         full.names = TRUE)

# Load all functions in R  ------------------------------------------------
sapply(my_R_files, source)


# Lendo os arquivos ----------------------------------------------------

dados <- read_dfp(2022, "BPP")

source("R/cad_cia.R")


# Resolvendo o problema da empresa TC.SA ----------------------------------

dados_ <- dados |>
  filter(ORDEM_EXERC=="ÚLTIMO", DENOM_CIA!="TC S.A.")

tc_sa <- dados |>
  filter(ORDEM_EXERC=="ÚLTIMO", VERSAO=="3", DENOM_CIA=="TC S.A.")


# Retornando TC. SA para dados --------------------------------------------

dados <- bind_rows(dados_,tc_sa)

rm(dados_, tc_sa)


# Identificar observações duplicadas em todas as colunas ------------------

duplicadas <- dados[duplicated(dados), ]
empresas_duplicadas <- data.frame("n"=unique(duplicadas$DENOM_CIA))


# Identificar observações triplicadas em todas as colunas ------------------

triplicadas <- duplicadas[duplicated(duplicadas), ]
empresas_triplicadas <- data.frame("n"=unique(triplicadas$DENOM_CIA))



# excluindo as observações duplicadas -------------------------------------

dados <- dados |>
  distinct()

# Adicionado os setores ---------------------------------------------------

cad_cia <- semi_join(cad_cia,dados,by=c("CD_CVM"))

dados <- inner_join(dados,cad_cia)

# Listar todos os objetos no ambiente que começam com "cad" ---------------

objetos_cad <- ls(pattern = "^cad")


# Remover esses objetos ---------------------------------------------------

rm(list = objetos_cad, objetos_cad)


# Criando a base somente de bancos ----------------------------------------

bancos <- dados |>
  filter(SETOR_ATIV=="Bancos" |
         DENOM_CIA%in%c("BRAZILIAN FINANCE E REAL ESTATE S.A.",
                      "XP INVESTIMENTOS S.A."))


# Retirando os bancos da base ---------------------------------------------

dados <- dados |>
  filter(SETOR_ATIV!="Bancos") |>
  filter(!DENOM_CIA %in% c("BRAZILIAN FINANCE E REAL ESTATE S.A.",
                      "XP INVESTIMENTOS S.A."))

# Qtde de empresas listadas na B3 -----------------------------------------

empresas <- dados |>
  distinct(DENOM_CIA)

# Salvando ----------------------------------------------------------------

openxlsx::write.xlsx(dados,"data/dfp_corrigido_BPP_con_2022.xlsx")

openxlsx::write.xlsx(bancos,"data/dfp_bancos_BPP_con_2022.xlsx")


# Qtde de contas diferentes -----------------------------------------------

contas <- dados |>
  distinct(CD_CONTA) |>
  pull()


# Qtde de terminologias diferentes -----------------------------------------------

terminologias <- dados |>
  distinct(DS_CONTA, CD_CONTA)

terminologias_unica <- dados |>
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



# Loop --------------------------------------------------------------------
df_bpp <- map_dfr(contas, ~ {
  dados %>%
    filter(CD_CONTA == .x) %>%
    count(DS_CONTA) %>%
    mutate(Cod = .x)
})

# Salvando ----------------------------------------------------------------

openxlsx::write.xlsx(df_bpp,"data/df_BPP.xlsx")


# DF para auxiliar gráficos -----------------------------------------------

x<-df_bpp |>
  group_by(Cod) |>
  summarise(empresas=sum(n))

y<-df_bpp |>
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
  left_join(df_bpp,by = join_by(Cod)) |>
  select(-c(n, ramificacao, nomenclatura))


tab4 <- df |>
  filter(ramificacao=="4",
         empresas>=47, nomenclatura==1) |>
  left_join(df_bpp,by = join_by(Cod)) |>
  select(-c(n, ramificacao, nomenclatura))

tab5 <- df |>
  filter(ramificacao==5) |>
  arrange(desc(nomenclatura)) |>
  slice_head(n=10) |>
  select(-ramificacao)

# Tabela para as terminologias --------------------------------------------


term <- bind_rows(count(terminologias), count(terminologias_minuscula),
                  count(terminologias_acento), count(term_acento_min))


term_unica <- bind_rows(count(terminologias_unica),
                        count(terminologias_minuscula_unica),
                        count(terminologias_acento_unica),
                        count(term_acento_min_unica))


tipo <- c("Qtde de terminologias diferentes",
          "Qtde de term. desconsiderando diferenças entre maiúsculo e minúsculo",
          "Qtde de term. desconsiderando diferenças de acentuação",
          "Qtde de term. desconsiderando diferenças de acentuação e
          maiúsculo/minúsculo")

tab6 <-  data.frame("Tipo"= tipo,
                    "(1)" = term, "(2)" = term_unica)



# Criando a tabela de terminologias com contas diferentes -----------------

ds_conta <- terminologias_unica |>
  pull()

ds_bp <- map_dfr(ds_conta, ~{
  dados |>
    filter(DS_CONTA==.x) |>
    count(CD_CONTA) |>
    mutate(Cod = .x)
})

ds_bp <- ds_bp |>
  mutate(ramificacao = case_when(
    nchar(CD_CONTA)==1 ~ "1",
    nchar(CD_CONTA)==4 ~ "2",
    nchar(CD_CONTA)==7 ~ "3",
    nchar(CD_CONTA)==10 ~ "4",
    nchar(CD_CONTA)==13 ~ "5",
  )) |>
  relocate(ramificacao, .before = n)

tab7 <- ds_bp |>
  group_by(Cod) |>
  summarise("Freq"=n(),
            "uso"=sum(n)) |>
  arrange(desc(Freq)) |>
  slice_head(n=20)

# Exportando tabelas em Tex -----------------------------------------------

tab_list <- list(tab, tab2, tab3, tab4, tab5, tab6, tab7)

walk2(tab_list, seq_along(tab_list), tabelas_BPP)

# Tema gráfico ------------------------------------------------------------

extrafont::loadfonts()
tema <- ggthemes::theme_hc() +
  theme(axis.title = element_text(
    family = "Palatino Linotype",
    face = "bold",
    size = 26
  ),
  axis.text = element_text(
    family = "Palatino Linotype",
    size = 20
  ),
  plot.caption = element_text(
    family = "Palatino Linotype",
    face = "bold",
    size = 20,
    hjust = 1
  ),
  legend.text = element_text(
    family = "Palatino Linotype",
    face = "bold",
    size = 20
  ),
  legend.title = element_text(
    family = "Palatino Linotype",
    size = 20
    )
  )

# Gráficos ----------------------------------------------------------------


# 5 ramificações ----------------------------------------------------------

graf1 <- df |>
  filter(ramificacao==5) |>
  arrange(desc(nomenclatura)) |>
  slice_head(n=10) |>
  mutate(Cod_fator = forcats::fct_reorder(Cod,
                                          nomenclatura)) |>
  ggplot() +
  aes(x = nomenclatura, y = Cod_fator) +
  geom_col(fill = "#4C9900",,
           color = "black",
           show.legend = FALSE) +
  scale_x_continuous(breaks = seq(0,270,30), limits = c(0,270)) +
  ggthemes::scale_color_hc() +
  labs(title = "Quinto Nível",
       x = "Quantidade de terminologias utilizadas",
       y = "Código da conta") +
  geom_label(aes(label = nomenclatura), size=10) + tema


# 4 ramificações ----------------------------------------------------------

graf2 <- df |>
  filter(ramificacao==4) |>
  arrange(desc(nomenclatura)) |>
  slice_head(n=10) |>
  mutate(Cod_fator = forcats::fct_reorder(Cod,
                                          nomenclatura)) |>
  ggplot() +
  aes(x = nomenclatura, y = Cod_fator) +
  geom_col(fill = "#4C9900",
           color = "black",
           show.legend = FALSE) +
  scale_x_continuous(breaks=seq(0,135,15), limits = c(0,135)) +
  ggthemes::scale_color_hc() +
  labs(title = "Quarto Nível",
       x = "Quantidade de terminologias utilizadas",
       y = "Código da conta") +
  geom_label(aes(label = nomenclatura), size= 10) + tema

# Boxplot -----------------------------------------------------------------

graf3 <- df |>
  filter(ramificacao > 1) |>
  ggplot()+
  aes(x = nomenclatura , y = ramificacao) +
  geom_boxplot(outlier.size = 3) +
  scale_x_continuous(breaks=seq(0,270,30)) +
  ggthemes::scale_color_economist() +
  labs(x = "Qtde de terminologias utilizadas",
       y = "Nível") + tema


graf4 <- df |>
  filter(ramificacao > 1, empresas > 47) |>
  ggplot()+
  aes(x = nomenclatura , y = ramificacao) +
  geom_boxplot(outlier.size = 3) +
  scale_x_continuous(breaks=seq(0,270,30)) +
  ggthemes::scale_color_hc() +
  labs(x = "Qtde de terminologias utilizadas",
       y = "Nível") + tema


graf5 <- df |>
  filter(ramificacao > 1) |>
  ggplot()+
  aes(x = nomenclatura, y = empresas,
      color = ramificacao)+
  geom_point(size=5) +
  scale_x_continuous(breaks=seq(0,270,30)) +
  ggthemes::scale_color_hc() +
  tema +
  labs(x = "Qtde de terminologias utilizadas",
       y = "Qtde de empresas")

fig3 <- df |>
  filter(ramificacao > 3) |>
  ggplot()+
  aes(x = nomenclatura, y = empresas)+
  geom_point(size=6, colour = "#4C9900") + facet_wrap(~ ramificacao, nrow = 2) +
  scale_x_continuous(breaks=seq(0,270,30)) +
  ggthemes::scale_color_hc() +
  tema + theme(strip.text = element_text(size = 30,
                                         family = "Verdana",
                                         face = "bold",
                                         color = "white"),
               strip.background = element_rect(
                 fill = "#4C9900"
               )) +
  labs(x = "Qtde de terminologias utilizadas",
       y = "Qtde de empresas") +guides(color = "none") +
  scale_color_canva()
# Patchwork ---------------------------------------------------------------

fig1 <- graf2 + graf1  + plot_layout(axis_titles  = "collect") & tema


graf6 <- graf3 + graf4 + plot_layout(ncol = 2,
                axis_titles  = "collect") & tema

fig2 <- graf6 / graf5 + plot_annotation(
  tag_levels = "I",tag_suffix = ")") +
  plot_layout(nrow = 2, axis_titles  = "collect") &
  tema

# Salvando os gráficos ----------------------------------------------------

lista_g <- list()
lista_fig <- list(fig1,fig2,fig3)

for (i in 1:3) {
  nome <- paste0("BPP_fig", i)
  lista_g <- c(lista_g, nome)
}

purrr::walk2(lista_fig, lista_g,
             ~ ggsave(plot = .x,
                      filename = glue('Figuras/BPP/{.y}.png'),
                      dpi = 500,
                      width = 16, height = 10))

# Gráficos das contas -----------------------------------------------------

for (i in c(4,5)) {
  contas_barra_bpp(i)
}
