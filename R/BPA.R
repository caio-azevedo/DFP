# Pacotes -----------------------------------------------------------------

library(tidyverse)
library(openxlsx)
library(extrafont)
library(ggthemes)



# Limpando ----------------------------------------------------------------

rm(list=ls())


# Lendo um arquivo CSV ----------------------------------------------------

dados <- read.csv("dfp_cia_aberta_2022/dfp_cia_aberta_BPA_con_2022.csv", sep = ";",
                  fileEncoding = "latin1")

dados <- dados %>%
  filter(ORDEM_EXERC=="ÚLTIMO")


# Identificar observações duplicadas em todas as colunas ------------------

duplicadas <- dados[duplicated(dados), ]


# excluindo as observações duplicadas -------------------------------------

dados <- unique(dados)


# Qtde de empresas listadas na B3 -----------------------------------------

empresas <- unique(dados$DENOM_CIA)
length(empresas)


# Qtde de contas diferentes -----------------------------------------------

contas <- unique(dados$CD_CONTA)
length(contas)


# Loop --------------------------------------------------------------------

tabela<- list()

for (i in c(1:length(contas))) {
  tabela[[i]] <- dados %>%
    filter(CD_CONTA==contas[i]) %>%
    count(DS_CONTA) %>%
    mutate(Cod=contas[i])

  i <- i + 1
}

df_bpa<-do.call(rbind,tabela)

rm(tabela)

# Salvando ----------------------------------------------------------------

#openxlsx::write.xlsx(df_bpa,"df_BPA.xlsx")


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



# Tema gráfico ------------------------------------------------------------

extrafont::loadfonts()
tema <- ggthemes::theme_economist() +
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
  ggthemes::scale_color_economist() +
  tema +
  labs(title = "Quinta ramificação",
       caption = "FONTE:Elaboração própria",
       x = "Quantidade de nomemclaturas utilizadas",
       y = "Código da conta") +
  geom_label(aes(label = nomenclatura), size=10)


ggsave("Figuras/graf1.png", graf1,dpi = 900,
       width = 16, height = 10)


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
  ggthemes::scale_color_economist() +
  tema +
  labs(title = "Quarta ramificação",
       caption = "FONTE:Elaboração própria",
       x = "Quantidade de nomemclaturas utilizadas",
       y = "Código da conta") +
  geom_label(aes(label = nomenclatura), size= 10)


ggsave("Figuras/graf2.png", graf2,dpi = 900,
       width = 16, height = 10)


# Boxplot -----------------------------------------------------------------

graf3 <- df |>
  filter(ramificacao > 1) |>
  ggplot()+
  aes(x = nomenclatura , y = ramificacao) +
  geom_boxplot(outlier.size = 3) +
  scale_x_continuous(breaks=seq(0,180,30)) +
  ggthemes::scale_color_economist() +
  tema +
  labs(caption = "FONTE:Elaboração própria",
       x = "Quantidade de nomemclaturas utilizadas",
       y = "Ramificações")

ggsave("Figuras/graf3.png", graf3,dpi = 900,
       width = 16, height = 10)

graf4 <- df |>
  filter(ramificacao > 1, empresas > 47) |>
  ggplot()+
  aes(x = nomenclatura , y = ramificacao) +
  geom_boxplot(outlier.size = 3) +
  scale_x_continuous(breaks=seq(0,180,30)) +
  ggthemes::scale_color_economist() +
  tema +
  labs(caption = "FONTE:Elaboração própria",
       x = "Quantidade de nomemclaturas utilizadas",
       y = "Ramificações")

ggsave("Figuras/graf4.png", graf4,dpi = 900,
       width = 16, height = 10)
