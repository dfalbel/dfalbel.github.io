---
layout: post
title: 'Meu primeiro passo com d3'
date : 2015-11-17
tags: [d3]
--- 

<script src = "http://d3js.org/d3.v3.min.js"></script>

A maioria das visualizações originais feitas atualmente são feitas usando o [d3.js](http://d3js.org/). Existem diversos exemplos na internet, mas gosto especialmente desses aqui:

* [At the National Conventions, the Words They Used](http://www.nytimes.com/interactive/2012/09/06/us/politics/convention-word-counts.html?_r=0#Better)
* [Visualizing Algorithms](http://bost.ocks.org/mike/algorithms/)

Essas duas foram feitas pelo Mike Bostock, criador do [d3.js](http://d3js.org/).

Neste post vou colar meu primeiro passo com essa ferramente. Realmente o primeiro passo! 
Coloquei no meio da tela, alguns círculos, cujo tamanho e posição são determinados por um banco de dados.
Veja o script:

<post>

{% highlight js %}

// meus dados
var array = [ 
  {"x": 10, "y": 20, "r": 10},  
  {"x": 10, "y": 70, "r": 10},  
  {"x": 50, "y": 40, "r": 10},  
  {"x": 30, "y": 10, "r": 10},  
  {"x": 170, "y": 140, "r": 20},  
  {"x": 300, "y": 100, "r": 30},  
  ];

// O SVG Container
var svgContainer = d3.select("post").append("svg")
                                    .attr("width", 350)
                                    .attr("height", 200);

// O gráfico
svgContainer
  .selectAll("circles")
  .data(array)
  .enter()
  .append("circle")
  .attr("cx", function(d) {return d.x})
  .attr("cy", function(d) {return d.y})
  .attr("r", function(d) {return d.r});

{% endhighlight %}


<script>

// meus dados
var array = [ 
  {"x": 10, "y": 20, "r": 10},  
  {"x": 10, "y": 70, "r": 10},  
  {"x": 50, "y": 40, "r": 10},  
  {"x": 30, "y": 10, "r": 10},  
  {"x": 170, "y": 140, "r": 20},  
  {"x": 300, "y": 100, "r": 30},  
  ];

// O SVG Container
var svgContainer = d3.select("post").append("svg")
                                    .attr("width", 350)
                                    .attr("height", 200);

// O gráfico
svgContainer
  .selectAll("circles")
  .data(array)
  .enter()
  .append("circle")
  .attr("cx", function(d) {return d.x})
  .attr("cy", function(d) {return d.y})
  .attr("r", function(d) {return d.r});

</script>

Bonitinho né? Ainda vou estudar bastante essa ferramenta, mas por enquanto estou achando a forma de construção das visualizações muito interessante!

</post>
