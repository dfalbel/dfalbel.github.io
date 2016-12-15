---
layout: post
title: 'Pacote folhar'
date : 2016-12-16
tags: [text-mining, r]
--- 



Esse post serve apenas para divulgar um pacote que estou desenvolvendo. Ele ainda
não está totalmente pronto, mas se como é difícil de testar, é bom que mais pessoas
usem e vejam se encontram errros, ou funcionalidades faltando.

Esse pacote faz um wrapper em volta do sistema de buscas do site da Folha de São Paulo: [http://search.folha.uol.com.br/](http://search.folha.uol.com.br/). As funções, permitem
a partir do R, fazer uma busca no site da Folha por meio de uma palavra-chave e 
de duas datas (para pesquisar noticias entre essas datas).

Depois de feita a busca, permite obter o texto de algumas notícias. Como o site da Folha,
possui diversos *cadernos* fica difícil decidir uma forma generalizada de fazer o parse
de todas as notícias possíveis. Conforme as pessoas pedirem, irei adicionando parser, ou, 
é relativamente simples fazer um pull request adicionando mais parsers [neste arquivo](https://github.com/dfalbel/folhar/blob/master/R/noticia.R).

# Exemplo

Depois de instalar o pacote usando:


{% highlight r %}
devtools::install_github("dfalbel/folhar")
{% endhighlight %}

Você pode fazer uma busca pelo termo *estatistica*, por exemplo:


{% highlight r %}
library(folhar)
busca <- folha_buscar("estatistica", "01/11/2016", "30/11/2016")
{% endhighlight %}



{% highlight text %}
## Error in as.vector(x, "list"): cannot coerce type 'environment' to vector of type 'list'
{% endhighlight %}

Veja que `busca` é um data.frame com todas as variáveis:

- data
- titulo
- link
- trecho

Agora você pode obter o texto completo de algumas notícias e mais alguns detalhes.
As possíveis notícias são as com url iniciado em:

- http://www1.folha.uol.com.br/
- http://f5.folha.uol.com.br/
- http://www.agora.uol.com.br/

Por exemplo, para uma notícia com a URL: "http://www1.folha.uol.com.br/poder/2016/11/1836519-pacote-de-dez-medidas-atinge-os-mais-pobres-diz-defensoria-do-rio.shtml" pode-se usar a função `folha_noticias` para obter mais detalhes.


{% highlight r %}
url <- "http://www1.folha.uol.com.br/poder/2016/11/1836519-pacote-de-dez-medidas-atinge-os-mais-pobres-diz-defensoria-do-rio.shtml"
noticia <- folha_noticias(url)
{% endhighlight %}

Desta vez um data.frame com as seguintes coluans é retornado:

- url
- datahora
- titulo
- autor
- texto