---
layout: post
title: 'Comparando os pacotes ranger e randomForest'
date : 2016-07-27
tags: [machine-learning]
--- 



Este post tem o objetivo de comparar os pacotes [`ranger`](https://github.com/imbs-hl/ranger) e `randomForest` para treinar
modelos de Random Forest (Durd!). A motivação de fazer esta análise foi observar que 
os dois pacotes têm resultados muitos distintos quando estava usando-os para prever a
probabilidade de um evento. Esta é uma análise de simulação, portanto trata de um problema 
muito específico e não deve ser considerado um resultado para qualquer banco de dados.

# Simulando um banco de dados

Os dados foram simulados usando o seguinte código. Ele cria variáveis aleatórias uniformes
e uma variável resposta de forma quequanto maior cada uma das variáves, maior a probabilidade
de resposta.


{% highlight r %}
library(magrittr)
simulate_data <- function(n){
  X <- data.frame(matrix(runif(n*10), ncol = 10))
  Y <- data.frame(Y = rbinom(n, size = 1, prob = apply(X, 1, sum) %>%
                               pnorm(mean = 5)
                             ) %>% 
                    as.factor()
                               
  ) 
  dplyr::bind_cols(X, Y)
}
{% endhighlight %}


{% highlight r %}
set.seed(98123)
treino <- simulate_data(10000)
teste <- simulate_data(10000)
{% endhighlight %}

# Treinando 

Para comparar os dois pacotes vou treinar dois modelos usando os mesmos parâmetros. Note que a probabilidade de $Y = 1$ é `pnorm(X1 + ... + X10, mean = 5)`. É esse valor que quero estimar com os dois pacotes.

Usando o `ranger` o modelo foi treinado assim:


{% highlight r %}
library(ranger)
modelo_ranger <- ranger(Y ~., data = treino, 
                                num.trees = 100, 
                                mtry = floor(sqrt(10)), 
                                write.forest = T, 
                                min.node.size = 100, 
                                probability = T
                                )
{% endhighlight %}

Usando o `randomForest`:


{% highlight r %}
suppressPackageStartupMessages(library(randomForest))
modelo_randomForest <- randomForest(Y ~., data = treino,
                                    ntree = 100, 
                                    mtry = floor(sqrt(10)),
                                    nodesize = 100
                                    )
{% endhighlight %}

# Comparando as probabilidades estimadas

Vamos agora comparar as probabilidades estimadas na base de treino pelos dois modelos.
O seguinte código foi utilziado para calcular as probabilidades preditas para cada um dos pacotes,
além da probabilidade real de resposta.

{% highlight r %}
pred_ranger <- predict(modelo_ranger, teste)$predictions[,2]
pred_randomForest <- predict(modelo_randomForest, teste, type = "prob")[,2]
prob_real <- apply(teste[,1:10], 1, sum) %>% pnorm(mean = 5)
{% endhighlight %}


{% highlight r %}
library(ggplot2)
{% endhighlight %}



{% highlight text %}
## 
## Attaching package: 'ggplot2'
{% endhighlight %}



{% highlight text %}
## The following object is masked from 'package:randomForest':
## 
##     margin
{% endhighlight %}



{% highlight r %}
data.frame(pred_ranger, pred_randomForest) %>% 
  ggplot(aes(x = pred_ranger, y = pred_randomForest)) + geom_point(size = 0.5)
{% endhighlight %}

![plot of chunk unnamed-chunk-6](/images/2016-07-27-comparando-ranger-e-randomForest/unnamed-chunk-6-1.png)

As probabilidades estimadas até são bastante relacionadas, no entanto os dois modelos foram treinados no mesmo
banco de dados e com os mesmos parâmetros para o algoritmo. Será que isso é esperado?

Veja também a relação da probabilidade estimada pelo `ranger` e pelo `randomForest` quando comparada com a 
probabilidade real.


{% highlight r %}
data.frame(prob_real, pred_ranger, pred_randomForest) %>%
  tidyr::gather(pacote, prob, -prob_real) %>%
  ggplot(aes(x = prob, y = prob_real)) + geom_point(size = 0.1) + facet_wrap(~pacote)
{% endhighlight %}

![plot of chunk unnamed-chunk-7](/images/2016-07-27-comparando-ranger-e-randomForest/unnamed-chunk-7-1.png)

O que mais me chamou atenção é que a probabilidade estimada pelo `randomForest` é muito mais linearmente
relacionada à probabilidade real de Y = 1, enquanto a probabilidade estimada pelo `ranger` apresenta uma
curva no formato de *logito*. Isso é relfletido no erro absoluto médio que fica maior com o pacote `ranger`.

O erro médio absoluto nas probabilidades foi calculado abaixo para cada um dos pacotes:


{% highlight r %}
mean(abs(prob_real - pred_ranger))
{% endhighlight %}



{% highlight text %}
## [1] 0.09555774
{% endhighlight %}



{% highlight r %}
mean(abs(prob_real - pred_randomForest))
{% endhighlight %}



{% highlight text %}
## [1] 0.07355277
{% endhighlight %}

# Por que ocorre esta diferença?

Provavelmente essa diferença está relacionada à forma com que cada pacote estima a probabilidade
de Y = 1. O `ranger` fala explicitamente em usar *probability forests* conforme aparece na
[documentação](http://www.inside-r.org/packages/cran/ranger/docs/ranger): 

> Grow a probability forest as in Malley et al. (2012).

Já para o `randomForest` não encontrei a forma com que eles estima as probabilidades.
Até fiz uma [pergunta no SO](http://stackoverflow.com/q/38618955/3297472) mas ainda não responderam :(

















