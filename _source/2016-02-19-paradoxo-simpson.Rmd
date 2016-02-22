---
layout: post
title: 'O paradoxo de Simpson'
date : 2016-02-22
tags: [estatistica]
--- 

Está em fase de pré-venda um 
[novo livro do Judea Pearl](http://www.amazon.com/Causal-Inference-Statistics-Judea-Pearl/dp/1119186846/ref=sr_1_1?ie=UTF8&qid=1452539578&sr=8-1&keywords=judea+pearl+primer) 
sobre inferência causal em estatística. Achei interessante que no primeiro capítulo do livro, [disponibilizado aqui](http://bayes.cs.ucla.edu/PRIMER/)
logo após a motivação de se estudar causalidade, Pearl fala sobre o [paradoxo de Simpson](https://en.wikipedia.org/wiki/Simpson%27s_paradox).

Nomeado em memória de Edward Simpson (1922), o primeiro estatístico a popularizá-lo, o paradoxo refere-se a existência de dados nos quais a associação estatística que é valida para a população inteira é revertida em todas as subpopulações, quando consideramos algum agrupamento.

O exemplo clássico do Simpson é de um grupo de pacientes doentes que tiveram a opção de tentar um remédio novo. Os resultados obtidos foram os seguintes.

              | Drug                           | No drug
--------------------------------------------------------------------------------
Men           | 81 out of 87 recovered (93%)   | 234 out of 270 recovered (87%)
Women         | 192 out of 263 recovered (73%) | 55 out of 80 recovered (69%)
Combined data | 273 out of 350 recovered (78%) | 289 out of 350 recovered (83%)

Entre todos os que testaram a nova droga, uma porcentagem menor dos que usaram o 
remédio se recuperaram do que entre os que não o utilizaram. No entanto, Os homens 
que usaram o remédio se recuperaram mais do que os que não usaram. O Mesmo acontece 
para as mulheres: a proporção de recuperação dentre as mulheres que usaram a droga 
é maior do que dentre as que não. Isso parece contraditório, se soubermos o sexo do 
indivíduo, não importanto qual ele seja, é melhor tratá-lo com o novo remédio, 
mas se não soubermos é melhor não tratá-lo com o novo medicamento.

**Surge então a dúvida**: se o governo fosse decidir sobre a adoção de uma política de uso 
desse novo medicamento, que decisão ele deveria tomar?

A resposta de Pearl, em seu livro, é muito completa. Ele diz: 

> A resposta não pode ser encontrada em estatística simples. Para poder decidir se a droga 
> irá ajudar ou prejudicar o paciente, primeiramente é necessário entender a história por
> trás dos dados - a história que geraram os resultados observados. Suponha que sabemos de um fato 
> adicional: Estrógeno tem um efeito negativo na recuperação, então mulheres tem menos chance de 
> se recuperar do que os homens, não importando o novo medicamento. Adicionalmente, como podemos
> ver pelos dados, mulheres têm significativamente mais chance de tomar o novo medicamento do que
> os homens. Então, a razão pela qual o medicamento parece ser prejudicial para a população em geral,
> se selecionarmos um usuário do medicamente aleatóriamente, essa pessoa tem mais chance de ser uma mulher,
> que tem menor chance de recuperação do que uma pessoa que não tomou o medicamento. (...)
> Por isso, para analisar corretamente, precisamos comparar individuos do mesmo gênero, assim assegurando que
> qualquer diferença nas taxas de recuperação entre aqueles que tomam ou não o medicamento
> **não** é devida à presença do estrógeno. Isso significa que devemos consultar os dados segregados,
> que nos mostra inequivocadamente que o medicamento é útil.










