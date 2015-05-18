---
layout: post
title: 'Comparação de proporções: qui-quadrado ou teste normal?'
date : 2015-05-17
tags: [r, estatistica]
--- 

<script type="text/javascript"
  src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>


Nos cursos de estatística, um dos primeiros problemas que são ensinados é o de comparação de proporções. O objetivo, por exemplo, é verificar se duas moedas (A e B) têm a mesma probabilidade de cair cara. 

Definimos então que $$X_A$$ é uma variável aleatória que recebe o valor 1 quando em um lançamento da moeda A o resultado foi cara. Caso contrário o valor de $$X_A$$ é 0. Podemos então propor que $$X_A \sim Bernouli(p_A)$$ em que $$p_A$$ é a probabilidade de $$X_A = 1$$. Analogamente, definimos $$X_B$$ e $$p_B$$.

Em seguida, com o objetivo de testar se $$p_A = p_B$$, propomos o seguinte experimento. Vamos lançar as moedas A e B, $$n_A$$ e $$n_B$$ vezes respectivamente. Assim, obtivemos $$x_A$$ e $$x_B$$, vetores de tamanho $$n_A$$ e $$n_B$$ contendo zeros ou uns de acordo com os resultados das moedas.

Suponha que existam duas populações A e B. Queremos saber se a proporção de ocorrência de um certo evento em A é igual a proporção de ocorrência em B. Para isso obtivemos uma amostra da variável aleatória X ("ocorrência do evento") em cada população de tamanhos $n_A$ e $n_B$.

Dado o modelo probabilístico e o experimento realizado, queremos testar se as duas moedas possuem a mesma probabilidade de sair cara.

Para qualquer aluno de estatística viriam dois testes de hipótese na cabeça: o teste normal de comparação de proporções ou o teste chi-quadrado. Ambos ensinados em qualquer curso introdutório de estatística. 

Mas qual deles devemos usar?

## O teste normal de comparação de proporções

O teste normal parte da seguinte afirmação:
O estimador de máxima verossimilhança para $$p_A$$ é $$\hat{p_A} = \frac{\sum_{i = 1}^{n_A} x_{iA}}{n_A}$$. 

Como procedimento básico de inferência estatística clássica tentamos encontrar a distribuição de $$\hat{p_A}$$. Acontece que, é fácil ver que $$\hat{p_A}$$ possui distribuição Binomial, basta notar que se $$X_A \sim Bernouli(p_A)$$ então $$\sum_{i=1}^{n} X_{iA} \sim Binomial(n, p_A)$$.

Também é conhecido que uma aproximação razoável da distribuição $$Binomial(n, p)$$ é a distribuição $$Normal(p, \frac{p(1-p)}{n})$$

Tudo o que foi dito anteriormente serve para a moeda B. Segue que queremos fazer um teste para $$H_0: p_A - p_B = 0$$ contra $$H_1: p_A - p_B \ne 0$$.
Logo, vamos usar a quantia $$\hat{p_A} - \hat{p_B}$$, para a qual podemos afirmar:

$$\hat{p_A} - \hat{p_B} \sim Normal(p_A- p_B, \frac{p_A(1-p_A)}{n_A} + \frac{p_B(1-p_B)}{n_B})$$

Segue então que podemos usar a seguinte estatística para testar a nossa hipótese:

$$z = \frac{\hat{p_A} - \hat{p_B}}{\sqrt{\frac{\hat{p_A}(1- \hat{p_A})}{n_A} + \frac{\hat{p_B}(1- \hat{p_B})}{n_B}}}$$

Como $$z$$ é apenas a padronização de uma variável com distribuição Normal, segue que $$z \sim N(0,1)$$.

Com todas essas ferramentas, já poderíamos testar se as duas proporções são iguais.

## O teste Chi Quadrado

O teste de $$\chi^2$$ é muito flexível e pode servir para testar inúmeras hipóteses diferentes. Uma delas é testar a aderência de um modelo probabilístico. Sabemos que o modelo com o qual estruturamos o nosso experimento foi $$X_A \sim Bernouli(p_A)$$ e $$X_B \sim Bernouli(p_B)$$, mas vamos testar a aderência do seguinte modelo: $$X_A \sim Bernouli(p)$$ e $$X_B \sim Bernouli(p)$$. Testar a aderência deste modelo parece ser equivalente a testar que $$p_A = p_B$$.

Um estimador óbvio para $$p$$ seria:

$$\hat{p} = \frac{\sum x_{iA} + \sum x_{iB}}{n_A + n_B}$$

Em seguida calculamos a estatística de $$\chi^2$$ que é $$\sum \frac{(O_i - E_i)^2}{E_i}$$ ou a seguinte expressão:

$$Q = \frac{(x_A - \hat{p}n_A)^2}{\hat{p}n_A} + \frac{((n_A - x_A) - (1- \hat{p})n_A)^2}{(1-\hat{p})n_A} + \frac{(x_B - \hat{p}n_B)^2}{\hat{p}n_B} + \frac{((n_B - x_B) - (1- \hat{p})n_B)^2}{(1-\hat{p})n_B}$$

Aqui usamos $$x_A = \sum x_{iA}$$, e análogo para B.

Agora podemos comparar o valor de Q na nossa amostra com os quantis da distribuição $$\chi^2$$ para decidir se podemos afirmar que as proporções são iguais.

## Os dois testes são iguais!

Um conhecido resultado de inferência estatística é que se $$z \sim Normal(0,1)$$ então $$z^2 \sim \chi^{2}_{1}$$
Portanto $$z^2$$ e $$Q$$ possuem a mesma distribuição. Além disso, é possível provar (depois de bastante conta chata) que neste caso $$Q = z^2$$.
Deste modo, como $$Q$$ e $$z^2$$ possuem a mesma distribuição e são matematicamente iguais podemos afirmar que os dois testes são equivalentes!
Apesar deste resultado ser simples, para mim nunca tinha sido claro que as duas abordagens eram exatamente iguais!











