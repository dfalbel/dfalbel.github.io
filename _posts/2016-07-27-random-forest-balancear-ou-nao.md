---
layout: post
title: 'Random Forest: Balancear a base ou não?'
date : 2016-07-27
tags: [machine-learning]
--- 



Em alguns problemas, a taxa de resposta é muito pequena então, para possuir uma
quantidade suficiente de resposta é necessário um banco de dados muito grande. Por exemplo, imagine um problema de classificação em que a taxa de resposta é de apenas
0,1%. Para termos pelo menos 1000 respostas precisamos de uma base de dados de 
no mínimo 1.000.000 indivíduos. Ainda poderíamos dizer que 1000 respostas é pouco e
dessa forma precisaríamos de uma base ainda maior.

Uma possível solução para este problema é balancear a base, ou seja: pegar todas as respostas e uma amostra de não-respostas. 

Neste post, gostaria de avaliar o impacto do balanceamento no desempenho do modelo.

# Simulando um banco de dados

Os dados foram simulados usando o seguinte código. Ele cria variáveis aleatórias uniformes
e uma variável resposta de forma que quanto maior cada uma das variáves, maior a probabilidade
de resposta. Considerei um valor 


{% highlight r %}
library(magrittr)
simulate_data <- function(n){
  X <- data.frame(matrix(runif(n*10), ncol = 10))
  Y <- data.frame(Y = rbinom(n, size = 1, prob = apply(X, 1, sum) %>%
                               pnorm(mean = 8)
                             ) %>% 
                    as.factor()
                               
  ) 
  dplyr::bind_cols(X, Y)
}
{% endhighlight %}


{% highlight r %}
set.seed(98123)
treino <- simulate_data(100000)
teste <- simulate_data(100000)
{% endhighlight %}

Esse código gerou duas bases de dados com aproximadamente 1% de respostas ou seja 1% de Y = 1.

# Treinando 

Vamos comparar alguns modelos treinados em diferentes taxas de balanceamento com o modelo treinado na base inteira. Os resultados sempre serão avaliados na base de dados chamada teste. 

Primeiramente vamos definir uma função balancear, que equilibra a taxa de respostas na base de acordo com um parâmetro `p`.


{% highlight r %}
suppressPackageStartupMessages(library(dplyr))
balancear <- function(df, p){
  n_resposta <- sum(df$Y == "1")
  n_n_resposta <- floor((1 - p)*n_resposta/p)
  
  bind_rows(
    df %>% filter(Y == "1"),
    df %>% filter(Y == "0") %>% sample_n(n_n_resposta)
  )
}
{% endhighlight %}

Agora vamos rodar o modelo para algumas taxas de desbalanceamento para ver o que acontece com o desempenho. O modelo treinado será o random forest usando o pacote `randomForest`. A classificação será avaliada com base na base de treino que está na proporção original da base de treino (com 1% approx. de resposta).


{% highlight r %}
suppressPackageStartupMessages(library(randomForest))
taxas <- c(0.05, 0.1, 0.25, 0.5)
desempenhos <- plyr::laply(taxas, function(taxa){
  df <- balancear(treino, p = taxa)
  
  modelo <- randomForest(Y ~., data = df,
                       ntree = 100, 
                       mtry = floor(sqrt(10)),
                       nodesize = 100
  )
  
  pred_base <- predict(modelo, df, type = "prob")[,2]
  cortes <- plyr::laply(sort(pred_base), function(p){
    tabela <- table(pred_base > p, df$Y, useNA = "always")
    ks <- tabela[1,1]/sum(tabela[,1]) + tabela[2,2]/sum(tabela[,2]) - 1
    ks
  })
  corte <- max((sort(pred_base)[cortes == max(cortes)]))
  
  pred_teste <- predict(modelo, teste, type = "prob")[,2] > corte
  tabela <- table(pred_teste, teste$Y, useNA = "always")
  tabela[1,1]/sum(tabela[,1]) + tabela[2,2]/sum(tabela[,2]) - 1
})
names(desempenhos) <- taxas
desempenhos
{% endhighlight %}



{% highlight text %}
##      0.05       0.1      0.25       0.5 
## 0.4942124 0.5859000 0.6220510 0.6143771
{% endhighlight %}

A tabela acima mostra o desempenho do modelo em cada uma das taxas de desbalanceamento.
Veja que o modelo desbanaceado com taxa de 25% ficou melhor na base de teste do que o modelo
construído com a taxa de 5%, mais próximo da taxa original da base. Claro que isso é uma simulação com apenas uma repetição, e o correto seria repetir o experimento para diversas bases diversas vezes, mas acredito que já é possível ter uma ideia do que acontece. 

> Por esse estudo, parece que balancear a base melhora o desempenho do modelo. Parece que para taxas acima de 25% de resposta o desempenho já é muito semelhante.

Com esse resultado, acredito que treinar o modelo em uma base com 50% de resposta seja melhor, pois você terá uma base menor. Neste caso, um modelo treinado com 2% da base foi tão eficaz quanto um modelo treinado em toda a base.

# Mas e quando estamos estimando probabilidades?

Em muitos problemas, estamos estimando probabilidades ao invés de classificar observações. Neste caso esbarramos em um outro problema. Como voltar a probabilidade à escala original. Nesta simulação seria estimar a probabilidade de Y = 1 dados todas as covariáveis X.

Por exemplo compare as probabilidades pelo modelo balanceado com taxa de 50% de resposta e 
a probabilidade real de resposta (dada pela simulação).


{% highlight r %}
treino_bal <- balancear(treino, 0.5)
modelo <- randomForest(Y ~., data = treino_bal,
                       ntree = 100, 
                       mtry = floor(sqrt(10)),
                       nodesize = 100
  )
prob_real_teste <- apply(teste[,1:10], 1, sum) %>% pnorm(8)
prob_modelo <- predict(modelo, teste, type = "prob")[,2]
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
data.frame(prob_real_teste, prob_modelo) %>%
  ggplot(aes(x = prob_modelo, y = prob_real_teste)) + 
  geom_point(size = 0.1) +
  stat_smooth()
{% endhighlight %}

![plot of chunk unnamed-chunk-5](/images/2016-07-27-random-forest-balancear-ou-nao/unnamed-chunk-5-1.png)

As probabilidades não estão relacionadas linearmente. Ainda não encontrei uma solução para
retornar à escala original de uma forma simples. 

Assim que eu encontrar, será o assunto de um outro post.