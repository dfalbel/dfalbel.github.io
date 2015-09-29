---
layout: post
title: 'Criando paletas de cores a partir imagens no R'
date : 2015-09-28
tags: [r, graficos, cores, imagens]
--- 

Recentemente eu quis obter as cores predominantes de uma foto para usá-las em um gráfico que estava fazendo. Acabei achando o problema interessante: não é óbvio determinar uma maneira de encontrar as cores distintas, porém predominantes, em uma imagem.

Então, fiz um pacote do R que lê uma imagem em `jpeg` e cria uma paleta de cores baseada nesta imagem. Abaixo mostro um exemplo, em seguida explico rapidamente como o algoritmo funciona.

O pacote é instalado utilizando `devtools::install_github('dfalbel/paletaCores')`. Em seguida, você pode obter a paleta da seguinte maneira.

![david-bowie](https://vice-images.vice.com/images/content-images/2015/09/09/mick-rock-tk-body-image-1441819666.jpg?resize=*:*&output-quality=)



{% highlight r %}
suppressPackageStartupMessages(library(paletaCores))
cores <- criar_paleta("../images/david bowie.jpeg")
cores
{% endhighlight %}



{% highlight text %}
## [1] "#4B69A9" "#B52F25" "#240C4C" "#D58E5D" "#EBDCC6"
{% endhighlight %}

Esse código retorna um vetor de cores, que pode ser exibido usando a função exibir que acompanha o pacote `paletaCores`.


{% highlight r %}
exibir(cores)
{% endhighlight %}

![plot of chunk unnamed-chunk-2](/images/2015-09-28-paleta-de-cores-img/unnamed-chunk-2-1.png) 

# Como funciona

A primeiro passo que é necessário entender é como uma imagem é interpretada pelo `R`. O pacote `paletaCores` possui uma função, que não é exportada, que serve para ler uma imagem.

A imagem no `R` é representada por um `data.frame` com o seguinte formato:


{% highlight r %}
img <- paletaCores:::ler("../images/david bowie.jpeg")
head(img, n = 5)
{% endhighlight %}



{% highlight text %}
##   x   y         r         g         b     cor id
## 1 1 750 0.2352941 0.5333333 0.5843137 #3C8895  1
## 2 1 749 0.2627451 0.5568627 0.5372549 #438E89  2
## 3 1 748 0.2941176 0.5843137 0.5960784 #4B9598  3
## 4 1 747 0.2509804 0.5372549 0.5607843 #40898F  4
## 5 1 746 0.2470588 0.5411765 0.5647059 #3F8A90  5
{% endhighlight %}

Ou seja, é um `data.frame` que mapeia cada pixel, identificado por sua coordenada `x,y` a uma cor que é identificada pela trípla de valores `rgb`.

Então como separar as cores mais importantes e diferentes entre si da imagem? Aqui usamos a técnica de clusterização conhecida como kmeans. As variáveis utilizadas foram cada atributo da cor dos píxels: `r`, `g` e `b`.

Veja o código da função `criar_paleta`.


{% highlight r %}
paletaCores::criar_paleta
{% endhighlight %}



{% highlight text %}
## function (img, n = 5) 
## {
##     foto <- ler(img)
##     cluster <- kmeans(x = foto %>% dplyr::select(r, g, b), centers = n)
##     foto$grupo <- cluster$cluster
##     grupos <- foto %>% dplyr::group_by(grupo) %>% dplyr::summarise(r = mean(r), 
##         g = mean(g), b = mean(b)) %>% dplyr::mutate(cor = rgb(r, 
##         g, b))
##     return(grupos$cor)
## }
## <environment: namespace:paletaCores>
{% endhighlight %}

Utilizamos, em seguida, a cor representada pelo centróide de cada cluster criado como cor da paleta.

# Mais exemplos

![praia](/images/2015-09-28-paleta-de-cores-img/praia.jpg)


{% highlight r %}
criar_paleta("../images/2015-09-28-paleta-de-cores-img/praia.jpg") %>% exibir
{% endhighlight %}

![plot of chunk unnamed-chunk-5](/images/2015-09-28-paleta-de-cores-img/unnamed-chunk-5-1.png) 

![vulcao](/images/2015-09-28-paleta-de-cores-img/vulcao.jpeg)


{% highlight r %}
criar_paleta("../images/2015-09-28-paleta-de-cores-img/vulcao.jpeg") %>% exibir
{% endhighlight %}

![plot of chunk unnamed-chunk-6](/images/2015-09-28-paleta-de-cores-img/unnamed-chunk-6-1.png) 










