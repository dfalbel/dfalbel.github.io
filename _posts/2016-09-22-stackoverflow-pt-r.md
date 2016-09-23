---
layout: post
title: 'Quantidade de perguntas sobre R no pt.stackoverflow'
date : 2016-09-22
tags: [stackoverflow]
--- 



Veja o gráfico do número de perguntas com a tag `R` no pt.stackoverflow por mês.
Será que está crescendo?

![plot of chunk unnamed-chunk-1](/images/2016-09-22-stackoverflow-pt-r/unnamed-chunk-1-1.png)

Abaixo o código para reproduzir:


{% highlight r %}
library(dplyr)
library(lubridate)
library(ggplot2)
library(stackr)
stack_search(tagged = "r", site = "pt.stackoverflow", pagesize = 100, num_pages = 5) %>%
  group_by(ano = year(creation_date), mes = month(creation_date)) %>%
  summarise(n = n()) %>%
  mutate(date = ymd(paste(ano, mes, "01"))) %>%
  ggplot(aes(x = date, y = n)) + 
  geom_line() +
  geom_smooth(method = "lm") +
  labs(x = "Mês", y = "Qtd. Perguntas") + 
  scale_x_date(date_breaks = "8 months")
{% endhighlight %}

