---
layout: post
title: 'O paradoxo de Simpson'
date : 2016-02-22
tags: [estatistica]
--- 

Está em fase de pré-venda um 
[novo livro do Judea Pearl](http://www.amazon.com/Causal-Inference-Statistics-Judea-Pearl/dp/1119186846/ref=sr_1_1?ie=UTF8&qid=1452539578&sr=8-1&keywords=judea+pearl+primer) 
sobre inferência causal em estatística. Achei interessante que no primeiro capítulo do livro, [disponibilizado aqui](http://bayes.cs.ucla.edu/PRIMER/)
logo após a motivação de se estudar causalidade, Pearl fala sobre o [paradoxo de Simpson](https://en.wikipedia.org/wiki/Simpson%27s_paradox).

Nomeado em memória de Edward Simpson (1922), o primeiro estatístico a popularizá-lo, o paradoxo refere-se a existência de dados nos quais a associação estatística que é valida para a população inteira é revertida em todas as subpopulações, quando consideramos algum agrupamento.

O exemplo clássico do Simpson é de um grupo de pacientes doentes que tiveram a opção de tentar um remédio novo. Os resultados obtidos foram os seguintes.

|               | Drug                           | No drug                         |
|:--------------|-------------------------------:|--------------------------------:|
|Men            | 81 out of 87 recovered (93%)   | 234 out of 270 recovered (87%)  |
|Women          | 192 out of 263 recovered (73%) | 55 out of 80 recovered (69%)    |
|Combined data  | 273 out of 350 recovered (78%) | 289 out of 350 recovered (83%)  |

Entre todos os que testaram a nova droga, uma porcentagem menor dos que usaram o 
remédio se recuperaram do que entre os que não o utilizaram. No entanto, Os homens 
que usaram o remédio se recuperaram mais do que os que não usaram. O Mesmo acontece 
para as mulheres: a proporção de recuperação dentre as mulheres que usaram a droga 
é maior do que dentre as que não. Isso parece contraditório, se soubermos o sexo do 
indivíduo, não importanto qual ele seja, é melhor tratá-lo com o novo remédio, 
mas se não soubermos é melhor não tratá-lo com o novo medicamento.

**Surge então a dúvida**: se o governo fosse decidir sobre a adoção de uma política de uso 
desse novo medicamento, que decisão ele deveria tomar?

A resposta de Pearl, em seu livro, é muito completa. Ele diz: 

> A resposta não pode ser encontrada em estatística simples. Para poder decidir se a droga 
> irá ajudar ou prejudicar o paciente, primeiramente é necessário entender a história por
> trás dos dados - a história que geraram os resultados observados. Suponha que sabemos de um fato 
> adicional: Estrógeno tem um efeito negativo na recuperação, então mulheres tem menos chance de 
> se recuperar do que os homens, não importando o novo medicamento. Adicionalmente, como podemos
> ver pelos dados, mulheres têm significativamente mais chance de tomar o novo medicamento do que
> os homens. Então, a razão pela qual o medicamento parece ser prejudicial para a população em geral,
> se selecionarmos um usuário do medicamente aleatóriamente, essa pessoa tem mais chance de ser uma mulher,
> que tem menor chance de recuperação do que uma pessoa que não tomou o medicamento. (...)
> Por isso, para analisar corretamente, precisamos comparar individuos do mesmo gênero, assim assegurando que
> qualquer diferença nas taxas de recuperação entre aqueles que tomam ou não o medicamento
> **não** é devida à presença do estrógeno. Isso significa que devemos consultar os dados segregados,
> que nos mostra inequivocadamente que o medicamento é útil.

# Analisando no R

Supondo que o banco de dados que gerou a tabela acima seja da seguinte forma:


{% highlight r %}
dados <- data.frame(
  id = 1:700,
  sexo = c(rep("Homem", 357), rep("Mulher", 343)),
  remedio = c(rep(1, 87), rep(0, 270), rep(1, 263), rep(0, 80)),
  recuperou = c(rep(1, 81), rep(0, 6), rep(1, 234), rep(0, 36), 
                rep(1, 192), rep(0, 71), rep(1, 55), rep(0, 25))
)
{% endhighlight %}

Veja que na tabela resumo eles estão iguais:


{% highlight r %}
library(dplyr)
{% endhighlight %}



{% highlight text %}
## 
## Attaching package: 'dplyr'
{% endhighlight %}



{% highlight text %}
## The following objects are masked from 'package:stats':
## 
##     filter, lag
{% endhighlight %}



{% highlight text %}
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
{% endhighlight %}



{% highlight r %}
dados %>% 
  group_by(sexo, remedio) %>% 
  summarise(n_rec = sum(recuperou), n = n())
{% endhighlight %}



{% highlight text %}
## Source: local data frame [4 x 4]
## Groups: sexo [?]
## 
##     sexo remedio n_rec     n
##   (fctr)   (dbl) (dbl) (int)
## 1  Homem       0   234   270
## 2  Homem       1    81    87
## 3 Mulher       0    55    80
## 4 Mulher       1   192   263
{% endhighlight %}

Para estimar o efeito do uso do medicamento na recuperação poderíamos ajustar um
modelo de regressão logística com o seguinte código:


{% highlight r %}
modelo <- glm(recuperou ~ sexo + remedio, data = dados, family = "binomial")
{% endhighlight %}

Calculamos a probabilidade de recuperação para cada um dos casos possíveis.


{% highlight r %}
casos <- expand.grid(sexo = c("Homem", "Mulher"), remedio = c(1,0))
casos$prob <- predict(modelo, newdata = casos, type = "response")
{% endhighlight %}

Agora podemos ver que para quem recee o medicamento a probabilidade de recuperação, não importando o gênero do indivíduo.


{% highlight r %}
tab <- casos %>% group_by(remedio) %>% summarise(p = mean(prob))
tab
{% endhighlight %}



{% highlight text %}
## Source: local data frame [2 x 2]
## 
##   remedio         p
##     (dbl)     (dbl)
## 1       0 0.7684074
## 2       1 0.8229495
{% endhighlight %}

Vemos então que ao tomar o remédio a probabilidade de cura aumenta em 7.1%.

A análise incorreta, sem considerar o sexo, mostraria outra conclusão (vide
a tabela abaixo).


{% highlight r %}
modelo <- glm(recuperou ~ remedio, data = dados, family = "binomial")
casos <- expand.grid(sexo = c("Homem", "Mulher"), remedio = c(1,0))
casos$prob <- predict(modelo, newdata = casos, type = "response")
tab <- casos %>% group_by(remedio) %>% summarise(p = mean(prob))
tab
{% endhighlight %}



{% highlight text %}
## Source: local data frame [2 x 2]
## 
##   remedio         p
##     (dbl)     (dbl)
## 1       0 0.8257143
## 2       1 0.7800000
{% endhighlight %}

Assim seria observada uma queda de -5.54%
na probabilidade de recuperação com o uso do medicamento.






