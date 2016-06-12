---
layout: post
title: 'Validação Adversária'
date : 2016-06-12
tags: [modelagem, randomForest]
--- 



[Esse post](http://fastml.com/adversarial-validation-part-one/) do [FastML](http://fastml.com/) fez uma 
análise bem interessante sobre como são as bases de validação/avaliação de torneios de Machine Learning 
como os que aparecem no [Kaggle](https://www.kaggle.com/) ou o do [Numerai](https://numer.ai/). Ele comenta
como em algumas competições, a base de validação (base em que são avaliadas as predições para o cálculo
do seu score) possuem comportamento diferente da base utilizada para treino. Nesse post, que é a primeira parte
da análise do Zygmund, ele mostra o exemplo de uma competição do Santander, que aconteceu no Kaggle em
que as duas bases de treino e teste possuem o mesmo comportamento. 

Na [parte 2 do post](http://fastml.com/adversarial-validation-part-two/), ele mostra que a base de treino do 
[Numerai](https://numer.ai/), aquela da qual eles deixam a variável `target` disponível é bem diferente do banco de teste, que eles chamam de *tournament dataset*. Até o próprio Numerai, recomendou a leitura deste post no twitter.

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">Interesting idea on adversarial validation with Numerai data on <a href="https://twitter.com/fastml">@fastml</a> <a href="https://t.co/dqb0WupiMH">https://t.co/dqb0WupiMH</a></p>&mdash; Numerai (@numerai) <a href="https://twitter.com/numerai/status/740709465964478464">June 9, 2016</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

Resolvi replicar o experimento dele para verificar o resultado encontrado por ele. Utilizei a mesma idéia
proposta pelo FastMl: Empilhar a base do torneio e a base de treino e tentar criar um modelo para prever se
uma observação é da base de treino. Se o acerto do modelo for perto de 50%, quer dizer que as bases são muito parecidas. Se o modelo conseguir acertar de qual base de dados a observação é proveniente, significa que os
bancos de dados possuem características muito diferentes.

# Leitura das bases

Usei as bases que estão disponíveis no Numerai neste [link](https://numer.ai/). Também as deixei dispoíveis 
no [repositório do blog](https://github.com/dfalbel/dfalbel.github.io/tree/master/data/numerai-datasets).


{% highlight r %}
library(dplyr)
{% endhighlight %}



{% highlight text %}
## 
## Attaching package: 'dplyr'
## 
## The following objects are masked from 'package:stats':
## 
##     filter, lag
## 
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
{% endhighlight %}



{% highlight r %}
train_data <- read.csv("../data/numerai-datasets/numerai_training_data.csv")
test_data <- read.csv("../data/numerai-datasets/numerai_tournament_data.csv")
{% endhighlight %}

Empilhando as duas e criando a resposta.


{% highlight r %}
data <- bind_rows(
  train_data %>% select(-target) %>% mutate(TRAIN = TRUE),
  test_data %>% select(-t_id) %>% mutate(TRAIN = FALSE)
)
data$TRAIN <- as.factor(data$TRAIN)
{% endhighlight %}

# Visualização

Para visualizar as possíveis diferenças entre a base de treino e de torneio, utilizamos componentes principais para reduzir a 
dimensionalidade. Com isso, das 21 variáveis que possíamos inicialmente, obtivemos 2, que podem ser facilmente ser representadas
em um gráfico de dispersão.


{% highlight r %}
pca <- princomp(data %>% select(-TRAIN))
pca_df <- pca$scores %>%
  data.frame()
pca_df$TRAIN <- data$TRAIN
{% endhighlight %}


{% highlight r %}
library(ggplot2)
{% endhighlight %}



{% highlight text %}
## Warning: package 'ggplot2' was built under R version 3.2.3
{% endhighlight %}



{% highlight r %}
pca_df %>% 
  arrange(runif(nrow(.))) %>%
  ggplot(aes(Comp.1, Comp.2)) + geom_point(aes(color = TRAIN), size = 0.2, alpha = 0.3)
{% endhighlight %}

![plot of chunk unnamed-chunk-4](/images/2016-06-09-validacao-adversaria/unnamed-chunk-4-1.png) 

Note que com essas duas dimensões não é perceptível a diferença entre os dois bancos de dados.

# Ajustando o modelo

Aqui usei um modelo de random forest por meio do pacote `caret`.


{% highlight r %}
library(randomForest)
{% endhighlight %}



{% highlight text %}
## randomForest 4.6-12
## Type rfNews() to see new features/changes/bug fixes.
## 
## Attaching package: 'randomForest'
## 
## The following object is masked from 'package:ggplot2':
## 
##     margin
## 
## The following object is masked from 'package:dplyr':
## 
##     combine
{% endhighlight %}



{% highlight r %}
modelo <- randomForest(TRAIN ~ ., data = data, ntree = 100, mtry = sqrt(21))
modelo
{% endhighlight %}



{% highlight text %}
## 
## Call:
##  randomForest(formula = TRAIN ~ ., data = data, ntree = 100, mtry = sqrt(21)) 
##                Type of random forest: classification
##                      Number of trees: 100
## No. of variables tried at each split: 5
## 
##         OOB estimate of  error rate: 20.52%
## Confusion matrix:
##       FALSE  TRUE class.error
## FALSE  6054 25723 0.809484848
## TRUE    567 95753 0.005886628
{% endhighlight %}

Na tabela acima, as linhas repesentam os valores verdadeiros e as colunas as categorias previstas pelo
modelo de random forest. Note que das 96.320 observações da base de treino, o modelo classifica apenas
589 (menos de 1%) como base de teste. 


{% highlight r %}
library(ROCR)
{% endhighlight %}



{% highlight text %}
## Carregando pacotes exigidos: gplots
{% endhighlight %}



{% highlight text %}
## Warning: package 'gplots' was built under R version 3.2.4
{% endhighlight %}



{% highlight text %}
## 
## Attaching package: 'gplots'
## 
## The following object is masked from 'package:stats':
## 
##     lowess
## 
## Carregando pacotes exigidos: methods
{% endhighlight %}



{% highlight r %}
pred <- prediction(predict(modelo, type = "prob")[,2], data$TRAIN)
as.numeric(performance(pred , "auc")@y.values)
{% endhighlight %}



{% highlight text %}
## [1] 0.8351809
{% endhighlight %}

Veja também que o AUC (área sobre a curva ROC) foi de 0.84, muito próxima da relatada no post do FastML. Se a base de testes fosse realmente uma
amostra aleatória da base de treino, esse número deveria ser próximo de 0.5.

Enfim, esse resultado é importante pois, se as duas bases possuem comportamentos diferentes, é difícil
saber qual o score que você teria no final do torneio, apenas avaliando o seu erro na base de treino.
A recomendação do FastMl é validar o seu modelo nestas observações da base de treini que o modelo de random forest classificou errôneamente como base de teste, desta forma você teria uma estimativa mais
precisa do erro no final do torneio.
