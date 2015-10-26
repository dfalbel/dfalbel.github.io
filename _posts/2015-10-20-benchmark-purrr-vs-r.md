---
layout: post
title: 'Benchmark do pacote purrr e funções naturais do base R'
date : 2015-10-20
tags: [r, pacotes, purrr, base]
--- 

No mês passado o Hadley fez o lançamento de uma nova versão do pacote `purrr`, este pacote tem como objetivo completar a interface de programação funcional do R. Desta forma, tudo que o `purrr` faz, também pode ser feito usando o `base` R, porém com um código muito maior. Surgiu, então, a pergunta: o que é mais rápido? `purrr` ou `base`?

Antes de ver os resultados, vale ressaltar que este é apenas um teste de velocidade. Tão, ou mais importante do que a velocidade está leitura do código e a consistência da interface. Então não use isso para aprender um ou outro jeito de fazer.

No teste vamos usar os seguintes pacotes:


{% highlight r %}
library(microbenchmark)
library(purrr)
{% endhighlight %}


## Map


{% highlight r %}
vetor <- 1:100
microbenchmark(
  purr = map(vetor, sqrt),
  base_lapply = lapply(vetor, sqrt),
  base_funprog = Map(sqrt, vetor)
)
{% endhighlight %}



{% highlight text %}
## Unit: microseconds
##          expr     min       lq      mean   median       uq      max
##          purr 115.347 132.8405 230.65570 152.1910 255.8315 3696.554
##   base_lapply  36.571  42.7445  57.57207  48.9665  65.7170  135.173
##  base_funprog  48.345  58.3950 112.11341  66.4450  89.3160 3045.689
##  neval
##    100
##    100
##    100
{% endhighlight %}

Observamos que nesta operação, os dois métodos usando as funções `base` tiveram resultados parecidos (apesar do `lapply` ser um pouco mais rápido), o `purrr::map` teve velocidade um pouco menos que 4x pior.

Abaixo está a verificação de que as três formas retornam exatamente o mesmo resultado.


{% highlight r %}
purr <- map(vetor, sqrt)
base_lapply <- lapply(vetor, sqrt)
base_funprog <- Map(sqrt, vetor)

identical(purr, base_lapply)
{% endhighlight %}



{% highlight text %}
## [1] TRUE
{% endhighlight %}



{% highlight r %}
identical(purr, base_funprog)
{% endhighlight %}



{% highlight text %}
## [1] TRUE
{% endhighlight %}



{% highlight r %}
identical(base_lapply, base_funprog)
{% endhighlight %}



{% highlight text %}
## [1] TRUE
{% endhighlight %}

Agora vamos comparar `base` e `purrr` quando simplificamos os resultados para um vetor de números.


{% highlight r %}
microbenchmark(
  purr = map_dbl(vetor, sqrt),
  base_lapply = unlist(lapply(vetor, sqrt)),
  base_sqrt = sqrt(vetor)
)
{% endhighlight %}



{% highlight text %}
## Unit: nanoseconds
##         expr   min      lq     mean  median      uq   max neval
##         purr 35795 37453.5 44759.95 39774.0 46158.5 97679   100
##  base_lapply 36232 37285.5 42635.48 38486.0 46114.5 99180   100
##    base_sqrt   619   665.0   791.23   729.5   809.0  2065   100
{% endhighlight %}

Veja então que ao usar a versão `map_dbl` que simplifica os resultados para um vetor numérico do R, a versão usando `lapply` e usando o `purrr` tornam-se equivalentes.

Obviamente, a versão vetorizada de `sqrt` é muito mais rápida.


{% highlight r %}
purr <- map_dbl(vetor, sqrt)
base_lapply <- unlist(lapply(vetor, sqrt))
base_sqrt <- sqrt(vetor)
identical(purr, base_lapply)
{% endhighlight %}



{% highlight text %}
## [1] TRUE
{% endhighlight %}



{% highlight r %}
identical(purr, base_sqrt)
{% endhighlight %}



{% highlight text %}
## [1] TRUE
{% endhighlight %}



{% highlight r %}
identical(base_lapply, base_sqrt)
{% endhighlight %}



{% highlight text %}
## [1] TRUE
{% endhighlight %}

Enfim, concluí que usando `purr::map`, sabendo qual é a classe do objeto retornado conseguimos praticamente a mesma performance do `base`.

## Reduce

Reduce aplica uma função binária recursivamente por um vetor ou lista. Um exemplo simples de uso pode ser encontrar a soma de todos elementos de um vetor. Faremos aqui então de duas maneiras: usando o `base::Reduce` e o `purrr::reduce`.



{% highlight r %}
vetor <- 1:100
microbenchmark(
  base::Reduce(sum, vetor),
  purrr::reduce(vetor, sum)
)
{% endhighlight %}



{% highlight text %}
## Unit: microseconds
##                       expr     min      lq      mean   median
##   base::Reduce(sum, vetor)  67.078  74.762  93.57927  79.3760
##  purrr::reduce(vetor, sum) 116.191 121.019 193.58939 133.1125
##        uq      max neval
##   96.6310  221.952   100
##  184.9765 1651.187   100
{% endhighlight %}

Veja que neste caso o `purrr::reduce` foi um menos de 2x mais lento.

Vejamos um exemplo um pouco mais complexo em que temos uma lista de vetores numéricos e queremos encontrar os valores que aparecem em todas os vetores.


{% highlight r %}
l <- replicate(5, sample(1:10, 15, replace = T), simplify = FALSE)
str(l)
{% endhighlight %}



{% highlight text %}
## List of 5
##  $ : int [1:15] 6 10 7 3 2 6 1 7 7 3 ...
##  $ : int [1:15] 1 1 7 6 4 6 9 2 4 3 ...
##  $ : int [1:15] 4 10 7 5 2 5 2 4 7 3 ...
##  $ : int [1:15] 4 3 6 10 3 3 3 4 4 5 ...
##  $ : int [1:15] 4 4 7 5 8 3 9 1 6 2 ...
{% endhighlight %}



{% highlight r %}
microbenchmark(
  base::Reduce(intersect, l),
  purrr::reduce(l, intersect)
)
{% endhighlight %}



{% highlight text %}
## Unit: microseconds
##                         expr    min      lq     mean  median      uq
##   base::Reduce(intersect, l) 43.076 44.7460 49.44164 45.8995 54.1695
##  purrr::reduce(l, intersect) 49.104 50.7265 56.60058 51.8865 61.2550
##      max neval
##  138.075   100
##  156.936   100
{% endhighlight %}

Note que agora a performance das duas abordagens fica muito parecida, o `purrr` sendo muito pouco mais lento.

## Conclusão

Ainda não comparei todas as funções do `purrr` com as funções equivalentes do `base`, mas o que deu para perceber é que para operações muito simples o `base` se sai melhor. No entanto, quando as operações são mais complexas, as duas abordagens tornam-se equivalentes em termos de velocidade.








