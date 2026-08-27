# Dawnforge (trilha Flutter) — Registro de mudanças

> Uma seção por versão, mais recente primeiro — um registro completo de versões (regra 34).
> Categorias, usadas nesta ordem, omitindo as não tocadas:
> `### 💥 Breaking Changes` · `### ✨ New` · `### 🔧 Changed` · `### ⚖️ Balance` ·
> `### 🐛 Fixed` · `### 🎨 Art & Audio` · `### 🧹 Internal`
>
> Uma seção nova é escrita como `## 0.0.0-NEXT` e carimbada pelo comando de commit
> (CLAUDE.md §Parallel sessions).

## 0.20.0

### 🧹 Internal

- Agora dá para ensinar o jogo a falar sobre ele mesmo. Até hoje só os nomes das
  coisas do mundo — um javali, uma ameixa, uma picareta — tinham palavras em cada
  idioma. As palavras que a própria tela precisa, como o título em cima da sua
  mochila, não tinham onde ser escritas. Agora têm, em inglês, português e
  espanhol de uma vez, e uma palavra que falte em um idioma para a construção do
  jogo em vez de te surpreender depois.

## 0.19.1

### 🧹 Internal

- O mundo sem fim passou no teste de velocidade: andando sem parar, o jogo
  ficou em 120 desenhos por segundo — o dobro da meta que ele precisava
  bater. A construção do mundo acompanha você.

## 0.19.0

### ✨ New

- A floresta ganhou vida: grama selvagem, palmeiras, arbustos, flores,
  rochas, carvão e cobre agora crescem pelo mundo todo, em grupinhos
  naturais — e o cobre se esconde em bolsões ricos que valem a caça. Cada
  mundo faz crescer a própria floresta a partir da semente, a mesma
  floresta toda vez que você replanta a mesma semente. Coisas sólidas são
  sólidas de verdade: você contorna uma árvore, não atravessa. (Página O
  Mundo do manual atualizada.)

## 0.18.0

### 🧹 Internal

- As coisas derrubadas ficaram de verdade: um item agora pode deitar no
  chão, balançar de leve, e voar para a sua mochila quando você chega
  perto — e ele é esperto sobre onde cai, nunca dentro de uma parede nem
  no mar, sempre em chão da sua própria altura. Se a mochila está cheia,
  ele espera no chão. Nada no mundo derruba itens AINDA — as ferramentas
  que quebram as coisas vêm em seguida.

## 0.17.0

### 🧹 Internal

- As mochilas existem agora, por dentro: um lugar com bolsos numerados onde
  as coisas podem ser guardadas, empilhadas e contadas, com regras justas —
  coisas iguais se juntam, bolso cheio diz não, e uma ferramenta sempre fica
  num bolso só dela. Ainda não dá para ver; a parte da tela vem depois.

## 0.16.0

### 🧹 Internal

- O jogo aprendeu a matemática dos tesouros: como uma chance decide se algo
  cai, e como um bônus de "mais itens" sempre significa MAIS — até um bônus
  pequeno agora paga a parte justa dele com o tempo, em vez de arredondar
  quieto para nada.

## 0.15.0

### 🧹 Internal

- Os arquivos de dados do jogo agora dizem o que cada rocha, árvore e criatura
  deixa para trás quando quebra — e como a floresta decide onde suas plantas,
  minérios e bichos podem morar. O jogo já sabe ler tudo isso; fazer acontecer
  na tela é o próximo passo.

## 0.14.1

### 🧹 Internal

- O diário de construção do projeto agora leva só os nomes de quem o constrói.
  Toda anotação antiga foi reescrita para tirar a assinatura de uma ferramenta,
  e entrou um guarda que se recusa a escrever outra.

## 0.14.0

### 🧹 Internal

- Um painelzinho de contadores apareceu no canto de cima: ele mostra a
  velocidade com que o jogo desenha e quanto trabalho a construção do mundo
  está fazendo a cada momento. Por enquanto é ferramenta de construtor —
  mais tarde vai se esconder atrás de uma opção.

## 0.13.0

### ✨ New

- Agora o mundo empurra de volta: a beira do mar e as paredes de montanha
  te param, em vez de deixar atravessar. Deslize ao longo de uma parede e
  você continua andando — só a direção bloqueada para. (Página O Mundo do
  manual atualizada.)

## 0.12.0

### ✨ New

- O mundo não acaba mais. O campinho verde se foi — agora todo jogo novo
  constrói um mundo inteiro a partir de uma semente: grama, mar e montanhas
  em degraus, diferente a cada vez, igual toda vez que você replanta a
  mesma semente. Ande o quanto quiser; o chão à frente aparece conforme
  você vai. Você começa num pedaço plano e seguro de grama. (Página nova
  do manual: O Mundo.)

## 0.11.0

### 🧹 Internal

- O mundo aprendeu a se construir em volta de você, pedaço por pedaço:
  enquanto você anda, o chão à frente vai aparecendo em silêncio e o chão
  lá atrás é guardado — um pouquinho a cada quadro, nunca tudo de uma vez,
  para o jogo continuar leve. Andar na beirada de um pedaço nunca faz ele
  piscar. Quarto de cinco passos rumo ao mundo sem fim; o último o coloca
  na tela.

## 0.10.1

### 🧹 Internal

- Uma checagem interna que às vezes gritava alarme falso em computadores
  ocupados aprendeu a esperar a vez dela: agora observa o jogo REALMENTE
  terminar de acordar, em vez de contar um número fixo de piscadas.

## 0.10.0

### 🧹 Internal

- A memória de mapa do jogo cresceu: agora ela lembra qual tile de chão
  está em cada lugar, e a altura de cada degrau de montanha — sem gastar
  memória extra com tiles que ninguém mexeu. Água e penhasco aprenderam a
  dizer o que são. Terceiro de cinco passos rumo ao mundo sem fim.

## 0.9.0

### 🧹 Internal

- Nasceu o gerador de mundo: dê a ele um número-semente e ele decide, para
  qualquer lugar que você perguntar, se ali tem água, grama ou montanha — e
  sempre dá a mesma resposta para a mesma semente. Montanhas sobem em
  degraus, como uma pirâmide, e o ponto de partida é sempre chão plano.
  Ainda nada na tela — segundo de cinco passos rumo ao mundo sem fim.

## 0.8.0

### 🧹 Internal

- O mundo aprendeu sua primeira receita de fazer chão: os números de terreno
  da floresta (quanta água, quanta montanha) agora viajam do pack para o
  jogo, junto com o tile de chão natural que eles vão pintar. Nada visível
  ainda — primeiro de cinco passos rumo a um mundo que não acaba.

## 0.7.1

### 🐛 Fixed

- O jogo estava invisível — um campo verde sem nada nele. Dois defeitos,
  ambos corrigidos: as coisas estavam sendo colocadas fora de onde a câmera
  olha, e toda imagem animada estava sendo desenhada 16 vezes menor do que
  deveria.

## 0.7.0

### ✨ New

- O jogo abriu os olhos: um javali que você guia com o teclado (WASD ou
  setas), num campo verde com uma palmeira, pedras e plantas em volta. A
  câmera te acompanha. É pequeno, mas é a primeira coisa que dá para JOGAR.

## 0.6.0

### 🎨 Art & Audio

- As imagens chegaram: o jogo agora recorta cada sprite da mesma folha de arte
  grande que a versão Godot usa — 22 sprites reais, e um quadrado colorido de
  espera para as 14 coisas que ainda não têm arte final.

## 0.5.0

### 🧹 Internal

- O jogo agora sabe falar três línguas: os nomes e descrições escritos para a
  versão Godot (inglês, português, espanhol) carregam aqui também — 228 linhas
  de texto, com uma checagem de build que pega qualquer língua com linha
  faltando.

## 0.4.0

### 🧹 Internal

- As criaturas aprenderam a se mover, olhar para os lados, se machucar, curar
  aos poucos e morrer — as mesmas regras da versão Godot, funcionando aqui
  agora. Ainda nada na tela: a parte de desenhar vem em seguida.

## 0.3.0

### 🧹 Internal

- O livro de conteúdo do jogo começou a funcionar: os mesmos arquivos que
  descrevem itens, plantações e criaturas na versão Godot agora são lidos aqui
  também. As primeiras 38 coisas — trigo, tomate, trevo e companhia — carregam
  corretamente.

## 0.2.0

### 🧹 Internal

- O motor aprendeu a forma de cada coisa do mundo: atores, objetos, pisos e
  itens agora existem como dados que o jogo sabe ler, e as fábricas que os
  constroem com segurança. Ainda nada jogável — isto é trabalho de fundação.

## 0.1.0

### 🧹 Internal

- O projeto recomeçou como a trilha de estudo Tessera-Dart: o jogo antigo foi arquivado
  e um novo motor, portado da versão Godot do Dawnforge, começou. Nada está jogável
  ainda.
