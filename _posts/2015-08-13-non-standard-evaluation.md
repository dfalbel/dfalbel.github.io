---
layout: post
title: 'Exemplo interessante de Non Standard evaluation no R'
date : 2015-08-13
tags: [r, graficos]
--- 

Vou falar rapidamente de um exemplo interessante de como o R avalia os argumentos passados para as funções.

Considere as duas funções abaixo:


{% highlight r %}
foo <- function(){
  cat("foo\n")
  return(1)
}

fooo <- function(x = foo()){
  cat("fooo\n")
  return(x)
}
{% endhighlight %}

Ao chamar a função `fooo`, o que você esperaria que fosse avaliado primeiro?
A linha que tem `cat("fooo\n")` ou a linha que tem `cat("foo\n")`?

Na minha intuição, a função `foo` deveria ser avaliada antes, uma vez que ela cria o argumento que será usado em seguida na função `fooo`. Mas não é isso que acontece.


{% highlight r %}
fooo()
{% endhighlight %}



{% highlight text %}
## fooo
## foo
{% endhighlight %}



{% highlight text %}
## [1] 1
{% endhighlight %}

Agora considere a seguinte pequena alteração no código de `fooo`.


{% highlight r %}
fooo <- function(x = foo()){
  cat("fooo\n")
  return(1)
}
{% endhighlight %}

Agora, ao invés de ela retornar `x`, ela sempre retornará `1`.

Observe agora o resultado da chamada da função `fooo`. 


{% highlight r %}
fooo()
{% endhighlight %}



{% highlight text %}
## fooo
{% endhighlight %}



{% highlight text %}
## [1] 1
{% endhighlight %}

Veja que a função `foo` nem foi chamada dessa vez, mesmo ela sendo parte necessária do argumento x da função que chamamos.

Isso acontece porque os argumentos das funções são um tipo especial de objeto chamado `promise`. Um `promise` captura a expressão necessária para calcular o argumento, mas só o avalia na primeira situação em que o seu valor é necessário.
