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



# Baixando as informações das companhias ----------------------------------

dados <- read.xlsx("data/dfp_bancos_BPA_con_2022.xlsx")


# Qtde de contas diferentes -----------------------------------------------

contas <- dados |>
  distinct(CD_CONTA) |>
  pull()

# Qtde de empresas listadas na B3 -----------------------------------------

empresas <- dados |>
  distinct(DENOM_CIA)

# Identificar observações duplicadas em todas as colunas ------------------

duplicadas <- dados[duplicated(dados), ]
empresas_duplicadas <- data.frame("n"=unique(duplicadas$DENOM_CIA))


# Identificar observações triplicadas em todas as colunas ------------------

triplicadas <- duplicadas[duplicated(duplicadas), ]
empresas_triplicadas <- data.frame("n"=unique(triplicadas$DENOM_CIA))




# Qtde de terminologias diferentes -----------------------------------------------

terminologias <- dados |>
  distinct(DS_CONTA, CD_CONTA)

terminologias_unica <- terminologias |>
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
df_bpa_bancos <- map_dfr(contas, ~ {
  dados %>%
    filter(CD_CONTA == .x) %>%
    count(DS_CONTA) %>%
    mutate(Cod = .x)
})


# Salvando ----------------------------------------------------------------

openxlsx::write.xlsx(df_bpa_bancos,"data/df_BPA_bancos.xlsx")


# DF para auxiliar gráficos -----------------------------------------------

x<-df_bpa_bancos |>
  group_by(Cod) |>
  summarise(empresas=sum(n))

y<-df_bpa_bancos |>
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


tab3 <- df |>
  filter(ramificacao=="5",
         empresas>=47, nomenclatura==1) |>
  left_join(df_bpa_bancos,by = join_by(Cod)) |>
  select(-n)


tab4 <- df |>
  filter(ramificacao=="4",
         empresas>=47, nomenclatura==1) |>
  left_join(df_bpa_bancos,by = join_by(Cod)) |>
  select(-n)

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

# Sumário de contas por empresas ------------------------------------------

tab7 <- dados |>
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

# Exportando tabelas em Tex -----------------------------------------------

tab_list <- list(tab, tab3, tab4, tab5, tab6, tab7)

walk2(tab_list, seq_along(tab_list), tabelas_BPA)

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
  geom_col(fill = "#076fa2",,
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
  geom_col(fill = "#076fa2",
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

fig3 <- df |>
  filter(ramificacao > 1) |>
  ggplot()+
  aes(x = nomenclatura, y = empresas, color = ramificacao)+
  geom_point(size=5) + facet_wrap(~ ramificacao, nrow = 2) +
  scale_x_continuous(breaks=seq(0,180,30)) +
  ggthemes::scale_color_hc() +
  tema + theme(strip.text = element_text(size = 20)) +
  labs(x = "Qtde de terminologias utilizadas",
       y = "Qtde de empresas") + guides(color = "none") +
  scale_color_canva()

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
lista_fig <- list(fig1,fig2,fig3)

for (i in 1:3) {
  nome <- paste0("BPA_bancos_fig", i)
  lista_g <- c(lista_g, nome)
}

purrr::walk2(lista_fig, lista_g,
             ~ ggsave(plot = .x,
                      filename = glue('Figuras/BPA/{.y}.png'),
                      dpi = 500,
                      width = 16, height = 10))



