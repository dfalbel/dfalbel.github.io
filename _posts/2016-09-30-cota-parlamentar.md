---
layout: post
title: 'Uso da cota parlamentar'
date : 2016-09-30
tags: [r]
--- 



Na semana passada adicionei o repositório [cota-parlamentar](https://github.com/dfalbel/cota-parlamentar) no meu [github](https://github.com/dfalbel).

Neste repositório é possível encontrar uma base de os dados relativa aos gastos parlamentares registrados na Câmara dos Deputados. Esses dados são disponibilizados *abertamente* no [site do câmara](http://www2.camara.leg.br/transparencia/cota-para-exercicio-da-atividade-parlamentar/dados-abertos-cota-parlamentar). Digo *abertamente* pois, o formato disponibilizado (xml), apesar de completo, é longe de ser o ideal para fazer alguma análise.

Portanto, o que está no meu repositório, é o banco de dados *parseado* e em csv, em formato de colunas. 

## Ler

Os dados têm 48MB e podem ser lidos tranquilamente no R da seguinte forma:


{% highlight r %}
dados <- readr::read_csv("https://github.com/dfalbel/cota-parlamentar/blob/master/data/cota-parlamentar-2016.csv?raw=true")
{% endhighlight %}


## Análise mais simples

Deputados que mais gastaram em 2016:


{% highlight r %}
library(tidyverse)
dados %>%
  group_by(txNomeParlamentar, sgPartido) %>%
  summarise(vlrLiquido = sum(vlrLiquido, na.rm = T)) %>%
  ungroup() %>%
  arrange(desc(vlrLiquido)) %>%
  slice(1:10)
{% endhighlight %}



{% highlight text %}
## # A tibble: 10 × 3
##    txNomeParlamentar sgPartido vlrLiquido
##                <chr>     <chr>      <dbl>
## 1              ROCHA      PSDB   424778.6
## 2    HIRAN GONÇALVES        PP   404409.8
## 3       ZENAIDE MAIA        PR   386474.9
## 4     CARLOS ANDRADE       PHS   385338.9
## 5     ANTÔNIO JÁCOME       PTN   380091.1
## 6         EDIO LOPES        PR   379983.8
## 7        HILDO ROCHA      PMDB   379095.8
## 8      SÁGUAS MORAES        PT   377859.1
## 9    VINICIUS GURGEL        PR   377258.6
## 10   NILTON CAPIXABA       PTB   375241.1
{% endhighlight %}

Deputados que menos gastaram em 2016:


{% highlight r %}
dados %>%
  group_by(txNomeParlamentar, sgPartido) %>%
  summarise(vlrLiquido = sum(vlrLiquido, na.rm = T)) %>%
  ungroup() %>%
  arrange(vlrLiquido) %>%
  slice(1:10)
{% endhighlight %}



{% highlight text %}
## # A tibble: 10 × 3
##       txNomeParlamentar sgPartido vlrLiquido
##                   <chr>     <chr>      <dbl>
## 1      ROSÂNGELA CURADO       PDT   -1335.98
## 2        FÁTIMA BEZERRA        PT     -21.49
## 3        MERLONG SOLANO        PT      11.73
## 4         MIGUEL CORRÊA        PT      14.13
## 5    REINHOLD STEPHANES       PSD      53.52
## 6    SEBASTIÃO OLIVEIRA        PR     108.24
## 7  MARCO ANTÔNIO CABRAL      PMDB     133.52
## 8        SERGIO ZVEITER      PMDB     314.11
## 9          JOSIAS GOMES        PT     899.29
## 10  CAPITÃO FÁBIO ABREU       PTB     963.67
{% endhighlight %}

## Próximos passos

* No site são disponibilizados arquivos de diversos anos. No repositório, só disponibilizei o arquivo do ano de 2016.
* Esses dados são atualizados diariamente. Ainda não tive tempo de criar uma rotina de atualização automática.
* Ainda vou fazer mais posts de análises desse banco de dados.

