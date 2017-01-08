---
layout: post
title: 'Udacity Deep Learning Parte 1: Manipulação de dados'
date : 2017-01-07
tags: [r]
--- 

Faz algum tempo tenho praticado Deep Learnig, fazendo o curso disponível na 
[Udacity](https://br.udacity.com/course/deep-learning--ud730/). O curso é 
muito bom, o professor é um dos pesquisadores do Google Brain! 

Fiz alguns exercícios do curso, e gostaria de divulgar as minhas soluções aqui
no blog. O primeiro exercício, pouco tem a ver com Deep Learning, na verdade a 
tarefa é organizar todas as imagens disponibilizadas [aqui](http://yaroslavvb.blogspot.com.br/2011/09/notmnist-dataset.html).
Esse conjunto de dados é chamado notMINIST.

![](../images/nmn.png)

Vamos lá!

## Download dos dados

O primeiro passo é fazer o download dos dados para a nossa máquina. Temos dois
aquivos, um de treino e um de teste. A diferença é que no conjunto de imagens de
teste, elas foram verificadas de que estava corretamente classificadas, no de treino
não.

Os arquivos são baixados e extraídos com o código a seguir.


{% highlight r %}
library(httr)
url <- 'http://commondatastorage.googleapis.com/books1000/'
# download traning data
GET(paste0(url, "notMNIST_large.tar.gz"), write_disk("notMNIST_large.tar.gz"))
# download test data
GET(paste0(url, "notMNIST_small.tar.gz"), write_disk("notMNIST_small.tar.gz"))
{% endhighlight %}


{% highlight r %}
untar("notMNIST_large.tar.gz")
untar("notMNIST_small.tar.gz")
{% endhighlight %}

Com isso você terá dois diretórios, cada um deles com mais diretórios representando
as letras A a J.

O primeiro problema pedido nos exercícios da Udacity era, abrir algumas imagens e 
verificar que são letras de A a J em diferentes fontes.


{% highlight r %}
library(purrr)
library(magick)
library(magrittr)
{% endhighlight %}


{% highlight r %}
files <- 'notMNIST_large/' %>%
  list.dirs(full.names = TRUE, recursive = FALSE) %>%
  map(~list.files(.x, full.names = TRUE, recursive = FALSE)) %>%
  map_chr(~sample(.x, 1))

par(mfrow=c(5,2), mar = rep(0, 4))
for(i in 1:10)
  plot(image_read(files[i]))
{% endhighlight %}

![plot of chunk unnamed-chunk-2](/images/2017-01-07-udacity-deep-learning-01/unnamed-chunk-2-1.png)

Ok, aparentemente está correto. As imagens estão da forma esperada.

## Transformar os dados para análise

O próximo problema era deixar o banco de dados em um formato melhor para a análise.
Como são muitas imagens, cerca de 52.000 por letra. Vamos pegar uma amostra de
10.000 imagens de cada classe possível e transformar em um banco de dados. 

Vamos usar o formato de array multidimensional do R. Eu, particularmente, nunca 
tinha utilizado esse formato de dados do R, na maioria das vezes usei `data.frame`s
ou `matrix`s mas como neste caso, os dados são imagens, faz mais sentido representá-los
dessa forma.

Note que criamos a função `pre_process` que deixa a imagem na forma que queremos 
guardá-la no R. Como algumas imagens estão com problema e não podem ser ldias, 
fizemos com que essa função tivesse


{% highlight r %}
set.seed(88320)

train_files <- 'notMNIST_large/' %>%
  list.dirs(full.names = TRUE, recursive = FALSE) %>%
  map(~list.files(.x, full.names = TRUE, recursive = FALSE)) %>%
  map(~sample(.x, 10000)) %>%
  unlist() %>% 
  setNames(stringr::str_sub(., 17, 17))

test_files <- 'notMNIST_small/' %>%
  list.dirs(full.names = TRUE, recursive = FALSE) %>%
  map(~list.files(.x, full.names = TRUE, recursive = FALSE)) %>%
  unlist() %>% 
  setNames(stringr::str_sub(., 17, 17))

pre_process <- . %>%
  map(plyr::failwith(NULL, function(x) {
    x <- x %>% 
      image_read() %>%
      as.raster() %>%
      apply(c(1,2), col2rgb) 
    x[1,,,drop = FALSE]
  })) %>%
  abind::abind(along = 1)

train_data <- pre_process(train_files)
test_data <- pre_process(test_files)

saveRDS(train_data, 'train_dataset.rds')
saveRDS(test_data, 'test_dataset.rds')
{% endhighlight %}




Esse trecho de código leva cerca de 2h para terminar de rodar no meu computador
(MacBook Air 4GB RAM). Se no seu computador não rodar, você sempre pode diminuir 
o tamanho da amostra utlizada.

No final desse processo você terá dois arquivos `.rds`. Cada um deles é um array
3-dimensional. As labels estão guardadas nas dimensões do array.

Vamos verificar que os dados foram transformados corretamente. Para isso vamos 
plotar uma amostra das imagens.


{% highlight r %}
amostra <- sample(1:dim(train_data)[1], size = 10) 
amostra <- train_data[amostra,,]

par(mfrow=c(5,2), mar = rep(0, 4))
for(i in 1:10)
  plot(as.raster(amostra[i,,]/255))
{% endhighlight %}

![plot of chunk unnamed-chunk-5](/images/2017-01-07-udacity-deep-learning-01/unnamed-chunk-5-1.png)

Também vamos verificar a distribuição das letras, ver se temos maisou menos a mesma
quantidade de cada uma, tanto na base de testes como da na de treino.


{% highlight r %}
table(dimnames(train_data)[[1]])
{% endhighlight %}



{% highlight text %}
## 
##     A     B     C     D     E     F     G     H     I     J 
##  9998 10000 10000 10000 10000 10000 10000 10000 10000 10000
{% endhighlight %}



{% highlight r %}
table(dimnames(test_data)[[1]])
{% endhighlight %}



{% highlight text %}
## 
##    A    B    C    D    E    F    G    H    I    J 
## 1872 1873 1873 1873 1873 1872 1872 1872 1872 1872
{% endhighlight %}

Ok. Tudo parece correto.

Por considerações a respeito de otimização, é melhor que os valores das matrizes
estejam entre -1 e 1 ao invés de 0 a 255 como é a forma gerada pelo R.

Para fazer a conversão usamos a função uma função bem simples.


{% highlight r %}
train_data <- (train_data - (255/2))/(255/2)
test_data <- (test_data - (255/2))/(255/2)
{% endhighlight %}

## Ajuste um off-the-shelf classifier

Neste exercício o objetivo era treinar um classificador *off-the-shelf*. Resolvi
utilizar o `xgboost` (Gradient Boosted Trees), pois estudei essa técnica a pouco
tempo e ela é fácil de utilizar, e não é necessário alterar os parâmetros para 
obter um resultado satisfatório.

Em primeiro lugar, como o `xgboost` precisa de uma matriz, vamos transformar os nossos
dados de um array 3-dimensional para uma matriz. Basicamente vamos representar cada
um dos 784 pixels por uma coluna diferente. As classes precisam ser passadas ao
algoritmo em um vetor numérico de 0 ao número de categorias.


{% highlight r %}
# Tranformar em matriz
train_x <- t(apply(train_data, 1, c))
train_y <- as.numeric(as.factor(dimnames(train_data)[[1]])) - 1

test_x <- t(apply(test_data, 1, c))
test_y <- as.numeric(as.factor(dimnames(test_data)[[1]])) - 1
{% endhighlight %}

Agora o treino do algoritmo. O único parâmetro que alterei foi o número de iterações
para que não demorasse muito para treinar.


{% highlight r %}
library(xgboost)
xg <- xgboost(data = train_x, label = train_y, nrounds = 10, 
              objective = 'multi:softmax', num_class = 10)
{% endhighlight %}


{% highlight r %}
# Accuracy Train
train_pred <- predict(xg, newdata = train_x)
sum(train_pred == train_y)/length(train_y)

# Accuracy Test
test_pred <- predict(xg, newdata = test_x)
sum(test_pred == test_y)/length(test_y)
{% endhighlight %}

Com esse algoritmo obtive o seguinte resultado:

* Acerto na base de treino: 88,45%
* Acerto na base de teste: 91,87%

Nos próximos posts, vamos ajustar modelos mais complexos que terão acerto superior 
ao obtido aqui. No entanto, note que o acerto aqui já foi bem satisfatório! 90% das
imagens estão sendo classificadas corretamente!




