---
layout: post
title: Previsão com dados diários
date : 2014-04-28
tags: [tradução, previsao]
---

>tradução de um [post](http://robjhyndman.com/hyndsight/dailydata/#more-2275) de Rob J. Hyndman.

Recentemente, recebi diversos emails perguntanto como fazer previsão para dados diários no `R`. Ao menos que a série seja muito longa, o melhor jeito é atribuir o valor 7 ao parâmetro de frequência.


{% highlight r %}
y <- ts(x, frequency=7)
{% endhighlight %}

Então qualquer método usual de previsão de séries temporais deve produzir resultados satisfatórios. Por exemplo:


{% highlight r %}
library(forecast)
fit <- ets(y)
fc <- forecast(fit)
plot(fc)
{% endhighlight %}

Quando a série é suficientemente grande para ter mais de um ano pode ser necessário usar modelos que permitam sazonalidade anual além da sazonalidade semanal. Nesse caso um modelo como o TBATS pode ser usado.


{% highlight r %}
y <- msts(x, seasonal.periods=c(7,365.25))
fit <- tbats(y)
fc <- forecast(fit)
plot(fc)
{% endhighlight %}

Isso deve ser capaz de capturar tanto o padrão semanal quanto o padrão anual da série. O período 365.25 é o número de dias médio de um ano, considerando anos bissextos. Em alguns países outros tamanhos de anos podem ser necessários. Por exemplo, nos dados de energia analisados em De Livera et al (JASA 2011), usamos três períodos sazonais: 7, 354.35 e 365.25. O período 354.35 é o número médio de dias do calendário Islâmico.

Capturar a sasonalidade associada a eventos que não ocorrem sempre no mesmo dia, como a Páscoa ou ano novo Chinês é mais difícil. Mesmo com dados mensais, isso pode ser complicado pois os feriados podem cair em Março ou Abril (para a Páscoa) ou em Janeiro ou Fevereiro (para o ano novo Chinês). Os modelos sazonais usuais não permitem isso, e mesmo modelos complexos de sazonalidade discutidos em meu paper na JASA assumem que os padrões sazonais ocorrem no mesmo tempo em todos os anos. A melhor maneira de lidar com feriados que mudam é usar variáveis "dumy". No entanto, nem os modelos ETS nem os TBATS permitem o uso de covariáveis. Um modelo de espaço de estado da forma que o TBATS mas com diferentes fontes de erro e covariáveis poderia ser usado, mas eu não tenho nenhum código em `R` para fazer isso. 

Ao invés disso, eu usaria um modelo de regressão com erros ARIMA, em que os regressores incluam variáveis "dummy" tanto para os feriados quanto para os efeitos de sazonalidade anual. Ao menos que você tenha muitas decadas de data, é razoável assumir que a forma sazonal anual é a mesma de ano para ano, então termos de Fourier podem ser usados para modelar a sazonalidade anual. Suponha que usamos `K=5` termos de Fourier para modelar a sazonalidade, e que as variáveis "dummy" para os feriados estão no vetor `holiday` com 100 valores futuros dos feriados em `holidayf`. Então o código a seguir ajustará um modelo apropriado.



{% highlight r %}
y <- ts(x, frequency=7)
z <- fourier(ts(x, frequency=365.25), K=5)
zf <- fourierf(ts(x, frequency=365.25), K=5, h=100)
fit <- auto.arima(y, xreg=cbind(z,holiday))
fc <- forecast(fit, xreg=cbind(zf,holidayf), h=100)
{% endhighlight %}

O valor de K pode ser escolhido minimizando o AIC do modelo ajustado.




