---
layout: post
title: 'Comparação de proporções: qui-quadrado ou teste normal?'
date : 2015-05-17
tags: [r, estatistica]
--- 

<script type="text/javascript"
  src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>


Nos cursos de estatística, um dos primeiros problemas que são ensinados é o de comparação de proporções. O modelo proposto é sempre da seguinte forma:

Suponha que existam duas populações A e B. Queremos saber se a proporção de ocorrência de um certo evento em A é igual a proporção de ocorrência em B. Para isso obtivemos uma amostra da variável aleatória X ("ocorrência do evento") em cada população de tamanhos $n_A$ e $n_B$.

Assumimos \\(X_{A} \sim Bernouli(p_A)\\) e \\(X_b \sim Bernouli(p_B)\\). Em uma amostra aleatória simples da \(X_A \\) então temos:

$$\sum_{i=1}^{n_A} X_{Ai} \sim Binomial(n_A, p_A)$$ 

Como $$ \hat{p_A} = \sum_{i=1}^{n_A} X_{Ai}/n_A $$ conseguimos fácilmente chegar na distribuição de \\( \hat{p_A} - \hat{p_B} \\), a partir daí podemos comparar a proporção em que o evento acontece em cada uma das populações. Em geral usamos a aproximação da distribuição binomial para a normal, mas isso não seria necessário.

O teste Chi-Quadrado também serve para fazer testes de hipóteses em tabelas de contingência. Então teoricamente podemos usá-lo para testar também se as duas proporções são iguais.

Então a princípio temos duas abordagens possíveis para comparar proporções: teste normal e teste chi-quadrado.

## Estatística de teste no caso Normal

No caso Normal, podemos definir que a estatística:

$$z = \frac{\hat{p_A} - \hat{p_B}}{\sqrt{\frac{\hat{p_A}(1- \hat{p_A})}{n_A} + \frac{\hat{p_B}(1- \hat{p_B})}{n_B}}}$$

Com 

$$\hat{p_k} = x_k/n_k$$ e $$x_k$$ o número de sucessos na amostra de tamanho $$n_k$$. Para $$k = A, B$$ 

Sabemos que $z$ tem distribuição aproximadamente Normal com média zero e variância 1.

## Estatística de teste no caso do Chi Quadrado

No caso do teste Chi Qudrado definimos a seguinte estatística de teste:

$$Q = \frac{(x_A - \hat{p}n_A)^2}{\hat{p}n_A} + \frac{((n_A - x_A) - (1- \hat{p})n_A)^2}{(1-\hat{p})n_A} + \frac{(x_B - \hat{p}n_B)^2}{\hat{p}n_B} + \frac{((n_B - x_B) - (1- \hat{p})n_B)^2}{(1-\hat{p})n_B}$$

Com $$\hat{p} = \frac{x_A + x_B}{n_A + n_B}$$ e $$x_k$$ o número de sucessos na amostra de tamanho $$n_k$$. Para $$k = A, B$$
Neste caso sabemos que $$Q \sim chi^2_1$$


## Conclusão

É também um conhecido resultado da estatística que se $$z \sim Normal(0,1)$$ então $$z^2 \sim \chi^{2}_{1}$$
Portanto $$z^2$$ e $$Q$$ possuem a mesma distribuição. Além disso, é possível provar (depois de bastante conta chata) que neste caso $$Q = z^2$$.

Deste modo, como $$Q$$ e $$z^2$$ possuem a mesma distribuição e são matematicamente iguais podemos afirmar que os dois testes são equivalentes!

Apesar deste resultado ser simples, para mim nunca tinha sido claro que as duas abordagens eram exatamente iguais!











