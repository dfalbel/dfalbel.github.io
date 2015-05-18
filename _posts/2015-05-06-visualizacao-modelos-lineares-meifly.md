---
layout: post
title: Visualizando um conjunto de modelos lineares usando o pacote meifly
date : 2015-05-06
tags: [r, estatistica, bayesiana]
--- 

O [Hadley Wickham](http://had.co.nz/) é um dos grandes nomes atuais do R. Em 2007 ele escreveu um paper que foi eleito pela [ASA](http://www.amstat.org/) o melhor dentre os estudantes na sessão de estatística computacional e gráficos.

Esse paper introduzia o [pacote meifly](http://had.co.nz/model-vis/2007-jsm.pdf) (models explored interactively on the fly). Este pacote tem um conjunto de funções que facilitam a exploração de conjuntos de modelos lineares. O resultado disso é muito interessante. Neste post, vou tentar reproduzir alguns gráficos que o Hadley fez em 2007.

Nos últimos dias, dei um fork no repositório do [meifly no Github](https://github.com/hadley/meifly) e fiz algumas alterações no código, trocando alguns códigos pelas funções do pacote [broom](https://github.com/dgrtwo/broom). Neste post, vou usar o pacote com as alterações que fiz, então para instalá-lo basta usar `devtools::install_github("dfalbel/meifly")`.

# Banco de dados

Para este post, vou usar o banco de dados `diammonds` que vem junto com o pacote `ggplot2`.
Nele temos as seguintes variáveis:

- price. price in US dollars (\$326–\$18,823)
- carat. weight of the diamond (0.2–5.01)
- cut. quality of the cut (Fair, Good, Very Good, Premium, Ideal)
- colour. diamond colour, from J (worst) to D (best)
- clarity. a measurement of how clear the diamond is (I1 (worst), SI1, SI2, VS1, VS2, VVS1, VVS2, IF (best))
- x. length in mm (0–10.74)
- y. width in mm (0–58.9)
- z. depth in mm (0–31.8)
- depth. total depth percentage = z / mean(x, y) = 2 * z / (x + y) (43–79)
- table. width of top of diamond relative to widest point (43–95)


{% highlight r %}
library(ggplot2)
{% endhighlight %}



{% highlight text %}
## Loading required package: methods
{% endhighlight %}



{% highlight r %}
head(diamonds)
{% endhighlight %}



{% highlight text %}
##   carat       cut color clarity depth table price    x    y    z
## 1  0.23     Ideal     E     SI2  61.5    55   326 3.95 3.98 2.43
## 2  0.21   Premium     E     SI1  59.8    61   326 3.89 3.84 2.31
## 3  0.23      Good     E     VS1  56.9    65   327 4.05 4.07 2.31
## 4  0.29   Premium     I     VS2  62.4    58   334 4.20 4.23 2.63
## 5  0.31      Good     J     SI2  63.3    58   335 4.34 4.35 2.75
## 6  0.24 Very Good     J    VVS2  62.8    57   336 3.94 3.96 2.48
{% endhighlight %}

Estamos interessados em encontrar um bom modelo para prever o preço do diamante de acordo com as demais características que estão na base de dados.

Para o exemplo, vou usar uma amostra aleatória deste banco de dados e vou renomear algumas colunas. 


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
d <- diamonds %>% sample_n(1000)
names(d)[c(8,9,10)] <- c("length", "width", "depth2")
{% endhighlight %}


# Ajuste dos modelos

Ajustaremos **todos** os modelos possíveis, isto é, os modelos que possuem todas as combinações possíveis das variáveis da base. Para isso vamos precisar do pacote `meifly`.


{% highlight r %}
library(meifly)

y <- d$price
x <- d %>% select(-price)
models <- fitall(y, x, "lm")
{% endhighlight %}


{% highlight text %}
## Fitting 511 models...
{% endhighlight %}

Com esse código ajustamos todos os modelos possíveis sendo `y` o vetor de respostas e `x` a matriz com todas as variáveis do banco de dados (exceto pela resposta).

# Visualizando no nível dos modelos

A primeira proposta é visualizar o conjunto de modelos em seu nível mais alto: os próprios modelos.

Usando a função `summary` no objeto `models` criado obtemos estatísticas algumas estatísticas de qualidade de ajuste de cada um dos modelos ajustados.


{% highlight r %}
s_models <- summary(models)
names(s_models) # variaveis obtidas para cada mdoelo
{% endhighlight %}

 [1] ".id"           "r.squared"     "adj.r.squared" "sigma"        
 [5] "statistic"     "p.value"       "df"            "logLik"       
 [9] "AIC"           "BIC"           "deviance"      "df.residual"  

A partir deste `summary` dos modelos, Hadley propôs o seguinte gráfico.


{% highlight r %}
library(tidyr)
s_models %>% 
  select(df, AIC, BIC, adj.r.squared, logLik) %>%
  gather(statistic, value, -df) %>%
  group_by(statistic) %>%
  mutate(value = (value - min(value))/(max(value) - min(value))) %>% 
  ggplot(aes(df, value)) + 
  geom_point() +
  facet_wrap(~statistic)
{% endhighlight %}

![plot of chunk unnamed-chunk-6](https://dl.dropboxusercontent.com/u/40339739/jekyll/2015-05-06-visualizacao-modelos-lineares-meifly/unnamed-chunk-6-1.png) 

No eixo x encontramos o número de parâmetros de cada modelo e no eixo y o valor da estatística. Note que para AIC e BIC, quanto menor melhor. Já para o R-quadrado ajustado e para o log-verossimilhança, quanto maior melhor.

Por este gráfico podemos afirmar que quanto maior o número de parâmetros melhor parece ser o modelo. No entanto, é possível encontrar um bom modelo com 15 coeficientes. O ganho a partir daí parece não ser muito significativo.

# Visualizando no nível dos coeficientes

Nesta sessão é proposta uma análise dos modelos no nível de seus coeficientes.

Usando o pacote `meifly` podemos obter uma tabela em que cada linha é um coeficiente de cada modelo, além de sua estimativa, valor-p, estatística de teste, etc. Para isso basta usar o código abaixo.


{% highlight r %}
coefs <- coef(models)
{% endhighlight %}

As visualizações, aqui, ficam um pouco mais complicadas uma vez que os parâmetros estão em escalas diferentes e são difíceis de serem comparados. No entanto, o gráfico a seguir pode dizer alguma coisa:


{% highlight r %}
coefs %>% 
  filter(estimate != 0) %>%
  ggplot(aes(y = p.value, x = term)) +
  geom_boxplot() +
  geom_hline(yintercept = 0.05) + 
  coord_cartesian(ylim = c(0, 0.5))
{% endhighlight %}

![plot of chunk unnamed-chunk-8](https://dl.dropboxusercontent.com/u/40339739/jekyll/2015-05-06-visualizacao-modelos-lineares-meifly/unnamed-chunk-8-1.png) 

Neste gráfico temos o valor-p do parâmetro em cada modelo no eixo y e qual é o termo no eixo x. Note que a caixa do boxplot dos valores do parâmetro relacionado à variável `carat` está totalmente encolhida abaixo do corte de 5%. Isso pode indicar que essa variável é necessária na modelagem, além de que não deve estar associada com nenhuma outra variável. Já o parâmtero relacionado à cor `C` não parece ser importante, apesar de que em alguns modelos ele teve um valor-p menor do que 0.05.

# Outros

No artigo Hadley propõe outras visualizações: no nível das observações e no nível dos resíduos. Elas poderiam ajudar a identificar observações discrepante/influentes.


# Referência

- http://had.co.nz/model-vis/2007-jsm.pdf
















