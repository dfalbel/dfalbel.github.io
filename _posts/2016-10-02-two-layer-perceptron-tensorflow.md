---
layout: post
title: 'Two Hidden Layer Perceptrons no Tensorflow pelo R'
date : 2016-10-02
tags: [r, tensorflow]
--- 



Em novembro de 2015, a Google abriu o código do [Tensorflow](https://www.tensorflow.org/) que pelo próprio site diz ser: 

>TensorFlow™ is an open source software library for numerical computation using data flow graphs. Nodes in the graph represent mathematical operations, while the graph edges represent the multidimensional data arrays (tensors) communicated between them. 

O TensorFlow é usado dentro de equipes de ponta do Google como o [Google Brain](https://research.google.com/teams/brain/) em pesquisas sobre machine learning e *deep neural networks*

Na semana passada o Rstudio abriu o código de um [pacote do R chamado `tensorflow`](https://github.com/rstudio/tensorflow) escrito, na sua maior parte pelo fundador do Rstudio, [JJ Allaire](https://github.com/jjallaire).

Esse post o meu primeiro passo com esse pacote. Note que ele é um pouco mais avançado do que o 
[*MNIST For ML Beginners*](https://rstudio.github.io/tensorflow/tutorial_mnist_beginners.html) do próprio tensorflow, e 
um pouco menos avançado que o [*Deep MNIST for Experts*](https://rstudio.github.io/tensorflow/tutorial_mnist_pros.html).
Reproduzi, no R, o [notebook](https://github.com/aymericdamien/TensorFlow-Examples/blob/master/notebooks/3_NeuralNetworks/multilayer_perceptron.ipynb) do [Aymeric Damien](https://github.com/aymericdamien) que implementa uma `multilayer perceptron` usando TensorFlow no python.

Não vou entrar em detalhes em como instalar o pacote `tensorflow`. Você pode encontrar facilmente as instruções [aqui](https://rstudio.github.io/tensorflow/).

# Preparação dos dados

Você passa dados para o tensorflow no formato de *multidimensional data arrays*, quando traduzimos
isso para o R, chegamos no formato de matrizes (`matrix`). Portanto, antes de mais nada, precisamos
processar os dados, que geralmente estão no formato de `data.frames`.

Disponibilizei uma parte do banco de dados mnist [aqui](https://github.com/dfalbel/dfalbel.github.io/tree/master/data). O mnist é um famoso banco de dados de imagens 28x28 de dígitos escritos à mão já marcadas com o número que representam. 

![mnistExamples](/images/mnistExamples.png)

Para ler no R use o seguinte comando:


{% highlight r %}
library(tidyverse)
mnist <- read_csv("https://github.com/dfalbel/dfalbel.github.io/blob/master/data/train.csv?raw=true")
{% endhighlight %}

Vamos tranformar o `mnist` em uma matriz `X` com uma coluna para cada pixel e uma matriz `Y` com uma
coluna para cada valor possível do label. Essa transformação para a matriz Y é chamada de [*one hot encoding*](https://en.wikipedia.org/wiki/One-hot) e é bem comum na preparação dos bancos de dados
para machine learning.


{% highlight r %}
X <- mnist %>% select(starts_with("pixel")) %>% as.matrix()
Y <- mnist %>% 
  select(label) %>% 
  mutate(id = row_number(), value = 1) %>% 
  spread(label, value, fill = 0) %>% 
  select(-id) %>%
  as.matrix()
{% endhighlight %}

Assim temos os nossos dois principais inputs para o TensorFlow. Vou ainda separar esses bancos em duas partes. Uma para treino e outra para teste.


{% highlight r %}
indices_train <- sample(1:nrow(X), size = 37000L)

X_train <- X[indices_train, ]
Y_train <- Y[indices_train, ]

X_test <- X[-indices_train, ]
Y_test <- Y[-indices_train, ]
{% endhighlight %}

# Definição do modelo

Agora vamos definir o modelo de two hidden layers perceptrons usando a interface do TensorFlow no R.
Para facilitar o código, estamos usando apenas 2 camadas ocultas, mas isso pode ser facilmente generalizável para quem entendeu este exemplo mais simples.

Vamos ajustar uma rede neural parecida com a do esquema abaixo, porém com mais neurônios e
com duas camadas.

![Neuralnet](/images/neural-net.png)
[Fonte](http://neuralnetworksanddeeplearning.com/chap1.html)


{% highlight r %}
library(tensorflow)
{% endhighlight %}

Em primeiro lugar definimos as propriedades da rede neural.


{% highlight r %}
# Network Parameters
n_hidden_1 = 256L # 1st layer number of features
n_hidden_2 = 256L # 2nd layer number of features
n_input = as.integer(ncol(X)) # MNIST data input (img shape: 28*28)
n_classes = as.integer(ncol(Y)) # MNIST total classes (0-9 digits)
{% endhighlight %}

Esta rede terá duas camadas ocultas, cada uma delas com 256 neurônios. O parâmetro `n_input` indica o tamanho do vetor que representa cada imagem. Neste caso ele possui dimensão 784 (28x28: o número de pixels da imagem). O `n_classes` representa a quantidade de classificações possíveis: 10, uma para cada número de 0 a 9.

No `tensorflow`, vamos definir o formato dos inputs, por meio de placeholders.


{% highlight r %}
x <- tf$placeholder(tf$float32, shape(NULL, n_input))
y <- tf$placeholder(tf$float32, shape(NULL, n_classes))
{% endhighlight %}

Estamos definindo `x` e `y` como arrays bidimensionais. Com `NULL` linhas e `n_input` ou `n_classes` colunas. `NULL` indica que não sabemos inicialmente a quantidade de linahs que vamos mandar.

Agora precisamos definir as matrizes de pesos e de viéses. Não quero entrar em muitos detalhes teóricos
sobre redes neurais, por isso recomendo, para quem não estiver muito confortável com a estrutura de
uma rede neural, a leitura [deste capítulo](http://neuralnetworksanddeeplearning.com/chap1.html) do livro de Michael Nielsen.


{% highlight r %}
# Weights
w_h1 <- tf$Variable(tf$random_normal(shape(n_input, n_hidden_1)))
w_h2 <- tf$Variable(tf$random_normal(shape(n_hidden_1, n_hidden_2)))
w_out <- tf$Variable(tf$random_normal(shape(n_hidden_2, n_classes)))

# Biases
b_h1 <- tf$Variable(tf$random_normal(shape(n_hidden_1)))
b_h2 <- tf$Variable(tf$random_normal(shape(n_hidden_2)))
b_out <- tf$Variable(tf$random_normal(shape(n_classes)))
{% endhighlight %}

`Variables` no TensorFlow são uma forma de definir os parâmetros de um modelo. Elas podem ser usadas e modificadas dentro do chamado *computation graph*. Inicializamos todos as variáveis com um número aleatório com dstribuição normal.

Definimos agora a arquitetura de cada uma das camadas do modelo a partir dos pesos e dos inputs.


{% highlight r %}
layer_1 <- tf$matmul(x, w_h1) + b_h1
layer_1 <- tf$nn$relu(layer_1)

layer_2 <- tf$matmul(layer_1, w_h2) + b_h2
layer_2 <- tf$nn$relu(layer_2)

out_layer <- tf$matmul(layer_2, w_out) + b_out
{% endhighlight %}

Aqui utilizamos a função de ativação [`rectifier`](https://en.wikipedia.org/wiki/Rectifier_(neural_networks)). Por isso definimos cada camada usando o `tf$nn$relu()`. O `tf$matmul()` apenas multiplica as duas matrizes dentro do TensorFlow. Na última camada usamos *linear activation* que é o padrão do `tensorflow`.

Agora vamos definir a função de custo e o algoritmos usado para a minimização.


{% highlight r %}
cost <- tf$reduce_mean(tf$nn$softmax_cross_entropy_with_logits(out_layer, y))
optimizer <- tf$train$AdamOptimizer(learning_rate = 0.001)
train_step <- optimizer$minimize(cost)
{% endhighlight %}

Definimos o custo como média da *softmax cross entropy* entre os logitos e os labels. De novo, não vou explicar exatamente o que é isso, mas acho que [essa é uma boa referência](http://stackoverflow.com/a/34243720/3297472). Usamos também o [Adam Optimizer](https://arxiv.org/pdf/1412.6980v8.pdf), uma explicação mais simples do porque está [aqui](http://stats.stackexchange.com/a/184497/44359).
A última linha é a que conecta o *optimizer* com a função de custo. A cada passo do treino, estamos dizendo para otimizador minimizar o custo.

Até agora, definimos qual seria o *computation graph* para este modelo. Chegou a hora de iniciar o treino do modelo.


{% highlight r %}
training_epochs <- 30 # número de vezes que passamos pelo banco inteiro
batch_size <- 100 # número de observações por batch
display_step <- 5 # a cada quantos passos você quer mostrar os resultados?
{% endhighlight %}

Dado estes parâmetros, a seguir fazemos o loop de treino. É comum fazer treinos em *batches* em *deep learning*. Você
poderia usar todos os seus dados em cada iteração do algoritmo, mas isso ficaria bem mais caro computacionalmente, por
isso usa-se uma pequena parte dos dados aleatoriamente em cada itereção.


{% highlight r %}
sess <- tf$Session()
sess$run(tf$initialize_all_variables())

for (i in 1:training_epochs){
  avg_cost <- 0
  total_batch <- floor(nrow(X_train)/batch_size)
  shuffle_index <- order(runif(n = nrow(X_train)))
  X_train <- X_train[shuffle_index,]
  Y_train <- Y_train[shuffle_index,]
  for(j in 1:total_batch){
    batch_x <- X_train[((j-1)*batch_size + 1):(j*batch_size),]
    batch_y <- Y_train[((j-1)*batch_size + 1):(j*batch_size),]
    sess$run(train_step, feed_dict = dict(x = batch_x, y = batch_y))
    avg_cost <- avg_cost + sess$run(cost, feed_dict = dict(x = batch_x, y = batch_y))/total_batch
  }
  if (i %% display_step == 0){
    print(sprintf("Epoch = %02d - Avg. Cost = %f", i, avg_cost))
  }
}
{% endhighlight %}



{% highlight text %}
## [1] "Epoch = 05 - Avg. Cost = 4242.010991"
## [1] "Epoch = 10 - Avg. Cost = 882.411263"
## [1] "Epoch = 15 - Avg. Cost = 147.514608"
## [1] "Epoch = 20 - Avg. Cost = 35.560549"
## [1] "Epoch = 25 - Avg. Cost = 20.462326"
## [1] "Epoch = 30 - Avg. Cost = 19.004497"
{% endhighlight %}

Podemos calcular o acerto do modelo na base de teste com o código a seguir. 


{% highlight r %}
prediction <- tf$argmax(out_layer, 1L) # indice da coluna com > evidencia
prediction <- sess$run(prediction, feed_dict = dict(x = X_test, y = Y_test)) # obter isso para a base de validacao
# pegar o true label da matriz (meio complicadinho,mas é isso)
true_label <- Y_test %>% 
  as.data.frame() %>% 
  mutate(id = row_number()) %>% 
  gather(key, value, -id) %>% 
  filter(value != 0) %>% 
  arrange(id) %>%
  with(key)
# Cruzando o predito com o verdadeiro:
sum(diag(table(true_label, prediction)))/nrow(X_test)
{% endhighlight %}



{% highlight text %}
## [1] 0.9456
{% endhighlight %}


