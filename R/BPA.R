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




# Limpando ----------------------------------------------------------------

rm(list=ls())


# list functions ----------------------------------------------------------
my_R_files <- list.files(path ="functions", pattern = '*.R',
                         full.names = TRUE)

# Load all functions in R  ------------------------------------------------
sapply(my_R_files, source)

# Lendo um arquivo CSV ----------------------------------------------------

dados <- read.csv("dfp_cia_aberta_2022/dfp_cia_aberta_BPA_con_2022.csv", sep = ";",
                  fileEncoding = "latin1")

dados_ <- dados |>
  filter(ORDEM_EXERC=="ÚLTIMO", DENOM_CIA!="TC S.A.")


# Resolvendo o problema da empresa TC.SA ----------------------------------

tc_sa <- dados |>
  filter(ORDEM_EXERC=="ÚLTIMO", VERSAO=="3", DENOM_CIA=="TC S.A.")


# Retornando TC. SA para dados --------------------------------------------

dados <- bind_rows(dados_,tc_sa)

rm(dados_, tc_sa)

# Identificar observações duplicadas em todas as colunas ------------------

duplicadas <- dados[duplicated(dados), ]
empresas_duplicadas <- unique(duplicadas$DENOM_CIA)
length(empresas_duplicadas)


# Identificar observações triplicadas em todas as colunas ------------------

triplicadas <- duplicadas[duplicated(duplicadas), ]
empresas_triplicadas <- unique(triplicadas$DENOM_CIA)
length(empresas_triplicadas)


# excluindo as observações duplicadas -------------------------------------

dados <- dados |>
  distinct()


# Qtde de empresas listadas na B3 -----------------------------------------

empresas <- dados |>
  distinct(DENOM_CIA)

count(empresas)

# Qtde de contas diferentes -----------------------------------------------

contas <- dados |>
  distinct(CD_CONTA) |>
  pull()

length(contas)

# Qtde de terminologias diferentes -----------------------------------------------

terminologias <- dados |>
  distinct(DS_CONTA, CD_CONTA)

count(terminologias)

terminologias_unica <- terminologias |>
  distinct(DS_CONTA)

count(terminologias_unica)

# Qtde de terminologias desconsiderando diferenças entre maiúsculo --------

terminologias_minuscula <- terminologias |>
  mutate("DS_CONTA"= tolower(DS_CONTA)) |>
  distinct(DS_CONTA, CD_CONTA)

count(terminologias_minuscula)

terminologias_minuscula_unica <- terminologias |>
  mutate("DS_CONTA"= tolower(DS_CONTA)) |>
  distinct(DS_CONTA)

count(terminologias_minuscula_unica)


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
df_bpa <- map_dfr(contas, ~ {
  dados %>%
    filter(CD_CONTA == .x) %>%
    count(DS_CONTA) %>%
    mutate(Cod = .x)
})


# Salvando ----------------------------------------------------------------

openxlsx::write.xlsx(df_bpa,"df_BPA.xlsx")


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

tab5 <- df |>
  filter(ramificacao==5) |>
  arrange(desc(nomenclatura)) |>
  slice_head(n=10) |>
  select(-ramificacao)

# Exportando tabelas em Tex -----------------------------------------------

tab<-xtable(tab)
print(tab,file="Tabelas/BPA_tabela1.tex",compress=F, include.rownames = F)

tab2<-xtable(tab2)
print(tab2,file="Tabelas/BPA_tabela2.tex",compress=F, include.rownames = F)

tab3<-xtable(tab3)
print(tab3,file="Tabelas/BPA_tabela3.tex",compress=F, include.rownames = F)

tab4<-xtable(tab4)
print(tab4,file="Tabelas/BPA_tabela4.tex",compress=F, include.rownames = F)

tab5<-xtable(tab5)
print(tab5,file="Tabelas/BPA_tabela5.tex",compress=F, include.rownames = F)

# Tema gráfico ------------------------------------------------------------

extrafont::loadfonts()
tema <- ggthemes::theme_hc() +
  theme(axis.title = element_text(
  family = "Verdana",
  face = "bold",
  size = 20
),
axis.text = element_text(
  family = "Verdana",
  size = 15
),
plot.caption = element_text(
  family = "Verdana",
  face = "bold",
  size = 15,
  hjust = 1
),
legend.text = element_text(
  family = "Verdana",
  face = "bold",
  size = 15
),
legend.title = element_text(
  family = "Verdana",
  size = 12 ))

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
  geom_col(aes(fill = Cod),
           color = "black",
           show.legend = FALSE) +
  scale_x_continuous(breaks = seq(0,180,20)) +
  ggthemes::scale_color_hc() +
  labs(title = "Quinta ramificação",
       x = "Quantidade de terminologias utilizadas",
       y = "Código da conta") +
  geom_label(aes(label = nomenclatura), size=7)


# 4 ramificações ----------------------------------------------------------

graf2 <- df |>
  filter(ramificacao==4) |>
  arrange(desc(nomenclatura)) |>
  slice_head(n=10) |>
  mutate(Cod_fator = forcats::fct_reorder(Cod,
                                  nomenclatura)) |>
  ggplot() +
  aes(x = nomenclatura, y = Cod_fator) +
  geom_col(aes(fill = Cod),
               color = "black",
               show.legend = FALSE) +
  scale_x_continuous(breaks=seq(0,30,5)) +
  ggthemes::scale_color_hc() +
  labs(title = "Quarta ramificação",
       x = "Quantidade de terminologias utilizadas",
       y = "Código da conta") +
  geom_label(aes(label = nomenclatura), size= 7)


# Boxplot -----------------------------------------------------------------

graf3 <- df |>
  filter(ramificacao > 1) |>
  ggplot()+
  aes(x = nomenclatura , y = ramificacao) +
  geom_boxplot(outlier.size = 3) +
  scale_x_continuous(breaks=seq(0,180,30)) +
  ggthemes::scale_color_economist() +
  labs(x = "Qtde de terminologias utilizadas",
       y = "Ramificações")


graf4 <- df |>
  filter(ramificacao > 1, empresas > 47) |>
  ggplot()+
  aes(x = nomenclatura , y = ramificacao) +
  geom_boxplot(outlier.size = 3) +
  scale_x_continuous(breaks=seq(0,180,30)) +
  ggthemes::scale_color_hc() +
  labs(x = "Qtde de terminologias utilizadas",
       y = "Ramificações")


graf5 <- df |>
  filter(ramificacao > 1) |>
  ggplot()+
  aes(x = nomenclatura, y = empresas,
      color = ramificacao)+
  geom_point(size=5) +
  scale_x_continuous(breaks=seq(0,180,30)) +
  ggthemes::scale_color_hc() +
  tema +
  labs(x = "Qtde de terminologias utilizadas",
       y = "Qtde de empresas")

# Patchwork ---------------------------------------------------------------

fig1 <- graf1 + graf2 + plot_annotation(
  caption = "FONTE: Elaboração própria"
) + plot_layout(axis_titles  = "collect") & tema


graf6 <- graf3 + graf4 + plot_annotation(
  caption = "FONTE: Elaboração própria"
) + plot_layout(ncol = 2,
                axis_titles  = "collect") & tema

fig2 <- graf6 / graf5 + plot_annotation(
  tag_levels = "I",tag_suffix = ")",
  caption = "FONTE: Elaboração própria") +
  plot_layout(nrow = 2, axis_titles  = "collect") &
  tema

# Salvando os gráficos ----------------------------------------------------

lista_g <- list()
lista_fig <- list(fig1,fig2)

for (i in 1:2) {
  nome <- paste0("BPA_fig", i)
  lista_g <- c(lista_g, nome)
}

purrr::walk2(lista_fig, lista_g,
      ~ ggsave(plot = .x,
               filename = glue('Figuras/BPA/{.y}.png'),
               dpi = 500,
               width = 16, height = 10))


# Gráficos das contas -----------------------------------------------------

for (i in c(4,5)) {
  contas_barra_bpa(i)
}

