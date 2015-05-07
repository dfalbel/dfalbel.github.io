---
layout: post
title: Estimando parâmetros de um modelo ARMA(1,1) usando MCMC
date : 2015-05-07
tags: [r, estatistica, bayesiana]
--- 


<script type="text/javascript"
   src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>


**Importante:** Esse post é uma **tentativa** de ajustar um modelo ARMA bayesiano usando o R. Muito provavelmente existe alguma coisa errada aqui **e** com certeza não é um post completo e nem uma boa referência.

Os dados para esse post serão simulados usando a função `arima.sim`, assim podemos comparar as estimativas do modelo com os valores utilizados.


{% highlight r %}
y <- arima.sim(list(order = c(1,0,1), ar = 0.7, ma = 0.5), n = 100)
head(y)
{% endhighlight %}



{% highlight text %}
## [1] -3.0207100 -1.6145428 -2.5619564 -3.0964758 -0.6026404  0.7591474
{% endhighlight %}

# Definição do modelo

O modelo ARMA(1,1) é definido da seguinte forma:

$$y_t \sim N(\mu_t, \sigma^2)$$

Para todo o \\(t = 1,2,3,..,200\\). Temos também que:

$$\mu_t = \alpha + \phi y_{t-1} + \theta \epsilon_{t-1}$$

$$\epsilon_{t} = y_t - \mu_t$$

Definindo a verossimilhança no R:


{% highlight r %}
log_verossimilhanca <- function(param, y){
  
  phi <- param[1]
  theta <- param[2]
  sigma <- exp(param[3])
  
  mu <- numeric(length = length(y))
  eps <- numeric(length = length(y))
  eps[1] <- 0
  
  for(i in 2:length(y)){
    mu[i] <- phi*y[i-1] +  theta*eps[i-1]
    eps[i] <- y[i] - mu[i]
  }
  
#  pb$tick() # para a barrinha de progresso
  
  y <- y[-1]
  mu <- mu[-1]
  
  log_verossim <- dnorm(x=y, mean = mu, sd = sigma, log = T)
  sum(log_verossim)
}
{% endhighlight %}

Usaremos para todos os parâmetros a distribuição normal com média 0 e desvio padrão 100. Exceto para o desvio padrão que vamos usar distribuição log-normal. No R, definimos da seguinte maneira:


{% highlight r %}
log_priori <- function(param){
  
  phi <- param[1]
  theta <- param[2]
  sigma <- exp(param[3])
  
  phi_priori <- dnorm(phi, 0, 100, log = T)
  theta_priori <- dnorm(theta, 0, 100, log = T)
  sigma_priori <- dnorm(sigma, 0, 100, log = T)
  
  return(phi_priori + theta_priori + sigma_priori)
}
{% endhighlight %}

Deste modo podemos definir a posteriori como a soma da log-priori e da log-verossimilhança:


{% highlight r %}
log_posteriori <- function(param, y){
  log_verossimilhanca(param, y) + log_priori(param)
}
{% endhighlight %}


# MCMC

Usamos o código a seguir para rodar o MCMC. Iniciamos os valores dos parâmetros com 0.


{% highlight r %}
library(mcmc)
param.init <- c(0, 0, 0) # valores iniciais para os parametros
set.seed(43)
# library(progress) # se quiser colocar uma barrinha de progresso
# pb <- progress_bar$new(total = 1e5)
out <- metrop(log_posteriori, param.init, 1e6, y = as.numeric(y)) # fazer o MCMC
{% endhighlight %}

# Gráficos

Veja a distribuição posteriori dos parâmetros:


{% highlight r %}
library(dplyr)
{% endhighlight %}



{% highlight text %}
## 
## Attaching package: 'dplyr'
## 
## The following object is masked from 'package:stats':
## 
##     filter
## 
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
{% endhighlight %}



{% highlight r %}
library(tidyr)
library(ggplot2)
{% endhighlight %}



{% highlight text %}
## Loading required package: methods
{% endhighlight %}



{% highlight r %}
d <- out$batch %>% data.frame() %>% filter(row_number() > 100000) %>% mutate(X3 = exp(X3))
d2 <- d %>% gather(par, val) %>% group_by(par) %>% summarise(m = mean(val))
d %>% sample_n(50000) %>%
  gather(par, val) %>%
  ggplot(aes(x = val)) + 
  geom_density(adjust = 5, aes(fill = par), alpha = 0.3) + 
  geom_vline(aes(xintercept = m, group = par), color = "red", data = d2)+
  facet_wrap(~par,scales = "free")
{% endhighlight %}

![plot of chunk unnamed-chunk-6](https://dl.dropboxusercontent.com/u/40339739/jekyll/2015-05-05-modelo-arma-verossimilhanca/unnamed-chunk-6-1.png) 

Note que as estimativas pontuais dos parâmetros (reta vermelha) são próximas aos valores reais que usamos na simulação da amostra. 

# Referências

[Exemplos do pacote Laplaces Demon, página 17](http://www.icesi.edu.co/CRAN/web/packages/LaplacesDemon/vignettes/Examples.pdf)
