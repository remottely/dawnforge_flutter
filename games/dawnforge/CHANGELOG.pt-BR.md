# Dawnforge (trilha Flutter) — Registro de mudanças

> Uma seção por versão, mais recente primeiro — um registro completo de versões (regra 34).
> Categorias, usadas nesta ordem, omitindo as não tocadas:
> `### 💥 Breaking Changes` · `### ✨ New` · `### 🔧 Changed` · `### ⚖️ Balance` ·
> `### 🐛 Fixed` · `### 🎨 Art & Audio` · `### 🧹 Internal`
>
> Uma seção nova é escrita como `## 0.0.0-NEXT` e carimbada pelo comando de commit
> (CLAUDE.md §Parallel sessions).

## 0.38.0

### 🔧 Changed

- Clicar com uma coisa que não é ferramenta — uma tora, um pedaço de minério —
  não custa mais um golpe. Nunca ia acontecer nada, e mesmo assim você tinha que
  esperar os dois segundos inteiros. Apertar com uma tora na mão não é um golpe
  que falhou; é golpe nenhum, e agora o jogo concorda.

### 🧹 Internal

- O que um item FAZ quando você aperta agora é assunto do próprio item, e não do
  jogador. Dar um golpe com uma ferramenta e pousar uma coisa no chão não são
  dois ajustes de uma ação só — procuram alvos diferentes, fazem perguntas
  diferentes e gastam coisas diferentes — então cada tipo de item ganha o seu
  pedacinho de código que conhece o próprio feito. Nada do que dá para ver mudou
  além da linha acima; essa é a forma de que o próximo passo precisa para
  existir.
- Um aperto agora volta com três respostas em vez de duas: não aconteceu nada,
  aconteceu e não deu em nada, aconteceu e acertou. Só a do meio te custa a
  espera, e só o item sabe diferenciar.

## 0.37.0

### 🧹 Internal

- **Chão pode virar outro chão.** Deite uma ponte sobre a água, ou um piso
  sobre um buraco, e o quadradinho deixa de ser água: dá para andar em cima, e
  o desenho na tela se refaz para mostrar. As duas metades importam — o
  quadradinho mudar e a tela mudar são dois fatos separados aqui, porque o chão
  é pintado um pedação inteiro de cada vez, e isso é o fio entre eles.
- A mesma regra sobre gente vale aqui, e quem escolhe é o próprio chão. Uma
  ponte é uma coisa em que você **pisa**, então ela pode aparecer embaixo de um
  pé que já está pendurado na beira da água. Chão maciço não é, então não pode
  — isso seria fechar o chão em cima de alguém que está dentro dele.
- Dois limites sinceros. Um quadradinho de chão ainda não vai **em cima** de
  outro; levantar a terra em morros é um trabalho bem maior e vem depois. E uma
  ponte que você constrói e depois se afasta some quando você volta: o mundo
  esquece tudo que não está mostrando no momento, que é o mesmo acordo que uma
  árvore derrubada já faz. O jogo aprender a lembrar é um passo próprio.
- Ninguém consegue construir nada disso ainda — o botão que gasta o item é o
  próximo.

## 0.36.0

### 🧹 Internal

- O jogo agora sabe dizer se uma coisa pode ser construída num quadradinho —
  e, o que importa mais, **qual regra disse que não**. São três até agora. Tem
  alguém em pé ali e a coisa tiraria o chão dessa pessoa (uma tocha não tira,
  então tocha no seu pé pode; um buraco no chão tira, e muito). Já tem outra
  coisa naquele quadradinho. Ou não tem em que construir: o vazio além da borda
  do mundo, ou água — e a água recusa sozinha, não por causa de uma regra
  escrita sobre água.
- Cada uma dessas perguntas vale para **todos** os quadradinhos que a coisa
  ocupa, não só o que está embaixo do seu dedo. Uma fundição tem dois
  quadradinhos de largura, e uma fundição construída em volta de você te prende
  exatamente igual a uma construída em cima de você.
- Ninguém consegue construir ainda — esta é a parte que decide, não a que faz.

## 0.35.0

### 🧹 Internal

- Alguns itens agora são **plantas de construção**: em vez de serem uma coisa
  que você segura, são uma coisa que você põe no chão. Um item desses carrega o
  nome do que ele constrói, e o jogo procura esse nome do mesmo jeito que
  procura todo o resto — então uma planta que nomeia algo que ninguém desenhou
  é pega na hora em que é lida, e não na hora em que você tenta construir.
- As quatro primeiras vieram do pacote de design: uma fundição de cobre (a
  oficina onde se derrete pedra), uma ponte de palmeira e dois tipos de chão.
  Nada põe essas coisas na sua mochila ainda e nada as coloca no mundo ainda —
  isso são os próximos passos. Este aqui é o item saber o que ele é.

## 0.34.1

### 🧹 Internal

- O diário de construção fechou o trabalho das ferramentas: nove passos, de
  "tem alguém aí" até uma árvore que cai quando você clica nela. Ele também
  anotou as quatro coisas que ficaram de fora de propósito, para ninguém
  precisar adivinhar se foram esquecidas.

## 0.34.0

### ✨ New

- **Dá para colher.** Aponte para uma árvore com um machado na mão e clique —
  ou toque com o dedo — e ela leva a batida. Continue e ela se desfaz, e aquilo
  de que ela era feita cai no chão onde ela estava e vem para você quando você
  passa perto. Essa é a primeira coisa do jogo que é de verdade um jogo: você
  faz alguma coisa, e o mundo fica diferente depois.

  Quatro coisas que vale saber. Você bate **exatamente onde aponta**, nunca no
  quadradinho do lado. Cada coisa diz o que pode quebrá-la — um regador não faz
  nada numa árvore, e um machado fraco não faz nada numa pedra forte, e esses
  são dois problemas diferentes. **Mão vazia também conta**: as suas duas mãos
  são uma ferramenta de verdade, fracas e lentas e suficientes para mato e
  ervas, então você nunca fica sem poder tocar no mundo. E você precisa estar
  perto — o seu alcance é o da sua ferramenta, mais ou menos um quadradinho na
  maioria delas.

  A sua mão ainda não dá o golpe na tela; a árvore leva a batida e cai, mas
  ninguém desenhou o movimento ainda. (Página nova do manual: Colhendo.)

## 0.33.0

### 🧹 Internal

- Uma ação agora guarda para onde ela foi mirada, medida uma vez só, no
  instante em que o botão desceu. Parece pouco, mas é a diferença entre uma
  flecha ir para onde você apontou e uma flecha ir para trás: se o jogo for
  calcular a direção depois, quando você já andou e passou do lugar que mirou,
  a direção sai invertida. Então a mira é tirada uma vez e carregada inteira.

## 0.32.0

### 🧹 Internal

- O jogo agora sabe para onde você está apontando. É uma resposta só para
  todo mundo: o mouse andando pela janela e o dedo tocando a tela movem o
  mesmo cursor, e quem precisa saber pergunta nesse único lugar. A resposta é
  calculada de novo toda vez que alguém pergunta, porque dá para andar com o
  mouse parado — e aí o quadradinho para onde você aponta muda mesmo sem a sua
  mão mexer. Nada mira com isso ainda; esse é o próximo passo.

## 0.31.1

### 🧹 Internal

- O diário de construção se acertou com o golpe, e anotou o que o último passo
  precisa antes de alguém começar: o jogo ainda não faz ideia de onde o seu
  mouse está apontando, e existe exatamente um lugar que tem permissão de saber.

## 0.31.0

### 🧹 Internal

- O golpe existe. Aponte para uma árvore com um machado na mão e ela leva duas
  machadadas e cai, e as toras aparecem onde ela estava — a primeira vez neste
  projeto que uma coisa que o jogador faz muda o mundo. A força da batida vem
  da própria ferramenta, escrita nos dados dela: mão nua dá um cutucão, machado
  dá uma mordida. A enxada continua não fazendo nada numa árvore, e uma mão que
  não segura nada nunca está vazia, então sempre tem o que golpear. Nada disso
  está ligado ao seu mouse ainda — esse é o último passo deste trabalho.

## 0.30.0

### 🧹 Internal

- As coisas do mundo agora podem ser quebradas, e quebrar uma é o que deixa o
  que ela guarda no chão. Uma árvore com quatro pontos de vida leva duas
  machadadas e cai; as toras que ela foi escrita para dar aparecem onde ela
  estava, porque o toco solta o quadradinho dele na hora em que morre, em vez
  de ficar na frente das próprias toras. A ferramenta errada continua não
  fazendo nada, e a certa também não faz nada em cima de uma coisa onde tem
  alguém em pé. Ninguém consegue dar o golpe ainda — essa é a última peça.

## 0.29.1

### 🧹 Internal

- O índice do diário de construção se acertou de novo: o portão que decide se
  um golpe é permitido está pronto e testado, então as anotações não listam
  mais ele como a próxima coisa a fazer.

## 0.29.0

### 🧹 Internal

- Um lugar só do jogo agora decide se você tem permissão de bater em alguma
  coisa, e decide numa ordem só. Ele pergunta se a sua ferramenta é do tipo
  certo e boa o bastante, e não deixa nada ser tirado de baixo de uma pessoa
  que está em cima — a não ser que a coisa diga que não se importa, o que um
  arbusto diz e uma escada não. A plantação passa de propósito na frente:
  cavar com a enxada, regar e plantar não tiram o chão de ninguém, então você
  continua podendo trabalhar o quadradinho em que está pisando. Nada dá golpe
  ainda; o golpe é o próximo, e vai perguntar isso aqui.

## 0.28.1

### 🧹 Internal

- O índice do diário de construção se acertou com o trabalho das ferramentas:
  ele ainda dizia que só o primeiro dos seis passos estava pronto, quando três
  estão.

## 0.28.0

### 🧹 Internal

- O jogo agora sabe o que você está segurando. O espaço marcado na sua barra é
  a coisa que está na sua mão, e se o que está nesse espaço mudar enquanto ele
  estiver marcado — você usa o último, ou você larga — a sua mão muda junto.
  Espaço vazio não quer dizer mão vazia: você está segurando as suas próprias
  duas mãos, e elas contam como uma ferramenta de verdade, então nunca existe
  um momento em que você não consegue tocar no mundo. Os bichos seguram aquilo
  com que nasceram — as presas do javali são a arma dele, e bolsa nenhuma muda
  isso. Nada dá golpe ainda; o golpe é o próximo passo.

## 0.27.1

### 🧹 Internal

- A caixa de ferramentas que transforma este projeto num aplicativo de Android
  estava ficando velha, e avisava em voz alta toda vez que o jogo era aberto:
  três alertas sobre peças que o Flutter está prestes a parar de aceitar. As
  três peças agora são novas — o Gradle, o plugin do Android, o Kotlin — e os
  três alertas sumiram. O jogo em si não foi mexido; só a máquina que o embala.
  Um alerta fica e ainda não tem como sair: o Kotlin precisa continuar sendo
  buscado à mão, porque a cópia que vem dentro do plugin novo do Android é mais
  velha do que a que o Flutter exige.

## 0.27.0

### 🧹 Internal

- As ferramentas e as coisas que elas quebram finalmente se enxergam. Toda
  rocha, árvore e caixote do jogo já dizia quais ferramentas podem tocar nele e
  quão boas elas precisam ser; toda ferramenta já dizia qual ela é e quão boa
  ela é. O jogo é que não estava lendo nada disso. Agora lê, e sabe separar as
  duas perguntas: "você precisa de um machado" não é a mesma coisa que "você
  precisa de um machado melhor". Nada bate ainda — a batida é a próxima.

## 0.26.1

### 🧹 Internal

- O diário de construção anotou a ordem em que o trabalho das ferramentas tem
  que acontecer, e as duas armadilhas escondidas nela, enquanto ainda estavam
  frescas da leitura.

## 0.26.0

### 🧹 Internal

- O jogo aprendeu a responder direito uma pergunta, antes de qualquer coisa
  construir ou quebrar: **tem alguém aí?** Ele olha o espaço que os pés de uma
  pessoa realmente ocupam, não o quadradinho mais perto dela, e olha todos os
  quadradinhos que uma coisa ocuparia, não só o cantinho. E se uma coisa pode
  aparecer ou sumir embaixo de você está escrito nos dados dela mesma — um
  arbusto pode ser plantado no seu pé e quebrado ali; uma escada não, porque
  tirar ela muda o chão onde você está. Nada usa essa resposta ainda; as
  ferramentas que vão usar vêm em seguida.

## 0.25.1

### 🧹 Internal

- O diário de construção marcou o trabalho da mochila como terminado, e anotou
  as duas coisas que ficaram de fora de propósito, para ninguém começá-las sem
  querer.

## 0.25.0

### ✨ New

- A sua mochila abre. Aperte **I** ou **Tab** e os trinta bolsos estão lá;
  aperte **Esc** para fechar. Arraste uma coisa para cima de outro bolso e a
  coisa certa acontece sozinha: bolso vazio recebe a pilha, bolso com a mesma
  coisa junta as pilhas, e bolso com outra coisa troca as duas de lugar.
  Segure **Shift** enquanto arrasta para levar só metade. Arraste uma coisa
  para fora da mochila e solte no mundo para pousá-la no chão, no seu pé.

  E olhe atrás dela enquanto está aberta: as árvores continuam lá, embaçadas, e
  o mundo continua andando. **O jogo nunca para.** Você não consegue agir com a
  mochila aberta, mas o tempo não te espera — então não é lugar de se esconder.
  (Página nova do manual: A Mochila.)

## 0.24.2

### 🐛 Fixed

- Uma coisa que você larga agora consegue ficar largada. Cada item já dizia, nos
  dados dele, quanto tempo devia descansar no chão antes de alguém poder pegar —
  meio segundo — e o jogo não estava lendo essa linha. Então qualquer coisa que
  caísse no seu pé era puxada de volta para a mochila no instante seguinte, o
  que tornaria impossível pousar qualquer coisa. Agora ela fica lá, espera o meio
  segundo dela, e só então vem para você.

## 0.24.1

### 🧹 Internal

- O índice do diário de construção do projeto se acertou com o trabalho: as
  anotações que dizem o que está pronto e o que vem a seguir ainda descreviam as
  telas da mochila como intocadas.

## 0.24.0

### ✨ New

- A sua mochila ganhou um rosto. Uma barra de dez bolsos apareceu embaixo da
  tela, e um deles está sempre com a borda amarela acesa — é o bolso de onde
  você está segurando. Aperte uma tecla de número, aperte `Q` ou `E`, ou
  simplesmente toque num bolso para escolher outro. A sua mochila tem trinta
  bolsos, então a barra mostra dez por vez e **Page Up** / **Page Down** viram
  a página; as bolinhas embaixo dizem em qual página você está. As coisas que
  você pega aparecem nela na hora, com um numerinho quando você tem mais de
  uma. (Página nova do manual: A Barra de Itens.)

## 0.23.0

### 🔧 Changed

- Você não é mais um javali. Até agora o personagem que você levava para
  passear era literalmente um dos bichos da floresta, emprestado porque ninguém
  tinha feito um jogador ainda — e javali não tem bolso, então cada coisinha
  que o mundo derrubava batia em você e ficava na grama. Agora você é você, com
  uma mochila de trinta bolsos. Dois avisos honestos: por enquanto você é
  desenhado como um quadradinho colorido, porque a arte de uma pessoa ainda não
  está no jogo, e você ainda não consegue abrir a mochila — a tela dela é a
  próxima coisa.

## 0.22.0

### 🧹 Internal

- O jogo agora tem um lugar só que sabe o que está na sua tela. Só uma janela
  grande pode ocupar a tela por vez, então abrir a mochila em cima do mapa
  guarda o mapa sozinho, em vez de deixar duas coisas empilhadas uma sobre a
  outra. As coisinhas do canto — a sua barra de itens, os seus corações —
  voltam no instante em que a última janela fecha, sempre, porque uma regra só
  decide isso em vez de cada janela ter que lembrar. E o botão Voltar agora vai
  para um lugar exato: quem está por cima responde, então um aperto só nunca
  consegue fechar uma coisa e abrir outra ao mesmo tempo.

## 0.21.0

### 🧹 Internal

- As mochilas aprenderam os movimentos que suas mãos fazem. Até agora a mochila
  só sabia decidir sozinha onde uma coisa nova ia parar. Agora dá para pôr uma
  coisa no bolso que você escolher, tirar do bolso que você apontar, despejar
  no bolso do lado até ele encher, ou passar para outra mochila inteira — e
  quando duas coisas diferentes se encontram, elas simplesmente trocam de
  bolso. Nada na tela ainda: essa é a engrenagem embaixo do arrastar que vem
  em seguida.

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
