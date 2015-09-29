---
layout: post
title: 'Um modelo simples de análise de sobrevivência usando MCMC no R'
date : 2015-05-21
tags: [r, graficos]
--- 

<script type="text/javascript"
  src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>

Análise de sobrevivência é uma área da estatística que modela variáveis positivas que podem apresentar censura, ou seja observações incompletas.

Neste post, vamos discutir como ajustar um modelo bem simples de análise de sobrevivência, usando MCMC.

# Modelo e dados

Suponha o seguinte modelo. $$T \sim exponencial(\theta)$$ sendo que alguns indivíduos são censurados aleatóriamente, com probabilidade p. A censura neste modelo é não informativa. A interpretação de $$\theta$$ neste caso é a taxa com o que o evento acontece.

Vou gerar alguns dados no R para poder iniciar o estudo. Vamos utilizar uma exponencia com taxa 1/100 e taxa de censura será de aproximadamente 30%.


{% highlight r %}
set.seed(719)
dados <- data.frame(
  t = rexp(100, rate = 1/100), 
  ev = as.numeric(runif(100) > 0.7)
)
{% endhighlight %}

# Verossimilhança

Para fazer análise precisamos ter bem definida qual é a verossimilhança do nossos dados sob o modelo proposto.

Sabemos que se o evento aconteceu, a verossimilhança é a própria densidade ($$f_{\theta}(t)$$). Caso contrário, sabemos que o indivíduo sobreviveu mais do que $$t$$, então a verossimilhança deve ser $$S_{\theta}(t)$$.

Prosseguimos então definindo a log-verossimilhança no R.


{% highlight r %}
L <- function(param, dados){
  # para evitar problemas de espaço vou usar o log do parametro no mcmc
  # por isso o exponencio no início
  theta <- exp(param)
  
  ver <- ifelse(
    dados$ev == 1, 
    yes = dexp(dados$t, theta, log = T),  # isso é f(t)
    no  = pexp(dados$t, theta, log.p = T, lower.tail = F) # lower tail=F indica S(t)
  )
  
  ver <- ifelse(is.nan(ver), -Inf, ver)
  ver <- ifelse(ver == Inf, 0, ver)
  sum(ver)
}
{% endhighlight %}

# Priori

Vou assumir que não tenho nenhuma informação a priori sobre o parâmetro $$\theta$$, então vou uma priori "pouco informativa", ou seja, uma priori com muita variabilidade.

Vamos supor então que $$log(\theta) \sim Normal(0, 1000^2)$$

Definimos a log-priori no R da seguinte maneira.


{% highlight r %}
priori <- function(param){
  theta <- param
  theta <- dnorm(theta, mean = 0, sd = 1000, log = T)
  theta
}
{% endhighlight %}

# Posteriori e MCMC

Pelo teorema de Bayes, é possível ver que a posteriori será proporcional ao produtório da priori pela verossimilhança. No código, como estamos usando sempre o logaritmo, faremos a soma.


{% highlight r %}
posteriori <- function(param, dados){
  priori(param) + L(param, dados)
}
{% endhighlight %}

Para obter uma amostra aleatória da nossa posteriori vamos usar o MCMC. Neste caso, vamos usar o algoritmo de Metropolis-Hastings já implementado no R pela função `metrop`do pacote `mcmc`.


{% highlight r %}
library(mcmc)
set.seed(738)
out <- metrop(posteriori, initial = 0, nbatch = 10000, dados = dados)
{% endhighlight %}

# Um pouco de diagnóstico

A primeira coisa que vi foi a taxa de aceitação: 

{% highlight r %}
out$accept
{% endhighlight %}



{% highlight text %}
## [1] 0.224
{% endhighlight %}
É usado na literatura que uma taxa de 20% é aceitável, portanto estamos com um valor bom.

A seguir vemos um gráfico da cadeia simulada.

{% highlight r %}
plot(ts(out$batch))
{% endhighlight %}

![plot of chunk unnamed-chunk-7](https://dl.dropboxusercontent.com/u/40339739/jekyll/2015-05-20-regressao-exponencial-bayes/unnamed-chunk-7-1.png) 

Aparentemente a cadeia demorou algum tempo para chegar na distribuição estacionária, então, ou vamos ter que usar um período de burn-in ou vamos re-rodar o MCMC começando com valores mais próximos da distribuição estacionária.

A seguir fizemos um gráfico da função de autocorrelação da cadeia. Ele indicará se existe correlação entre as observações da cadeia, o que iria contra uma suposição do MCMC, que é a de que estamos gerando uma amostra i.i.d. da posteriori.


{% highlight r %}
acf(out$batch)
{% endhighlight %}

![plot of chunk unnamed-chunk-8](https://dl.dropboxusercontent.com/u/40339739/jekyll/2015-05-20-regressao-exponencial-bayes/unnamed-chunk-8-1.png) 


# Mais uma rodada


{% highlight r %}
set.seed(172)
out2 <- metrop(out, nbatch = 5000, nspac = 30, dados = dados)
{% endhighlight %}

Rodamos novamente o MCMC, desta vez com 5000 observações, espaçadas de 30 em 30. Também usamos como valor inicial da cadeia o último valor da cadeia anterior.

Agora podemos fazer inferência.

# Inferência

Se fizermos a média da nossa amostra, poderemos obter uma estimativa pontual do parâmetro $$\theta$$ que estamos interessados em estimar.

No R, fazemos assim:


{% highlight r %}
mean(exp(out2$batch))
{% endhighlight %}



{% highlight text %}
## [1] 0.00328351
{% endhighlight %}

Note que exponenciamos a amostra inicialmente. Lembra que estimamos $$log(\theta)$$?
Teríamos então que a média do tempo de sobrevivência que é $$1/\theta$$ é 304.5521205


# Comparando com a abordagem clássica

Na abordagem clássica poderíamos ajustar um modelo similar. No R, poderiamos ter feito da seguinte forma.


{% highlight r %}
library(survival)
mod <- survreg(Surv(t, ev) ~ 1, data = dados, dist = "exp")
summary(mod)
{% endhighlight %}



{% highlight text %}
## 
## Call:
## survreg(formula = Surv(t, ev) ~ 1, data = dados, dist = "exp")
##             Value Std. Error    z         p
## (Intercept)  5.72      0.189 30.3 3.44e-201
## 
## Scale fixed at 1 
## 
## Exponential distribution
## Loglik(model)= -188.1   Loglik(intercept only)= -188.1
## Number of Newton-Raphson Iterations: 5 
## n= 100
{% endhighlight %}

Veja que modelos o log da média neste caso. Então se quiséssemos uma estimativa da média do tempo de sobrevivência, precisamos exponenciar o parâmetro estimado.

Basta então fazermos:


{% highlight r %}
exp(mod$coefficients)
{% endhighlight %}



{% highlight text %}
## (Intercept) 
##    304.6968
{% endhighlight %}

Neste caso as duas abordagens ofereceram estimativas pontuais muito semelhantes. Em breve tentarei comparar também as estimativas intervalares.