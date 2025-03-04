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

1. [Tutorial de Execução dos Scripts](#tutorial-de-execucao-dos-scripts)
2. [Descrição dos Dados](#descrição-dos-dados)
3. [Instalação](#instalação)

## Tutorial de Execução dos Scripts

Este tutorial tem como objetivo orientar os usuários sobre como executar o código deste repositório, bem como descrever brevemente os scripts contidos na pasta `R`.

### Estrutura do Repositório

No diretório [R](https://github.com/caio-azevedo/DFP/tree/master/R) você encontrará todos os scripts em R necessários para a execução do projeto. A execução dos scripts é centralizada no arquivo `main.R`, que coordena a chamada dos demais arquivos na ordem correta. A seguir, uma breve descrição dos principais scripts:

- **main.R**:  
  Script principal que orquestra a execução dos demais arquivos. Ao executar este script, todos os outros serão chamados na ordem adequada para que o fluxo do projeto seja mantido.

- **[Script_2].R**:  
  (Descreva aqui a finalidade deste script, por exemplo, “Processa os dados brutos e gera as tabelas intermediárias.”)

- **[Script_3].R**:  
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

   Abra o projeto no RStudio ou na sua IDE preferida. Navegue até o diretório `R`.

3. **Execute o Script Principal:**

   Abra o arquivo `main.R` e execute-o. Esse script é o ponto de entrada do projeto e fará a execução de todos os demais scripts na ordem correta.

4. **Verifique os Resultados:**

   Após a execução, confira os resultados e outputs gerados (por exemplo, tabelas, gráficos, arquivos de saída).

## Dicas e Solução de Problemas


- **Ordem de Execução:**  
  O arquivo `main.R` foi desenvolvido para garantir que todos os scripts sejam executados na sequência necessária. Evite executar os scripts individualmente, a menos que tenha certeza da ordem correta.

- **Contribuições:**  
  Se encontrar algum problema ou tiver sugestões de melhoria, sinta-se à vontade para abrir uma issue ou enviar um pull request.


## Descrição dos Dados



## Instalação
