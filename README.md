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

## Índice

1. [Tutorial de Execução dos Scripts](#tutorial-de-execução-dos-scripts)
2. [Como Executar o Código](#como-executar-o-código)
3. [Dicas e Solução de Problemas](#dicas-e-solução-de-problemas)

## Tutorial de Execução dos Scripts

Este tutorial tem como objetivo orientar os usuários sobre como executar o código deste repositório, bem como descrever brevemente os scripts contidos na pasta `R`.

### Estrutura do Repositório

No diretório [R](https://github.com/caio-azevedo/DFP/tree/master/R) você encontrará todos os scripts em R necessários para a execução do projeto. A execução dos scripts é centralizada no arquivo `main.R`, que coordena a chamada dos demais arquivos na ordem correta. A seguir, uma breve descrição dos principais scripts:

- **main.R**:  
  Script principal que orquestra a execução dos demais arquivos. Ao executar este script, todos os outros serão chamados na ordem adequada para que o fluxo do projeto seja mantido.

- **01-import-and-clean-data.R**:  
  O arquivo 01-import-and-clean-data.R é responsável por importar, limpar e pré-processar os dados da DFP referentes ao ano de 2022, preparando-os para as análises posteriores. De forma sucinta, ele realiza as seguintes etapas:

1. **Carregamento de Recursos**:
Inicia carregando funções personalizadas e o cadastro das empresas a partir do script `cad_cia.R`.

2. **Definição dos Balanços**:
Define os tipos de balanço a serem processados, identificados como "BPA" e "BPP".

3. **Importação e Filtragem dos Dados**:
Utiliza a função (personalizada) read_dfp para ler os dados e, em seguida, filtra apenas os registros do "último" exercício. Realiza um join com o cadastro de empresas para garantir a consistência das informações.

4. **Segmentação dos Dados**:
Separa os dados em duas categorias:

- Bancos: Identificados por meio do setor de atividade e nomes específicos.
- Não Bancos: Empresas que não se enquadram como bancos, após a aplicação dos filtros.

5. **Exportação dos Dados Processados**:
Salva os conjuntos de dados resultantes (para bancos e não bancos) em arquivos Excel, facilitando o acesso e a consulta posterior.

6. **Geração de Sumários**:
Cria sumários estatísticos que apresentam métricas como número de empresas, número de contas distintas e média de terminologias por conta, consolidando as informações para análise.

- **02-summary.R**:  
  (Descreva aqui a finalidade deste script, por exemplo, “Realiza a análise estatística e gera gráficos.”)

- **03-tables.R**:  
  (Descreva aqui a finalidade deste script, por exemplo, “Realiza a análise estatística e gera gráficos.”)

- **04-graphics.R**:  
  (Descreva aqui a finalidade deste script, por exemplo, “Realiza a análise estatística e gera gráficos.”)

- **aux_tables.R**:  
  (Descreva aqui a finalidade deste script, por exemplo, “Processa os dados brutos e gera as tabelas intermediárias.”)

- **cad_cia.R**:  
  (Descreva aqui a finalidade deste script, por exemplo, “Realiza a análise estatística e gera gráficos.”)

### Pré-Requisitos

Antes de executar os scripts, certifique-se de ter instalado:

- [R](https://www.r-project.org/)
- [RStudio](https://www.rstudio.com/) (opcional, mas recomendado)


## Como Executar o Código

1. **Clone ou Baixe o Repositório:**

   Utilize o comando abaixo para clonar o repositório via Git:
   
   ```bash
   git clone https://github.com/caio-azevedo/DFP.git
   ```

2. **Abra o Projeto:**

   Abra o projeto `DFP.RProj` no RStudio ou na sua IDE preferida. Navegue até o diretório [R](https://github.com/caio-azevedo/DFP/tree/master/R).

3. **Execute o Script Principal:**

   Abra o arquivo `main.R` e execute-o. Esse script é o ponto de entrada do projeto e fará a execução de todos os demais scripts na ordem correta.

4. **Verifique os Resultados:**

   Após a execução, confira os resultados e outputs gerados (por exemplo, tabelas, gráficos, arquivos de saída).

## Dicas e Solução de Problemas


- **Ordem de Execução:**  
  O arquivo `main.R` foi desenvolvido para garantir que todos os scripts sejam executados na sequência necessária. Evite executar os scripts individualmente, a menos que tenha certeza da ordem correta.

- **Contribuições:**  
  Se encontrar algum problema ou tiver sugestões de melhoria, sinta-se à vontade para abrir uma issue ou enviar um pull request.


