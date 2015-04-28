---
layout: post
title: Digital Ocean, Docker e Hadleyverse
date : 2015-04-28
tags: [webscrapping, rselenium]
--- 

Docker é a grande revolução do momento. A possibilidade de desenvolver seu aplicativo em um ambiente totalmente reproduzível tornou muito mais fácil expandi-lo e servi-lo.

O R não ficou de fora e também lançou diversos "containers" com R, RStudio, Shiny Server instalados para que seja mais fácil ter um ambiente de programação em R em qualquer computador.

Neste artigo, vou ensinar a instalar e acessar na [digital ocean](https://www.digitalocean.com/) um RStudio com todos os pacotes do "Hadleyverse" instalado.

# 1 - Crie uma conta na Digital Ocean

Esse passo não deve ser muito difícil. Apenas entre no site da [digital ocean](https://www.digitalocean.com/) e crie a sua conta.

# 2 - Crie um droplet com docker instalado

No painel de início da DigitalOcean clique em Create Droplet conforme a figura abaixo.

![painel inicial da digital ocean](https://dl.dropboxusercontent.com/u/40339739/jekyll/2015-04-28-docker-hadleyverse-digitalocean/fig1.PNG)

Digite um nome para a sua droplet e selecione o seu tamanho. Aqui vou escolher o tamanho 512MB, mas isso não importa para o andamento da instalação.

![selecao do tamanho do droplet](https://dl.dropboxusercontent.com/u/40339739/jekyll/2015-04-28-docker-hadleyverse-digitalocean/fig2.PNG)

Agora selecione a região que você deseja criar (isso também não afetará a instalação) assim como as demais configurações. Neste artigo deixarei tudo do jeito que está.

![regiao do droplet](https://dl.dropboxusercontent.com/u/40339739/jekyll/2015-04-28-docker-hadleyverse-digitalocean/fig3.PNG)

Solicite a instalação do aplicativo docker em seu droplet. Sua tela deve estar parecida com seguinte imagem.

![tipo do droplet](https://dl.dropboxusercontent.com/u/40339739/jekyll/2015-04-28-docker-hadleyverse-digitalocean/fig4.PNG)

Crie o seu droplet clicando no botão circulado na figura abaixo.

![tipo do droplet](https://dl.dropboxusercontent.com/u/40339739/jekyll/2015-04-28-docker-hadleyverse-digitalocean/fig5.PNG)

# 3 - Acessando o droplet e instalando o Hadleyverse

Quando a DigitalOcean terminar de provisionar a sua instância você receberá a senha por email. Usando o terminal do linux/mac acesse a sua instância via SSH. No Windows isso pode ser feito usando o putty (mas não entrarei em detalhes).

Obtenha o IP do seu droplet no dashboard inicial da DigitalOcean.

![tipo do droplet](https://dl.dropboxusercontent.com/u/40339739/jekyll/2015-04-28-docker-hadleyverse-digitalocean/fig6.PNG)

O IP é o primeiro número que aprece na imagem: 45.55.141.180. Cada droplet possui o seu próprio. Nos próximos passos, substitua esse número pelo seu!!

Vá para o terminal e digite: `ssh root@45.55.141.180` e faça login usando a senha que você recebeu por email. A primeira coisa que você precisará fazer é trocar a senha.

![acessar droplet](https://dl.dropboxusercontent.com/u/40339739/jekyll/2015-04-28-docker-hadleyverse-digitalocean/fig7.PNG)

Digite o comando `docker pull rocker/hadleyverse` isso fará com que o docker comece a baixar todos os arquivos necessários para a instalação do container.

![docker pull](https://dl.dropboxusercontent.com/u/40339739/jekyll/2015-04-28-docker-hadleyverse-digitalocean/fig8.PNG)

Use o comando: `docker run -d -p 8787:8787 -e USER=rstudio -e PASSWORD=rstudio rocker/hadleyverse` para iniciar o container com Rstudio Server rodando com todos os pacotes do Hadley instalados. Defini aqui que o usuário e a senha serão rstudio, mas você pode trocar para o que você quiser.

![criar container](https://dl.dropboxusercontent.com/u/40339739/jekyll/2015-04-28-docker-hadleyverse-digitalocean/fig9.PNG)

Se tudo estiver correto, o seu container estará criado e poderá ser acessado acessando o http://45.55.141.180:8787

![criar container](https://dl.dropboxusercontent.com/u/40339739/jekyll/2015-04-28-docker-hadleyverse-digitalocean/fig10.PNG)

Pronto, agora você tem um Rstudio Server com todos os pacotes do Hadley instalados.
Para mais informações leia este [link](https://github.com/rocker-org/rocker/wiki/Using-the-RStudio-image)









