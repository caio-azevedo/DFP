# clean up workspace ------------------------------------------------------
rm(list=ls())

# close all figure --------------------------------------------------------
graphics.off()

# load packages -----------------------------------------------------------

pacotes <- c("tidyverse", "openxlsx", "writexl", "extrafont", "ggthemes",
             "xtable", "glue", "patchwork", "grid", "shadowtext",
             "stringi", "moments", "GetFREData")

novos <- pacotes[!(pacotes %in% installed.packages()[, "Package"])]

if(length(novos)) {
  install.packages(novos, dependencies = TRUE)
}

lapply(pacotes, require, character.only = TRUE)

# list functions ----------------------------------------------------------
my_R_files <- list.files(path ="functions", pattern = '*.R',
                         full.names = TRUE)

# Load all functions in R  ------------------------------------------------
sapply(my_R_files, source)

# Import data script ------------------------------------------------------
source("R/01-import-and-clean-data.R")

# Import summary script ---------------------------------------------------
source("R/02-summary.R")

# Import tables script --------------------------------------------------
source("R/03-tables.R")

# Import graphics script --------------------------------------------------
#source("R/04-graphics.R")

# Figura 1: Sumário das informações amostradas
print(sumario)

# Tabela 2: Alguns exemplos de denominações associadas a diversos códigos de conta
print(tab2)

# Tabela 3: Quantidade de terminologias diferentes.
print(tab3)

# Tabela 4: Número de terminologias por código de conta de acordo com o nível.
print(tab4)

# Tabela 5: Alguns exemplos de contas do quarto nível com apenas uma terminologia utilizada.
print(tab5)

# Tabela 6: Alguns exemplos de contas do quinto nível com apenas uma terminologia utilizada.
print(tab6)
