---
layout: post
title: "Coeficiente de correlação para variáveis qualitativas e quantitativas"
date: 2014-12-18
tags: [estatistica, correlacao]
--- 

Normalmente, testamos se uma variável quantitativa influencia uma variável qualitativa usando modelo de regressão logística. Mas muitas vezes apenas o teste não é suficiente, é necessário quantificar a relação entre as duas variáveis. 

Quando as duas variáveis são quantitativas usamos o coeficiente de correlação de Pearson, ou Spearman,... Quando ambas são qualitativas, existe a proposta de usar o coeficiente de Crammer-V. Quando uma é qualitativa e outra é quantitativa, não existe um método reconhecido e utilizado globalmente para obter um coeficiente.

Fiz uma pergunta no [Cross Validated](http://stats.stackexchange.com/questions/129585/is-there-a-correlation-index-for-binary-variable-vs-quantitative-variable/129587#129587) e me propuseram o uso da **raiz do coeficiente de determinação do modelo de regressão logística ajustado** como o coeficiente de correlação entre as variáveis.

Aqui, tento avaliar a utilização deste método por meio de algumas simulações. A primeira dificuldade é simular duas variáveis, uma contínua e uma binária que sejam dependentes. Para fazer isso: simulei uma amostra com distribuição normal bivariada e correlação `r` entre os dois vetores, em seguida, para um dos vetores, transformei os números menores do que zero em 0 e os maiores em 1. Depois, ajustei o modelo de regressão logística usando a variável binária como resposta e o vetor correlacionado como variável independente.

No software R, a seguinte função pode ser utlizada para simular e calcular o R-quadrado


{% highlight r %}
library(MASS)
library(magrittr)
library(binomTools)

simulacao_cor <- function(r, size){
  data <- mvrnorm(n=size, mu=c(0, 0), Sigma=matrix(c(1, r, r, 1), nrow=2), 
                  empirical=TRUE) %>% 
    data.frame() 
  data$X1 <- as.numeric(data$X1 < 0)
  
  modelo <- glm(X1 ~ X2, data = data, family = binomial(link = "logit"), 
                control = glm.control(maxit = 10e6))

  R2 <- binomTools::Rsq(modelo)$R2cor
  sqrt(R2)
}
{% endhighlight %}

Os argumentos são:

- `r`: correlação entre os dois vetores
- `size`: tamanho dos vetores

Então para simular, é possível simular o R-quadrado assim: `simulacao_cor(0.6, 1000)`.

A partir dessa função, podemos entender o comportamento da raíz do R-quadrado em função da correlação estabelecida inicialmente.
O gráfico abaixo apresenta uma simulação para 100 correlações diferentes o valor da raíz do R-quadrado obtido.


{% highlight r %}
library(plyr)
library(ggplot2)
{% endhighlight %}



{% highlight text %}
## Loading required package: methods
{% endhighlight %}



{% highlight r %}
d <- aaply(seq(0,1,by = 0.01), .margins = 1, .fun = simulacao_cor, size = 1000)
qplot(x = seq(0,1,by = 0.01), y = d, geom = "point") + 
  xlab("Correlação utilizada") + ylab("Raiz do R-Quadrado Simulada") +
  coord_fixed()
{% endhighlight %}

![plot of chunk unnamed-chunk-2](figure/source/2014-12-18-coeficiente-correlacao-continua-categorica/unnamed-chunk-2-1.png) 

Também é importante gerar variáveis correlacionadas com outras distribuições para verificar se esse comportamento não acontece apenas com a distribuição Normal.

Para isso, o processo é um pouco diferente. Primeiro geramos uma normal bivariada da mesma maneira e emseguida obtemos os quantis da distribuição associados a cada valor gerado. Em seguida pegamos o quantil de qualquer distribuição correspóndente aos quantis que foram selecionados pelo gerador de números aleatórios da normal. A função a seguir pode gerar os valores usando qualquer distribuição, apenas passe para o argumento dist uma função que calcula o quantil da distribuição dadas as probabilidades:



{% highlight r %}
simulacao_cor_dists <- function(r, size, dist){
  data <- mvrnorm(n=size, mu=c(0, 0), Sigma=matrix(c(1, r, r, 1), nrow=2), 
                  empirical=TRUE) %>% 
    data.frame() 
  data$X1 <- as.numeric(data$X1 < 0)
  data$X2 <- dist(pnorm(data$X2))
  modelo <- glm(X1 ~ X2, data = data, family = binomial(link = "logit"), 
                control = glm.control(maxit = 10e6))

  R2 <- binomTools::Rsq(modelo)$R2cor
  sqrt(R2)
}
{% endhighlight %}

Usando a distribuição poisson, obtivemos os seguintes resultados:


{% highlight r %}
d <- aaply(seq(0,1,by = 0.01), .margins = 1, .fun = simulacao_cor_dists, 
           size = 1000, 
           function(x) qpois(x, 3))
qplot(x = seq(0,1,by = 0.01), y = d, geom = "point") + 
  xlab("Correlação utilizada") + ylab("Raiz do R-Quadrado Simulada") +
  coord_fixed()
{% endhighlight %}

![plot of chunk grafico2](figure/source/2014-12-18-coeficiente-correlacao-continua-categorica/grafico2-1.png) 

Veja como este gráfico é muito parecido com o anterior. Usar a raíz do R-quadrado parece ser um índice confiável para ser utilizado como medida de correlação entre variáveis categóricas e contínuas.





