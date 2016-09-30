---
layout: post
title: 'Pacote ptstem'
date : 2016-09-30
tags: [text-mining, r]
--- 



No [meu github](https://github.com/dfalbel/) você pode encontrar o pacote [`ptstem`](https://github.com/dfalbel/ptstem).

Esse pacote unifica a API de uso de três algoritmos de stemming para a língua 
portuguesa disponíveis no R.

## Instalando

Você pode instalar direto do [github](https://github.com/dfalbel/ptstem) com o seguinte
comando:


{% highlight r %}
devtools::install_github("dfalbel/ptstem")
{% endhighlight %}

ou pelo [CRAN](https://cran.r-project.org/package=ptstem)


{% highlight r %}
install.packages("ptstem")
{% endhighlight %}

## Usando

Considere o seguinte texto, extraído artigo [*Stemming* da Wikipedia](https://pt.wikipedia.org/wiki/Stemiza%C3%A7%C3%A3o)


{% highlight r %}
text <- "Em morfologia linguística e recuperação de informação a stemização (do inglês, stemming) é
o processo de reduzir palavras flexionadas (ou às vezes derivadas) ao seu tronco (stem), base ou
raiz, geralmente uma forma da palavra escrita. O tronco não precisa ser idêntico à raiz morfológica
da palavra; ele geralmente é suficiente que palavras relacionadas sejam mapeadas para o mesmo
tronco, mesmo se este tronco não for ele próprio uma raiz válida. O estudo de algoritmos para
stemização tem sido realizado em ciência da computação desde a década de 60. Vários motores de
buscas tratam palavras com o mesmo tronco como sinônimos como um tipo de expansão de consulta, em
um processo de combinação."
{% endhighlight %}

O seguinte código usa o pacote [`rslp`](https://github.com/dfalbel/rslp) para afzer o stemming do texto.


{% highlight r %}
library(ptstem)
ptstem(text, algorithm = "rslp", complete = FALSE)
{% endhighlight %}



{% highlight text %}
## [1] "Em morfolog linguis e recuper de inform a stemiz (do ingl, stemming) é\no process de reduz palavr flexion (ou às vez deriv) ao seu tronc (st), bas ou\nraiz, geral uma form da palavr escrit. O tronc nao precis ser ident à raiz morfolog\nda palavr; ele geral é sufici que palavr relacion sej mape par o mesm\ntronc, mesm se est tronc nao for ele propri uma raiz val. O estud de algoritm par\nstemiz tem sid realiz em cienc da comput desd a dec de 60. Vari motor de\nbusc trat palavr com o mesm tronc com sinon com um tip de expans de consult, em\num process de combin."
{% endhighlight %}

Você pode completar as palavras que foram *stemizadas* usando o argumento `complete = T`.


{% highlight r %}
ptstem(text, algorithm = "rslp", complete = TRUE)
{% endhighlight %}

Os outros algoritmos implementados são:

* hunspell: o mesmo algoritmo usado no corretor do OpenOffice. (disponível via [hunspell](https://github.com/ropensci/hunspell) package)
* porter: disponível pelo pacote SnowballC.

Você pode trocar o algoritmo utilziado por meio do argumento `algorithm` da função `ptstem`:


{% highlight r %}
library(ptstem)
ptstem(text, algorithm = "hunspell")
{% endhighlight %}



{% highlight text %}
## [1] "Em morfologia linguística e recuperação de informação a stemização (do inglês, stemização) é\no processo de reduzir palavras flexionadas (ou às vezes derivadas) ao seu tronco (stemização), base ou\nraiz, geralmente uma forma da palavras escrita. O tronco não precisa ser idêntico à raiz morfologia\nda palavras; ele geralmente é suficiente que palavras relacionadas ser mapeadas para o mesmo\ntronco, mesmo se este tronco não for ele próprio uma raiz válida. O estudo de algoritmos para\nstemização tem ser realizado em ciência da computação desde a década de 60. Vários motores de\nbuscas tratam palavras com o mesmo tronco como sinônimos como um tipo de expansão de consulta, em\num processo de combinação."
{% endhighlight %}



{% highlight r %}
ptstem(text, algorithm = "porter")
{% endhighlight %}



{% highlight text %}
## [1] "Em morfologia linguística e recuperação de informação a stemização (do inglês, stemming) é\no processo de reduzir palavras flexionadas (ou às vezes derivadas) ao seu tronco (stem), base ou\nraiz, geralmente uma forma da palavras escrita. O tronco não precisa ser idêntico à raiz morfológica\nda palavras; ele geralmente é suficiente que palavras relacionadas sejam mapeadas para o mesmo\ntronco, mesmo se este tronco não for ele próprio uma raiz válida. O estudo de algoritmos para\nstemização tem sido realizado em ciência da computação desde a década de 60. Vários motores de\nbuscas tratam palavras com o mesmo tronco com sinônimos com um tipo de expansão de consulta, em\num processo de combinação."
{% endhighlight %}
