---
layout: post
title: 'Pacote rslp'
date : 2016-07-15
tags: [text-mining]
--- 



No [meu github](https://github.com/dfalbel/) você pode encontrar o pacote [`rslp`](https://github.com/dfalbel/rslp).

Esse pacote implementa o algoritmo *Stemming Algorithm for the Portuguese Language* descrito [neste artigo](http://homes.dcc.ufba.br/~dclaro/download/mate04/Artigo%20Erick.pdf) escrito por Viviane Moreira Orengo e Christian Huyck.

A ideia do algoritmo de stemming é muito bem explciada pelo diagrama abaixo.

![Schema](/images/schema-rslp.PNG)

## Instalando

O pacote pode ser instalado usando o `devtools`, pois ainda não está disponível no CRAN.


{% highlight r %}
devtools::install_github("dfalbel/rslp")
{% endhighlight %}

## Usando

As únicas funções importantes do pacote são: `rslp` e `rslp_doc`.
A primeira, recebe um vetor de palavras e retorna um vetor de palavras *stemizadas*. Já a segunda recebe um vetor de sentenças e retorna o mesmo vetor com as palavras *stemizadas*.

Veja os exemplos abaixo:


{% highlight r %}
library(rslp)
words <- c("balões", "aviões", "avião", "gostou", "gosto", "gostaram")
rslp(words)
{% endhighlight %}



{% highlight text %}
## [1] "bal"  "avi"  "avi"  "gost" "gost" "gost"
{% endhighlight %}


{% highlight r %}
docs <- c(
  "coma frutas pois elas fazem bem para a saúde.",
  "não coma doces, eles fazem mal para os dentes."
  )
rslp_doc(docs)
{% endhighlight %}



{% highlight text %}
## [1] "com frut poi el faz bem par a saud."  
## [2] "nao com doc, ele faz mal par os dent."
{% endhighlight %}






