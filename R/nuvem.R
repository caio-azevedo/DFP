# Carregue os pacotes
library(wordcloud)
library(quanteda)
library(tm)
library(RColorBrewer)
library(descr)
library(stringi)
library(tidyverse)



# Crie um corpus de texto e pré-processamento
corpus <- corpus(text)
tokens <- tokens(corpus, what = "word", remove_punct = TRUE, remove_numbers = TRUE)
tokens <- tokens_tolower(tokens)
tokens <- tokens_remove(tokens, stopwords("pt"))

# Crie uma matriz de termos-documentos e calcule a frequência das palavras
dfm <- dfm(tokens)
word_freqs <- dfm %>%
  convert(to = "data.frame") %>%
  summarise(across(where(is.numeric), sum)) %>%
  pivot_longer(cols = everything(), names_to = "word", values_to = "freq") %>%
  arrange(desc(freq))

# Gere a nuvem de palavras
png("nuvem_de_palavras.png",width = 800, height = 800)
set.seed(1234)
wordcloud(words = word_freqs$word, freq = word_freqs$freq,
          min.freq = 5,
          max.words=30, random.order=FALSE, rot.per=0,
          colors=brewer.pal(8, "Dark2"),
          use.r.layout = F, fixed.asp = F)
dev.off() # Fecha o dispositivo gráfico
