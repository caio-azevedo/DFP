[![Project Status: Active](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

# Arquivos para replicação dos dados, tabelas e gráficos
Repositório dos scripts utilizados no desenvolvimento do artigo "A despadronização da “padronização”: um panorama da complexidade terminológica dos balanços patrimoniais no Brasil".

# Informações do artigo

## Resumo

Este estudo visa analisar a diversidade terminológica existente nos Balanços Patrimoniais das empresas de capital aberto no Brasil a partir dos atuais padrões baseados em princípios, bem como avaliar de que forma a flexibilidade contábil e a diversificação excessiva de rubricas impactam a clareza das demonstrações contábeis das empresas brasileiras de capital aberto. Sua fundamentação teórica está delineada no debate entre padrões baseados em regras ou princípios que está diretamente relacionado à discussão sobre uniformidade versus flexibilidade nas normas contábeis e seus efeitos na comparabilidade das informações contábeis, sem defender quais dos padrões é ideal, reconhecendo a complexidade do tema. Emprega uma abordagem híbrida combinando revisão bibliográfica com técnicas estatísticas. Tendo os dados sido extraídos diretamente dos relatórios financeiros na CVM para o ano de 2022, utilizando programação em R, que permitiu a coleta de um amplo conjunto de dados, incluindo 453 empresas, resultando em 30.391 observações de ativos e 52.512 observações de passivos. A análise revelou uma alta diversidade terminológica nos níveis mais detalhados do plano de contas, com até 167 e 256 variações de termos para o mesmo código de conta, para ativo e passivo respectivamente. Esses resultados evidenciam a necessidade de um maior equilíbrio na adoção de padrões baseados em regras e princípios, de forma a promover uma padronização terminológica mais consistente. Isso contribuiria para minimizar a assimetria informacional, facilitando a interpretação e comparação dos dados por parte dos usuários, e, consequentemente, aprimorando a qualidade das decisões econômicas que se baseiam nessas informações.

**Palavras-chave:** Demonstrações Financeiras Padronizadas; Terminologia Contábil; Comparabilidade; Padronização Contábil.


## Autores:

* Lorrane Almeida de Sousa

Bacharela em Ciências Contábeis pela Universidade Federal do Delta do Parnaíba (UFDPar), Brasil.

E-mail: lorrane.sousa@ufdpar.edu.br

ORCID(https://orcid.org/0009-0006-1625-0049)


* Caio Oliveira Azevedo

Mestre em Economia Aplicada pela Universidade Federal da Paraíba (UFPB), Brasil.

E-mail: caio.azevedo@live.com

ORCID(https://orcid.org/0000-0002-7296-4939)


* Maria Isaura da Costa Neta

Bacharela em Ciências Contábeis pela Universidade Federal da Paraíba (UFPB), Brasil.

E-mail: maria.isaura@academico.ufpb.br

ORCID(https://orcid.org/0000-0003-0893-2577)


* Fábio Júnior Clemente Gama

Doutor em Economia Aplicada pela Universidade Federal de Juiz de Fora (UFJF), Brasil.

Professor Adjunto do Departamento de Ciências Econômicas da Universidade Federal do Delta do Parnaíba (UFDPar), Brasil.

E-mail: fabio.gama@ufdpar.edu.br

ORCID(https://orcid.org/0000-0003-3772-411X) 

# Tutorial de Execução dos Scripts

Este tutorial tem como objetivo orientar os usuários sobre como executar o código deste repositório, bem como descrever brevemente os scripts contidos na pasta `R`.


## Índice
1. [Primeiros passos: como executar o código](#como-executar-o-código)
2. [Descrição dos Arquivos](#descrição-dos-arquivos)
3. [Dicas e Solução de Problemas](#dicas-e-solução-de-problemas)

## Pré-Requisitos

Antes de executar os scripts, certifique-se de ter instalado:

- [R](https://www.r-project.org/)
- [RStudio](https://www.rstudio.com/) (opcional, mas recomendado)


## Primeiros passos: como executar o código

1. **Clone ou Baixe o Repositório:**

   Para usuários com conta no Github: utilize o comando abaixo para clonar o repositório via Git:
   
   ```bash
   git clone https://github.com/caio-azevedo/DFP.git
   ```
   Para usuários que não utilizam o Github: baixe o repositório clicando [aqui](https://github.com/caio-azevedo/DFP/archive/refs/heads/master.zip).

2. **Abra o Projeto:**

   Caso tenha feito o dowload do repositório, descompacte o arquivo e abra o projeto `DFP.RProj` no RStudio ou na sua IDE preferida. Em seguida, caso esteja utilizando RStudio, abra a pasta `R` dentro do ambiente do RStudio no painel de Arquivos ("Files").

3. **Execute o Script Principal:**

   Abra o arquivo `main.R` e execute-o (Ctrl + Shift + Enter). Esse script é o ponto de entrada do projeto e fará a execução de todos os demais scripts na ordem correta.

4. **Verifique os Resultados:**

   Após a execução, confira os resultados e outputs gerados (por exemplo, tabelas, gráficos, arquivos de saída).


## Descrição dos Arquivos

O repositório contém diversos scripts que, em conjunto, permitem a replicação dos dados, tabelas e gráficos apresentados no artigo. No diretório [R](https://github.com/caio-azevedo/DFP/tree/master/R) você encontrará todos os scripts em R necessários para a execução do projeto. A seguir, a função de cada arquivo:

- **main.R**  
  **Objetivo:** Orquestrar a execução dos demais scripts na ordem correta.  
  **Descrição:** Ao ser executado, este arquivo chama sequencialmente os scripts responsáveis pela importação, processamento, análise e visualização dos dados, garantindo que o fluxo de trabalho seja mantido sem erros.

- **01-import-and-clean-data.R**  
  **Objetivo:** Importar e preparar os dados da DFP (2022) para análise.  
  **Descrição:**  
  1. Carrega funções personalizadas e o cadastro de empresas (via `cad_cia.R`).  
  2. Define os tipos de balanço a serem processados (BPA e BPP).  
  3. Importa os dados utilizando uma função específica e filtra registros do “último” exercício, realizando um join com o cadastro de empresas.  
  4. Segmenta os dados entre bancos e não bancos, exportando-os em arquivos Excel.  
  5. Gera sumários estatísticos que consolidam informações relevantes para as análises posteriores.

- **02-summary.R**  
  **Objetivo:** Consolidar e ajustar os dados dos balanços.  
  **Descrição:**  
  1. Lê os dados para cada tipo de balanço com a função `read_dados` e remove duplicatas.  
  2. Aplica filtros específicos para tratar os registros da empresa TC S.A., separando os dados em dois grupos (registros normais e os da versão "3").  
  3. Une os conjuntos filtrados em uma lista (`dados_bp`), preparando a base para etapas seguintes.

- **03-tables.R**  
  **Objetivo:** Gerar, formatar e exportar as tabelas com os dados processados.  
  **Descrição:**  
  1. Importa funções auxiliares de formatação e exportação (via `aux_tables.R`).  
  2. Cria diversas tabelas:  
     - **Tabela 2:** Resumo de denominações associadas a códigos de conta, com os 20 principais registros.  
     - **Tabela 3:** Consolidação das terminologias distintas para os balanços de Ativo e Passivo.  
     - **Tabela 4:** Estatísticas (média, mínimo, máximo e mediana) do número de terminologias por código, segmentadas por nível.  
     - **Tabelas 5 e 6:** Exemplos de contas dos níveis quatro e cinco que apresentam apenas uma terminologia.  
     - **Tabela de Frequência:** Registros com maior nomenclatura para a ramificação 5.  
  3. Exporta as tabelas em LaTeX e em um único arquivo Excel.

- **04-graphics.R**  
  **Objetivo:** Realizar análises estatísticas e gerar os gráficos do estudo.  
  **Descrição:** Este script é responsável por processar os dados de forma visual, gerando gráficos que ilustram os principais achados da análise, complementando as informações apresentadas nas tabelas.


## Dicas e Solução de Problemas


- **Ordem de Execução:**  
  O arquivo `main.R` foi desenvolvido para garantir que todos os scripts sejam executados na sequência necessária. Evite executar os scripts individualmente, a menos que tenha certeza da ordem correta.

- **Contribuições:**  
  Se encontrar algum problema ou tiver sugestões de melhoria, sinta-se à vontade para abrir uma issue ou enviar um pull request.


