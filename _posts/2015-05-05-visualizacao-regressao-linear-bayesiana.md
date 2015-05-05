---
layout: post
title: Visualização de resultados de um modelo linear bayesiano
date : 2015-05-05
tags: [r, estatistica, bayesiana]
--- 

<script type="text/javascript"
  src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>

**Importante:** Esse post é uma **tentativa** de ajustar um modelo de regressão linear bayesiano usando o R. Muito provavelmente existe alguma coisa errada aqui **e** com certeza não é um post completo e nem uma boa referência.

Em um outro [post](http://dfalbel.github.io/2015/05/regressao-linear-bayesiana.html) ajustei um modelo de regressão linear bayesiano no R. Neste aqui, vou usar os resultados do ajuste anterior para fazer alguns gráficos que ajudam a visualizar os resultados do modelo bayesiano.



Considere o output do modelo ajustado no [post](http://dfalbel.github.io/2015/05/regressao-linear-bayesiana.html) anterior, que foi obtido com o seguinte comando:


{% highlight r %}
out <- metrop(posteriori, param.init, 1e6, x = mtcars$hp, y = mtcars$mpg)
{% endhighlight %}

# Gráfico da distribuição empírica dos parâmetros

O algoritmo de MCMC que utilizamos gerou uma amostra aleatória da distribuição dos parâmetros \\(\alpha, \beta \\) e \\(\sigma^2  \\). Então, a partir desta amostra, podemos obter a distribuição empírica dos parâmetros estimados. Essa amostra pode ser obtida a partir do objeto `out` em seu atributo `batch`.

Para construir este gráfico passei pelos seguitnes passos:

- retirar as primeiras observações da amostra, uma vez que normalmente quando fazemos MCMC esperamos a cadeia "aquecer".
- exponenciar as observações do parâmetero \\( \sigma^2 \\) já que no algoritmo utilizamos o seu logaritmo por problemas de definição de espaço.



O código a seguir faz as transformações necessárias no output do `mcmc` para podermos plotar o gráfico.


{% highlight r %}
library(tidyr)
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(ggplot2))
d <- out$batch %>% data.frame() %>% filter(row_number() > 10000) %>% mutate(X3 = exp(X3))
names(d) <- c(expression(alpha), expression(beta), expression(sigma ^2))
d2 <- d %>% gather(par, val) %>% group_by(par) %>% summarise(m = mean(val))
x <- d %>% sample_n(50000) %>%
  gather(par, val) %>% 
  ggplot(aes(x = val)) + 
  geom_density(adjust = 5) + 
  geom_vline(aes(xintercept = m, group = par), color = "red", data = d2)+
  facet_wrap(~par,scales = "free")
facet_wrap_labeller(x, labels = c(expression(alpha), expression(beta), expression(sigma^2)))
{% endhighlight %}



{% highlight text %}
## Loading required package: gridExtra
## Loading required package: grid
{% endhighlight %}

![plot of chunk unnamed-chunk-4](https://dl.dropboxusercontent.com/u/40339739/jekyll/2015-05-05-visualizacao-regressao-linear-bayesiana/unnamed-chunk-4-1.png) 

A linha vermelha indica a estimativa pontual, e a curva a distribuição empírica estimada. Note que assim como na teoria clássica, os parâmetros \\( \alpha  \\) e \\( \beta  \\) aparentam ter distribuição Normal.

# Distribuição conjunta dos parâmetros

Também é importante visualizarmos qual é a distribuição conjunta dos parâmetros estimados. O gráfico a seguir mostra as três combinações possíveis: \\( \alpha  \\) e \\( \beta  \\), \\( \alpha  \\) e \\( \sigma^2  \\), \\( \beta  \\) e \\( \sigma^2  \\).

Veja que esses resultados lembram muito bem a teoria clássica. \\( \alpha  \\) e \\( \beta  \\) possuem uma correlação alta, no entanto \\( \alpha  \\) e \\( \beta  \\) são independentes de \\( \sigma^2  \\).

O código a seguir pode ser utilizado para construir o gráfico no R:


{% highlight r %}
g1 <- out$batch %>% data.frame() %>%  
  filter(row_number() > 10000) %>% sample_n(50000) %>%
  ggplot(aes(x = X1, y = X2)) + geom_density2d(adjust = 5) + geom_point() + 
  xlab(expression(alpha)) + ylab(expression(beta))


g2 <- out$batch %>% data.frame() %>% mutate(X3 = exp(X3)) %>%
  filter(row_number() > 10000) %>% sample_n(50000) %>%
  ggplot(aes(x = X1, y = X3)) + geom_density2d(adjust = 5) + geom_point() + 
  xlab(expression(alpha)) + ylab(expression(sigma ^2))

g3 <- out$batch %>% data.frame() %>% mutate(X3 = exp(X3)) %>%
  filter(row_number() > 10000) %>% sample_n(50000) %>%
  ggplot(aes(x = X2, y = X3)) + geom_density2d(adjust = 5) + geom_point() + 
  xlab(expression(beta)) + ylab(expression(sigma ^ 2))

gridExtra::grid.arrange(g1, g2, g3, ncol=3)
{% endhighlight %}

![plot of chunk unnamed-chunk-5](https://dl.dropboxusercontent.com/u/40339739/jekyll/2015-05-05-visualizacao-regressao-linear-bayesiana/unnamed-chunk-5-1.png) 
 
# Referências

A seguinte função, utilizada para fazer o primeiro gráfico deste post, 


{% highlight r %}
facet_wrap_labeller <- function(gg.plot,labels=NULL) {
  #works with R 3.0.1 and ggplot2 0.9.3.1
  require(gridExtra)

  g <- ggplotGrob(gg.plot)
  gg <- g$grobs      
  strips <- grep("strip_t", names(gg))

  for(ii in seq_along(labels))  {
    modgrob <- getGrob(gg[[strips[ii]]], "strip.text", 
                       grep=TRUE, global=TRUE)
    gg[[strips[ii]]]$children[[modgrob$name]] <- editGrob(modgrob,label=labels[ii])
  }

  g$grobs <- gg
  class(g) = c("arrange", "ggplot",class(g)) 
  g
}
{% endhighlight %}
 
Foi copiada de [uma pergunta do stackoverflow](http://stackoverflow.com/a/16964861/3297472).

















