---
layout: post
title: Instalando RSelenium e Phantomjs na Digital Ocean
date : 2014-05-08
tags: [webscrapping, rselenium]
--- 

Demorei bastante tempo para deixar o RSelenium junto com o Phantomjs funcionando direitinho no servidor que criei no Digital Ocean. Então vou anotar aqui o que eu fiz.

Eu tentei muitas coisas então talvez algumas coisas daqui não sejam estritamente necessárias. 

### 1 - Instalando o RSelenium

Para mim, a única versão que funcionou foi a que está no github, então usei o seguinte comando para instalar.


{% highlight r %}
devtools::install_github("RSelenium", "johndharrison")
{% endhighlight %}

Era só isso, no etanto, sem o phantomjs eu não conseguia acessar as páginas corretamente usando os comandos:


{% highlight r %}
RSelenium::checkForServer()
RSelenium::startServer()
remDr <- remoteDriver(browserName = "htmlunit")

remDr$open()
remDr$getStatus()
remDr$navigate("http://www.google.com")
{% endhighlight %}

Com isso, o comando `remDr$getTitle()` funcionava, mas o comando `remDr$screenshot(display = TRUE)`. Eu acho que isso deve acontecer porque o `htmlunit` é um navegador "headless" sem suporte para criar a immagem do site... Então a solução foi instalar o PhantomJs. 

### 2 - Instalando o PhantomJs  

Para instalar o phantomjs eu encontrei esse [post](http://withr.me/blog/2014/04/30/automatically-scrape-flight-ticket-data-using-r-and-phantomjs/) do WithR.

Então apenas copiei e colei o código no console do meu linux.

```
sudo apt-get remove phantomjs
sudo unlink /usr/local/bin/phantomjs
sudo unlink /usr/local/share/phantomjs
sudo unlink /usr/bin/phantomjs
cd /usr/local/share
sudo wget https://phantomjs.googlecode.com/files/phantomjs-1.9.0-linux-x86_64.tar.bz2
tar xjf phantomjs-1.9.0-linux-x86_64.tar.bz2
sudo ln -s /usr/local/share/phantomjs-1.9.0-linux-x86_64/bin/phantomjs /usr/local/share/phantomjs
sudo ln -s /usr/local/share/phantomjs-1.9.0-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs
sudo ln -s /usr/local/share/phantomjs-1.9.0-linux-x86_64/bin/phantomjs /usr/bin/phantomjs

```

Com isso feito, tudo passou a funcionar:


{% highlight r %}
RSelenium::checkForServer()
RSelenium::startServer()
remDr <- remoteDriver(browserName = "phantomjs")

remDr$open()
remDr$getStatus()
remDr$navigate("http://www.google.com")
remDr$getTitle()
remDr$screenshot(display = TRUE)
{% endhighlight %}

Pronto. Agora só falta aprender a usar o RSelenium. Meu objetivo é conseguir jogar o 2048 pelo R, que nem neste [post](http://www.r-bloggers.com/play-2048-using-r/) do Mark T Patterson.
