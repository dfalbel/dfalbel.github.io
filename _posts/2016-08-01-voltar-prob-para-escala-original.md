---
layout: post
title: 'Prevendo probabilidades em bases balanceadas'
date : 2016-08-01
tags: [machine-learning]
--- 



No [post anterior](http://dfalbel.github.io/2016/07/random-forest-balancear-ou-nao.html) comentei sobre construir modelos em bases balanceadas para prever eventos
em que a base real é desbalanceada. Vimos que para classificação, o modelo construido na base 
balanceada ficou um pouco melhor. O problema é que quando estamos prevendo probabilidades, fica
difícil voltar a probabilidade para a escala original. 

Fiz uma pergunta do Stack Exchange de Data Science e me sugeriram pesquisar por [Platt Scaling](https://en.wikipedia.org/wiki/Platt_scaling). Ele sugere usar um modelo logístico para prever a probabilidade de resposta usando o score do modelo original como covariável. Isso na mesma base de dados. No estudo, Platt trata do SVM, em que o score é um número de -1 a 1 e o score é transformado em classificação usando a função `sign`. No meu caso, meu mododelo já prevê uma
probabilidade de resposta, ela apenas não está na escala correta, mas achei a ideia interessante.

Um outro resultado que eu conhecia era a possibilidade de voltar a probabilidade para a escala original quando o modelo ajustado foi uma regressão logística. Esse resultado é apresentado na
página 215 do [livro do Gilberto A. Paula](https://www.ime.usp.br/~giapaula/texto_2013.pdf).

Resolvi juntar os dois métodos. Vou ajustar um modelo de random forest, usar a sua probabilidade estimada para prever a probabilidade de resposta na base desbalanceada. Em seguida, vou usar o resultado do livro do Gilberto para ajustar o intercepto do modelo e voltá-las para a escala original.

Uma outra abordagem é descrita [neste artigo](https://www.researchgate.net/publication/283349138_Calibrating_Probability_with_Undersampling_for_Unbalanced_Classification) de leitura razoavelmente simples. 
Aiás, é bom saber o nome deste problema em ingês: Calibrating Probability with Undersampling for Unbalanced Classification.

# Simulando um banco de dados

Vou simular os dados usando o mesmo código do post anterior. A função `simulate` definida a seguir gera 10 variáveis aleatórias com distribuição uniforme para serem usadas como covariáveis. Em
seguida soma todas essas probabilidades e compara define que a probabilidade de Y = 1 é o quantil da normal de média 8. Depois simulamos Y, usando a distribuição de bernoulli.


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

# Ajustando os modelos 

A função `balancear` faz com que o banco de dados tenha `p` de resposta e `1-p` de não resposta. 
Vou treinar o modelo numa base balanceada com `p = 50%`.


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


{% highlight r %}
suppressPackageStartupMessages(library(randomForest))
df <- balancear(treino, 0.5)
modelo_rf <- randomForest(Y ~ ., data = df)
{% endhighlight %}

Vou ajustar um modelo na base de treino full para poder comparar os dois métodos (corrigir a probabilidade vs. ajustar na base full).


{% highlight r %}
modelo_full <- randomForest(Y ~ ., data = treino)
{% endhighlight %}

Usando a função `predict` podemos obter a probabilidade de Y = 1 para cada uma das observações.
São essas probabilidades que vamos utilizar como covariável no modelo de regressão logística.


{% highlight r %}
df_prob <- data.frame(x = predict(modelo_rf, type = "prob")[,2],
                      Y = df$Y
                      )
modelo_log <- glm(Y~., data = df_prob, family = "binomial")
summary(modelo_log)
{% endhighlight %}



{% highlight text %}
## 
## Call:
## glm(formula = Y ~ ., family = "binomial", data = df_prob)
## 
## Deviance Residuals: 
##     Min       1Q   Median       3Q      Max  
## -2.7229  -0.5224   0.0086   0.5908   2.5794  
## 
## Coefficients:
##             Estimate Std. Error z value Pr(>|z|)    
## (Intercept)  -3.8514     0.1533  -25.12   <2e-16 ***
## x             7.6192     0.2766   27.54   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for binomial family taken to be 1)
## 
##     Null deviance: 3510.1  on 2531  degrees of freedom
## Residual deviance: 2033.9  on 2530  degrees of freedom
## AIC: 2037.9
## 
## Number of Fisher Scoring iterations: 5
{% endhighlight %}

Agora vamos comparar a probabilidade estimada pelo modelo de regressão logística e pelo modelo de 
random forest na base que utilizamos para treinar os modelos.


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
data.frame(
  prob_log = predict(modelo_log, newdata = df_prob, type = "response"), 
  prob_rf = predict(modelo_rf, type = "prob")[,2]
  ) %>%
  ggplot(aes(x = prob_log, y = prob_rf)) + 
  geom_point(size = 0.1) +
  stat_smooth()
{% endhighlight %}

![plot of chunk unnamed-chunk-7](/images/2016-08-01-voltar-prob-para-escala-original/unnamed-chunk-7-1.png)

Agora vamos aplicar a correção no intercepto do modelo de regressão logística, assim vamos obter a probabilidade de resposta na escala original. O novo intercepto deve ser calculado da seguinte forma:

$$\beta_0 = \beta_0^* - \log\frac{\n_0}{\n_1}$$

Essa fórmula é reproduzida no código abaixo:


{% highlight r %}
modelo_log$coefficients[1] <- 
modelo_log$coefficients[1] - log(sum(treino$Y == "0") / sum(treino$Y == "1"))
{% endhighlight %}

# Resultados

Agora vamos aplicar os modelos em uma base de teste para verificar o acerto do modelo.
Nenhuma observação da base de teste foi utilizada na construção do modelo.

Primeiro aplciamos o modelo de random forest:


{% highlight r %}
teste$x <- predict(modelo_rf, newdata = teste, type = "prob")[,2]
{% endhighlight %}

Aqui `x` é a probabilidade de `Y = 1` estimada pelo random forest.
Veja agora a comparação das duas probabilidades: 

- prob_real: probabilidade real de `Y = 1` determinada pela simulação e,
- prob_teste: probabilidade de `Y = 1` estimada pelos modelos combinados


{% highlight r %}
prob_teste <- predict(modelo_log, teste, type = "response")
prob_real <- apply(teste[, 1:10], 1, sum) %>% pnorm(mean = 8)

summary(abs(prob_teste - prob_real))
{% endhighlight %}



{% highlight text %}
##      Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
## 0.0000000 0.0004345 0.0009987 0.0062730 0.0040100 0.4889000
{% endhighlight %}

Veja agora o erro quando o modelo for ajustado na base inteira:


{% highlight r %}
prob_full <- predict(modelo_full, newdata = teste, type = "prob")[,2]
summary(abs(prob_full - prob_real))
{% endhighlight %}

{% highlight text %}
##     Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
## 0.0000000 0.0005009 0.0027270 0.0090880 0.0090680 0.3561000 
{% endhighlight %}

Veja tamb´me um gráfico das probabilidades estimadas pelo método das bases balanceadas e as probabilidades reais. A reta em vermelho, é a reta esperada se a probabilidade real estivesse sendo perfeitamente estimada pelo modelo. A reta azul é a reta estimada usando os dados obtidos.


{% highlight r %}
data.frame(
  prob_teste = prob_teste,
  prob_real = prob_real
  ) %>%
  ggplot(aes(x = prob_teste, y = prob_real)) + 
  geom_point(size = 0.1) +
  stat_smooth(method = "lm") + 
  geom_abline(intercept = 0, slope = 1, colour = "red")
{% endhighlight %}

![plot of chunk unnamed-chunk-12](/images/2016-08-01-voltar-prob-para-escala-original/unnamed-chunk-12-1.png)

# Conclusão

Neste estudo de simulação, a probabilidade estimada usando o modelo na base balanceada e depois 
reajustada usando uma mistura do *Platt Scaling* com a reponderação da amostra retrospectiva 
obteve bons resultados. Além de aproximar bem a probabilidade real, aproximou-se mais desta do 
que o modelo de random forest ajustado na base full. Se comparar-mos a média, esse método teve
erros cerca de 30% menores e se compararmos a mediana, os erros foram aproximadamente 63% menores!


