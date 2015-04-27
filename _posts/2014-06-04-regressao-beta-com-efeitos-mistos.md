---
layout: post
title: Regressão Beta com efeitos mistos no R
date : 2014-06-04
tags: [gamlss, regressão]
---


Esse post não tem objetivo de explicar teoricamente o modelo de regressão Beta, apenas descrever praticamente como aplicá-lo no `R`.


É possível usar no R o pacote `betareg` para ajustar modelos de regressão beta da seguinte forma:


{% highlight r %}
require(betareg)
data("GasolineYield", package = "betareg")

modelo.betareg <- betareg(yield ~ batch + temp | temp, data = GasolineYield)
{% endhighlight %}

Também é possível ajustar o mesmo modelo usando o pacote `gamlss` da maneira a seguir:



{% highlight r %}
require(gamlss)

modelo.gamlss <- gamlss(formula=yield ~ batch + temp, sigma.formula=~temp, data=GasolineYield, family = "BE")
{% endhighlight %}

A vantagem do pacote `gamlss` é que ele permite ajustar modelos com efeitos aleatórios. Os modelos com efeitos aleatórios são usados quando existe algum tipo de dependência entre as observações, como por exemplo em estudos longitudinais.

Para ajustar um modelo de regressão beta com efeitos aleatórios basta:


{% highlight r %}
modelo.re <- gamlss(formula=yield ~ batch + temp + random(as.factor(batch)), sigma.formula=~temp, data=GasolineYield, family = "BE")
{% endhighlight %}

Note o uso do termo `+ random(as.factor(batch))`, é ele que indica para o programa o ajuste do efeito aleatório.













