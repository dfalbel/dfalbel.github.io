---
layout: post
title: Regressão linear bayesiana no R
date : 2015-05-04
tags: [r, estatistica, bayesiana]
--- 

<script type="text/javascript"
  src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>

**Importante:** Esse post é uma **tentativa** de ajustar um modelo de regressão linear bayesiano usando o R. Muito provavelmente existe alguma coisa errada aqui **e** com certeza não é um post completo e uma boa referência.

Para efeitos de exemplo usaremos o banco de dados `mtcars` facilmente acessível pelo R.
A tabela abaixa mostra algumas linhas deste banco de dados.


{% highlight r %}
knitr::kable(head(mtcars))
{% endhighlight %}



|                  |  mpg| cyl| disp|  hp| drat|    wt|  qsec| vs| am| gear| carb|
|:-----------------|----:|---:|----:|---:|----:|-----:|-----:|--:|--:|----:|----:|
|Mazda RX4         | 21.0|   6|  160| 110| 3.90| 2.620| 16.46|  0|  1|    4|    4|
|Mazda RX4 Wag     | 21.0|   6|  160| 110| 3.90| 2.875| 17.02|  0|  1|    4|    4|
|Datsun 710        | 22.8|   4|  108|  93| 3.85| 2.320| 18.61|  1|  1|    4|    1|
|Hornet 4 Drive    | 21.4|   6|  258| 110| 3.08| 3.215| 19.44|  1|  0|    3|    1|
|Hornet Sportabout | 18.7|   8|  360| 175| 3.15| 3.440| 17.02|  0|  0|    3|    2|
|Valiant           | 18.1|   6|  225| 105| 2.76| 3.460| 20.22|  1|  0|    3|    1|

Para simplificar ainda mais, faremos um modelo com apenas apenas uma variável explicativa. Tentaremos prever a variável `mpg` que é o consumo do carro em milhas por galão, pela variável `hp` que é a potência do carro medida em cavalos.

## Especificação do modelo probabilístico:

O primeiro passo em qualquer análise estatística é a especificação do modelo probabilístico. Neste exemplo, o modelo probabilístico especificado é da seguinte forma:

$$mpg_i \sim Normal(\alpha + \beta*hp_i, \sigma^2)$$

para \\(i = 1,2,...,32\\).

No R, especificamos o modelo da seguinte maneira:


{% highlight r %}
verossimilhanca <- function(param, x, y) {
  ### Parametros
  a <- param[1]
  b <- param[2]
  s <- exp(param[3])
  
  ### Log da verossimilhança
  mu <- a + b*x
  log_verossim <- sum(dnorm(y, mu, s, log=TRUE))
  return(log_verossim)
  }
{% endhighlight %}

## Especificando as distribuições priori

Para a análise bayesiana, precisamos especificar distribuições *priori*. Neste exemplo usaremos distribuições Normais para todos os parâmetros. 

No R, a especificação é feita da seguinte forma:


{% highlight r %}
prioris <- function(param){
  a <- param[1]
  b <- param[2]
  s <- exp(param[3])
  aprior = dnorm(a, sd = 20, log = T)
  bprior = dnorm(b, sd = 20, log = T)
  sprior = dnorm(s, sd = 20, log = T)
  return(aprior+bprior+sprior)
  }
{% endhighlight %}

## Definindo a posteriori

O produto da priori pela verossimilhança é chamado de posteriori. E é essa quantidade que será sendo utilizada no MCMC.
Definimos a função posteriori da seguinte forma:


{% highlight r %}
posteriori <- function(param, x, y){
  verossimilhanca(param, x , y) + prioris(param)
}
{% endhighlight %}

Veja que aqui estamos usando a soma e não o produto como escrito acima. Isto porque as funções `prioris` e `verossimilhanca` retornam o logaritmos.

## MCMC

Para fazer o MCMC no R, usaremos o pacote `mcmc`. Os seguintes comando serão usados para obter as estimativas dos parâmetros:


{% highlight r %}
library(mcmc)
param.init <- c(20, -2, 5) # valores iniciais para os parametros
set.seed(43) 
out <- metrop(posteriori, param.init, 1e6, x = mtcars$hp, y = mtcars$mpg) # fazer o MCMC
{% endhighlight %}


## Resultados

Os valores dos parâmetros obtidos foram:


{% highlight r %}
c(out$final[1:2], exp(out$final[3]))
{% endhighlight %}



{% highlight text %}
## [1] 31.38648924 -0.07583737  3.72903702
{% endhighlight %}

Veja que eles são bem parecidos com os valores obtidos ajustando um modelo de regressão linear simples frequentista:


{% highlight r %}
mod <- lm(mpg ~ hp, data = mtcars)
c(mod$coef, sd(mod$residuals))
{% endhighlight %}



{% highlight text %}
## (Intercept)          hp             
## 30.09886054 -0.06822828  3.80014564
{% endhighlight %}

Em outro post fiz algumas análises mais aprofundadas do resultado. [Veja neste link](http://dfalbel.github.io/2015/05/visualizacao-regressao-linear-bayesiana.html)

## Referências:

- [Post no theoretical ecology](https://theoreticalecology.wordpress.com/2010/09/17/metropolis-hastings-mcmc-in-r/)
- [Vignette do pacote mcmc](http://cran.r-project.org/web/packages/mcmc/vignettes/demo.pdf)










