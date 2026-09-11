# Dawnforge (trilha Flutter) — Registro de mudanças

> Uma seção por versão, mais recente primeiro — um registro completo de versões (regra 34).
> Categorias, usadas nesta ordem, omitindo as não tocadas:
> `### 💥 Breaking Changes` · `### ✨ New` · `### 🔧 Changed` · `### ⚖️ Balance` ·
> `### 🐛 Fixed` · `### 🎨 Art & Audio` · `### 🧹 Internal`
>
> Uma seção nova é escrita como `## 0.0.0-NEXT` e carimbada pelo comando de commit
> (CLAUDE.md §Parallel sessions).

## 0.74.0

### 🔧 Changed

- Quando você aperta Organizar e duas coisas são igualmente boas, agora elas
  ficam na ordem dos nomes, como as palavras numa lista. Antes elas ficavam na
  ordem de um código que o jogo usa só por dentro, que ninguém consegue ler.

### 🧹 Internal

- Toda coisa do jogo sempre carregou o nome que ela mostra para você, no seu
  idioma, e nada no jogo tinha lido esse nome até hoje. Agora o jogo sabe ler.
  É disso que a bancada precisa para dizer o que ela vai fazer.

## 0.73.1

### 🐛 Fixed

- Uma versão do jogo entrou no diário sem página nenhuma. A página está
  escrita logo abaixo, sob o número a que ela pertence.

## 0.73.0

### 🧹 Internal

- Nada mudou no jogo. Quem constrói o jogo agora tem três rotinas escritas.
  Uma diz onde tudo está quando alguém senta para trabalhar, para ninguém
  precisar adivinhar. Uma procura tudo o que o projeto já anotou, para a mesma
  pergunta não ser resolvida duas vezes. Uma roda as cinco conferências e
  explica o que significa uma delas ficar vermelha — inclusive uma que pode
  ficar vermelha só porque o computador estava ocupado com outra coisa, o que
  antes custava uma tarde inteira toda vez que alguém esbarrava nela.

## 0.72.0

### 🧹 Internal

- Nada mudou no jogo. Agora existe uma página que anota como o jogo é feito
  por dentro: para que serve cada pasta, o que acontece e em que ordem quando
  o jogo liga, como funciona o relógio que faz o mundo andar e como um menu
  impede você de agir sem nunca congelar o mundo atrás dele. A página só pode
  dizer coisas que já são verdade, e cada parte dela avisa em qual versão foi
  conferida — assim ninguém lê uma promessa velha e acredita nela. Conferir
  cada linha antes de anotar encontrou uma regra que aponta para um pedaço do
  jogo que nunca foi construído.

## 0.71.0

### 🐛 Fixed

- A lista de mudanças tinha duas anotações no lugar errado. Faltava a anotação
  sobre a tecla nova de "alcançar a coisa", e a anotação sobre contar a máquina
  estava arquivada com o número errado. As duas voltaram para o lugar certo.
  Nada estava errado no jogo em si — só no diário dele.

## 0.70.0

### 🧹 Internal

- Nada mudou no jogo. Alguém contou a máquina. O jogo irmão maior é feito de
  **560 peças de código**; este jogo menor tem **112** delas, uma em cada cinco.
  A contagem foi feita um tipo de peça por vez, então agora existe uma lista do
  que falta e de qual trabalho futuro traz cada coisa. A surpresa: as peças que
  decidem **como as coisas são feitas** estão quase todas aqui, e as peças que
  fazem **telas e menus** estão quase todas faltando — 4 de 87. É um dos motivos
  de o jogo ainda parecer tão simples.
- Duas observações saíram da contagem. Existe aqui uma pasta de código de
  desenho que o jogo irmão maior não precisa, porque naquele motor a coisa se
  desenha sozinha e neste alguém precisa desenhar. E o jogo maior tem **uma
  única exceção** à regra "nunca adivinhe, pare na hora", usada só ao carregar
  um save antigo. Este jogo ainda não precisa dessa exceção, porque aqui os
  saves antigos são simplesmente jogados fora.

## 0.69.0

### 🔧 Changed

- As teclas que andam com a borda amarela pela sua barra de itens mudaram.
  Antes eram `Q` e `E`; agora são `[` e `]`, as duas teclas logo à direita do
  `P`. O `E` precisava ficar livre, porque a partir de agora ele é a tecla que
  quer dizer "usar a coisa para onde estou apontando".

### 🧹 Internal

- O jogo aprendeu a ideia de alcançar uma coisa em vez de bater nela. Aponte
  para uma bancada, aperte `E`, e a bancada agora escuta você — de tão longe
  quanto aquele tipo de bancada disser que pode ser usada, o que o jogo lê da
  própria bancada em vez de chutar. No celular ou no tablet não existe tecla
  `E`, então um toque faz as duas coisas: toque em algo que dá para usar e
  você usa, toque em qualquer outra coisa e você bate nela como antes. Ainda
  não abre nada na tela — a janela que a bancada vai mostrar é o próximo
  pedaço de trabalho.

## 0.68.0

### 🧹 Internal

- Nada mudou no jogo. O jogo irmão maior conhece **51 apertos de botão
  diferentes** — andar, bater, alcançar, abrir a mochila, jogar uma coisa fora,
  virar a página do cinto. Este jogo menor responde a **22** deles. Alguém
  sentou e listou cada um: quais estão aqui, quais faltam e quais nunca vão vir
  (alguns são do jogo de blocos, e aqui ninguém pula). Três são diferentes de
  propósito: `Tab` abre a mochila aqui e vira o cinto lá, e é muito mais fácil
  escolher um agora do que depois que uma página de ajuda contar a coisa errada
  para quem joga.
- Duas surpresas saíram da lista. O jogo irmão maior pode ser jogado com
  **controle** e nunca com o dedo. Este jogo pode ser jogado com o **dedo** e
  não com controle nenhum. E, com a mochila aberta, apertar um número ainda
  troca a ferramenta da mão, porque o jogo decide "isso pode agora?" em cinco
  lugares diferentes em vez de um só. Os dois ficaram anotados com o conserto ao
  lado.

## 0.67.0

### 🧹 Internal

- Nada mudou no jogo. Quando desenhos ou dados novos entram, o jogo também
  precisa ser AVISADO para empacotá-los no aplicativo — e se ninguém escrever
  essa linha, parece tudo certo até a hora em que o jogo procura o desenho e
  não acha nada. Hoje as 27 linhas estão certas. Agora está anotado que todo
  lote futuro de conteúdo novo deve uma linha, e que um conferidor pequeno
  deveria vigiar isso, para a sequência boa ser mantida por uma máquina e não
  pela memória.

## 0.66.0

### 🧹 Internal

- Nada mudou no jogo. O motivo de existir esta versão menor do jogo é
  descobrir se dá para construir um jogo novo em cima dela só escrevendo
  páginas novas — sem mexer na máquina de baixo. Ninguém tinha testado. Agora
  virou uma tarefa de verdade, com linha de chegada clara: fazer um joguinho
  de faz de conta com duas páginas, ligar, e conferir que nenhuma linha da
  máquina precisou mudar. Uma primeira olhada diz que a máquina escreve o nome
  do próprio jogo em um lugar só, o que é um ótimo sinal.

## 0.65.0

### 🧹 Internal

- Nada mudou no jogo. O plano prometia que três coisas seriam feitas de um
  jeito que deixasse espaço para, um dia, jogar junto pela internet. Duas
  estão sendo cumpridas. A terceira — em que apertar um botão vira uma
  ordenzinha escrita que o jogo depois executa, em vez de o jogo esticar o
  braço e ler o teclado sozinho — nunca começou, e cada ação nova deixa isso um
  pouco mais trabalhoso de acrescentar depois. Agora está anotado como uma
  pergunta para o desenvolvedor, com os motivos dos dois lados.

## 0.64.0

### 🧹 Internal

- Nada mudou no jogo. Quando esta versão do jogo foi planejada, alguém anotou
  cinco coisas que podiam dar errado. Dezessete dias depois, ninguém tinha
  voltado para ver quais deram. Agora voltaram: três seguiram como o plano
  esperava, uma foi riscada e uma aconteceu de verdade — as páginas escritas
  que este jogo divide com o irmão maior tinham se afastado em silêncio, e a
  rede de segurança citada no plano nunca foi do tipo que pega isso. A rede de
  verdade já existe. Dois problemas que ninguém tinha imaginado também estão
  anotados.

## 0.63.0

### 🧹 Internal

- Nada mudou no jogo. O livrinho que explica como jogar é escrito duas vezes,
  uma em inglês e outra em português, e as duas cópias deveriam ter as mesmas
  páginas com as mesmas partes na mesma ordem. Ninguém estava conferindo. Uma
  página que sumisse em um idioma só seria notada por uma criança lendo aquele
  idioma, o que é tarde demais. Agora a conferência acontece antes de qualquer
  trabalho ser arquivado. Um pedaço dela ainda espera uma decisão, e ele avisa
  isso em voz alta em vez de fingir que conferiu tudo.

## 0.62.0

### 🧹 Internal

- Nada mudou no jogo. A contagem de ontem das páginas escritas que faltam
  ganhou uma segunda metade: até as páginas que a gente copiou foram aparadas
  na entrada, porque uma página só pode falar de coisas que o jogo já sabe
  ler. Alguém contou as linhas aparadas — 932 delas — e separou por para que
  servem. A maioria é sobre desenhar filhotes e variantes sombrias, o que pede
  uma rotina de desenho nova, não 500 decisões. Vinte e seis ferramentas já
  dizem como o golpe delas deveria aparecer, e nada lê isso ainda.

## 0.61.0

### 🧹 Internal

- Nada mudou no jogo. Quando duas linhas de trabalho são juntadas de volta, a
  anotação que registra a junção só podia ser escrita por um comando que
  ninguém tinha permissão de conferir — então o único momento que guarda mais
  trabalho de uma vez era justamente o momento em que ninguém estava olhando.
  Agora existe um comando que olha antes: ele confere que nada foi enfiado ali
  que a junção não trouxe, e só então escreve a anotação. Enquanto o
  construíamos, descobrimos que colocar uma configuração na frente de um comando
  fazia o guarda inteiro olhar para o outro lado. Isso também está corrigido.

## 0.60.0

### 🧹 Internal

- Nada mudou no jogo. A versão maior deste jogo guarda um conjunto de rotinas
  escritas que ensinam um ajudante a fazer direito cada tarefa que se repete —
  como começar uma sessão de trabalho, como anotar uma decisão, como terminar
  e arquivar tudo. Lá são 21 e aqui nenhuma, e a anotação que prometia
  trazê-las listava dez e esquecia cinco. A lista inteira está escrita agora,
  em seis lotes, na ordem que deixa cada uma útil.

## 0.59.0

### 🧹 Internal

- Nada mudou no jogo. Todas as palavras e números que descrevem este jogo —
  cada planta, cada ferramenta, cada receita — moram numa pilha grande de
  páginas escritas, e esta versão do jogo copiou só um cantinho dessa pilha:
  64 páginas de 930. Ninguém tinha contado, então ninguém sabia quais cantos
  faltavam. Agora existe uma lista, agrupada para que cada lote de páginas
  chegue junto com a parte do jogo que precisa dele. Apareceu uma surpresa: a
  bancada tem 115 páginas e a gente copiou uma.

## 0.58.0

### 🧹 Internal

- Nada mudou no jogo ainda, mas algo que as regras vinham prometendo enfim
  existe. Quando mudamos o jeito de anotar um mundo salvo, o mundo antigo que
  está neste computador deixa de fazer sentido, e a regra manda jogá-lo fora na
  mesma hora. O comando que joga fora nunca tinha sido escrito. Agora foi — e
  ele descobre o nome do próprio jogo pelo aplicativo em vez de ser avisado,
  então continua funcionando depois de uma renomeação. Suas preferências ficam
  onde estão, a não ser que você peça para irem junto.

## 0.57.0

### 🧹 Internal

- Nada mudou no jogo. Existe um vigia que lê cada arquivo logo depois de ele ser
  escrito e reclama se encontra uma das formas que prometemos nunca usar. Ele
  conhecia três. Agora conhece uma quarta: um valor cujo tipo ninguém escreveu.
  Uma quinta que tínhamos prometido foi cancelada de propósito, com o motivo
  anotado no caderno do próprio vigia, porque nenhum jeito de encontrá-la
  conseguia separar um erro de verdade de um código honesto comum.

## 0.56.0

### 🧹 Internal

- Nada mudou no jogo. Cada página do livro de receitas deste jogo foi copiada à
  mão da versão maior do jogo, uma por vez, e ninguém nunca voltou para ver se
  alguma página tinha sido reescrita de lá para cá. Agora um conferente compara
  as sessenta e uma páginas de uma vez. Tudo que os dois livros discordam
  precisa estar anotado com um motivo, para que uma diferença que ninguém
  escolheu nunca mais fique ali quietinha. A primeira conferência achou
  sessenta e sete delas, incluindo uma que já tinha sido notada e esquecida.

## 0.55.0

### 🧹 Internal

- Nada mudou no jogo. Cada parte do jogo deveria vir com um programinha que a
  cutuca e confere se ela continua se comportando — é assim que a gente
  percebe quando algo que já foi consertado quebra de novo depois. Alguém
  contou pela primeira vez: de 109 partes, 88 são cutucadas por alguma coisa e
  21 nunca são tocadas. A lista dessas 21 está anotada agora, na ordem que
  mais importa, com o que cada conferência precisa provar. Quatro delas
  seguram quase todo o resto, incluindo a que faz o mesmo mundo voltar quando
  você usa a mesma semente.

## 0.54.0

### 🧹 Internal

- Nada mudou no jogo. A versão maior deste jogo tem uma caixa de ferramentas
  cheia de programinhas que conferem os arquivos do próprio jogo atrás de
  erros — um pergunta se um desenho existe mesmo, outro pergunta se duas
  anotações sobre a mesma coisa ainda combinam. Aqui temos bem menos, e
  ninguém tinha parado para comparar as duas caixas. Agora alguém parou: cada
  ferramenta de lá está anotada aqui como "precisamos desta", "já temos" ou
  "nunca vamos precisar, e o motivo é este". Três coisas que a gente não
  conseguia conferir entraram na lista, e cada uma já achou um problema de
  verdade enquanto era anotada.

## 0.53.0

### 🧹 Internal

- Nada mudou no jogo. A pasta que guarda a versão mais antiga e maior deste
  jogo foi renomeada faz um tempo, e nossas anotações ainda apontavam para o
  nome antigo — então quem fosse procurar algo lá encontrava uma prateleira
  vazia e tinha que achar a nova na mão. O endereço agora está escrito em um
  lugar só, e toda anotação aponta para esse lugar em vez de repeti-lo.

## 0.52.1

### 🧹 Internal

- Nada mudou no jogo. O conferente de palavras da versão anterior contava os
  dois lugares que DEFINEM a busca de palavras como se fossem palavras que ele
  não conseguia conferir, e a nota da versão anterior dizia que a contagem
  era zero quando era dois. Os dois estão corrigidos: a contagem agora é zero
  de verdade.

## 0.52.0

### 🧹 Internal

- Nada mudou no jogo. Toda palavra que a tela pede pelo nome agora é conferida
  contra as três tabelas de idioma antes de qualquer trabalho ser arquivado.
  Até agora uma palavra que ninguém tinha traduzido só seria encontrada quando
  um jogador abrisse a tela que precisava dela, e o jogo pararia ali.

## 0.51.0

### 🧹 Internal

- Nada mudou no jogo. O livro de histórico agora confere a própria forma antes
  de qualquer trabalho ser arquivado: página mais nova primeiro, nenhuma
  página duas vezes, os sete títulos na ordem fixa, e os livros em inglês e em
  português contando as mesmas páginas com os mesmos títulos. Duas páginas
  ficaram fora de ordem por três versões antes de alguém perceber; daqui em
  diante o conferente percebe primeiro.

## 0.50.0

### ✨ New

- **Você começa com uma picareta de cobre.** Ela fica no primeiro bolso da
  mochila e já está na sua mão quando um mundo novo começa. Ela quebra pedras
  e minério, que são as primeiras coisas de que tudo o mais é feito. Até
  agora você começava sem nada, e nada no mundo podia ser minerado.
- A picareta de cobre em si veio do pacote de design. Você ainda não consegue
  fazer uma — isso precisa da oficina — mas tem uma.

### 🧹 Internal

- O que um jogador novo tem ao começar é uma página do pacote de design, lida
  pelas ferramentas do jogo do mesmo jeito que o jogo original lê a dele,
  então uma segunda página ao lado seria um segundo jeito de começar. A página
  do original não dá nada; a nossa dá a picareta, e a diferença está escrita
  na própria página.
- Uma página de início que cita um item que o pacote não tem para as
  ferramentas antes de conseguir parar o jogo.

## 0.49.0

### ✨ New

- **Palmeiras dão toras.** Uma palmeira crescida agora deixa toras quando cai,
  e uma nova dá sementes em vez disso. Até agora nenhuma árvore do mundo dava
  madeira nenhuma — as toras estavam escritas no projeto em "o que uma palmeira
  crescida dá", e o jogo nunca lia essa página.
- **Florestas têm árvores novas e velhas.** Toda planta selvagem agora entra no
  mundo em algum ponto da vida, de um broto recém-nascido até crescida por
  inteiro, então uma floresta não tem mais tudo da mesma idade. As crescidas
  dão mais.
- Sementes existem: sementes de palmeira, folha-verde, trevo, trigo, maçã,
  tomate e ameixa vieram do pacote de design, porque as plantas podem
  soltá-las. Você ainda não consegue plantar — isso é o capítulo da lavoura.

### 🐛 Fixed

- Toda palmeira era desenhada como uma muda, fosse qual fosse a idade. Uma
  planta agora mostra a figura da idade que ela tem de verdade.

### 🧹 Internal

- As plantas aprenderam a própria vida no papel: qual idade é crescida, se
  podem morrer de abandono, se uma mão pode colhê-las e o que cada idade dá. Só
  a parte "o que ela dá" é usada por enquanto; crescer ao longo dos dias, regar
  e colher com a mão esperam o capítulo da lavoura.
- O que uma planta solta são duas listas que SOMAM — o que ela dá em qualquer
  idade, e o que esta idade dá por cima. Uma rola depois da outra, nunca a
  mesma lista duas vezes.

## 0.48.2

### 🧹 Internal

- Nada no jogo mudou. A pasta onde o projeto guarda seus planos ganhou a sua
  página inicial: qual plano é o que está sendo trabalhado, para que serve cada
  gaveta e o que um plano novo precisa ter antes de contar como um.

## 0.48.1

### 🧹 Internal

- Nada no jogo mudou. O livro de tarefas do projeto ficou bem mais comprido e bem
  mais exato: cada próximo passo da portagem — plantar, a porta da bancada, as
  telas, salvar o seu mundo, e a lista grande do que vem depois — agora está
  escrito como pequenos trabalhos numerados, cada um com a página do jogo original
  que ele copia e o teste que prova que funciona. Uma anotação antiga estava errada
  e foi corrigida: o jogo original já tem uma lista de "com o que você começa",
  então este jogo vai ler essa lista em vez de inventar uma nova. As perguntas que
  só quem desenvolve pode responder estão reunidas em uma tabela, cada uma com uma
  resposta sugerida.

## 0.48.0

### 🧹 Internal

- **Uma bancada agora consegue trabalhar.** Dê a uma fundição uma receita e o
  minério e o carvão que ela pede, e ela pega tudo de uma vez, faz o lote uma
  barra por vez e coloca cada barra pronta no chão, na frente dela — nunca em
  cima dela. Ninguém consegue pedir isso a uma bancada ainda: o jeito de falar
  com uma (chegar perto e apertar uma tecla) não existe nesta versão. O motor
  está pronto; a porta é o próximo passo.
- Você paga o lote inteiro adiantado, e a bancada guarda o que ainda não usou.
  Pare no meio e tudo o que ela não queimou volta para o chão. Quebre uma
  bancada trabalhando e acontece o mesmo, antes de as peças dela caírem.
- Uma bancada recusa duas coisas, e em silêncio: uma receita que ela não faz e
  um lote que você não consegue pagar. Nenhuma das duas tira um item da sua
  mochila.
- Consertado um erro copiado direto do projeto: ao fazer cinco barras, o projeto
  contava "barra 1 de 1" cinco vezes, porque nunca anotava quantas foram
  pedidas. Este jogo anota, então a contagem lê 1 de 5, 2 de 5, e assim por
  diante.
- Se a bancada está ocupada deixou de ser uma anotação separada que podia
  discordar do que está em cima dela — a bancada está ocupada exatamente quando
  segura uma receita.
- O livro de histórico tinha duas páginas fora de ordem (0.45.4 e 0.45.3 estavam
  acima de 0.47.0); voltaram para o lugar.

## 0.47.0

### 🧹 Internal

- **Uma fundição sabe que é uma fundição.** O pacote de design diz isso desde o
  dia em que foi importado, e o jogo estava lendo ela como um móvel qualquer e
  jogando essa palavra fora. Ninguém tinha percebido, porque ninguém tinha
  perguntado ainda.
- Uma bancada não guarda lista nenhuma do que ela faz. Ela pergunta quais
  receitas citam o nome dela, então acrescentar uma receita depois é escrever um
  arquivo e não mexer em mais nada.
- Uma bancada melhor continua fazendo as coisas humildes: uma fundição de nível
  2 derrete barras de nível 1 tão bem quanto as de nível 2. E a lista que você
  veria é montada exatamente com a mesma regra que autoriza o trabalho — lista e
  permissão que discordam é como se acaba fabricando uma coisa que nunca te
  ofereceram.
- Duas coisas que uma bancada não pode ser: uma que responda por "feito à mão",
  que ofereceria justamente a lista que ela não pode ter, e uma que trabalhe
  infinitamente rápido. As duas agora param o jogo na hora em que o projeto é
  lido, e não muito depois.

## 0.46.0

### 🧹 Internal

- O jogo agora sabe dizer se você tem com que pagar uma receita, e quantas dá
  para fazer de uma vez. Quem decide é o ingrediente mais escasso: minério para
  cinco barras e carvão para uma dá uma barra.
- Um pedido para em cem, por mais cheia que esteja a sua mochila — esse teto vem
  direto do projeto e é um número que dá para o jogador alcançar de verdade.
- Duas respostas foram escritas de propósito porque o código óbvio erra as duas.
  Uma coisa SEM receita não pode ser feita do nada, e também não pode ser feita
  cem vezes. As duas seriam a resposta acidental, e as duas seriam bobas em vez
  de barulhentas.
- Nada faz essas perguntas ainda. A bancada que vai fazê-las é a próxima.

## 0.45.4

### 🧹 Internal

- Nada mudou no jogo. Foi anotado um problema nas ferramentas do próprio
  projeto: a trava que confere como o trabalho pronto é arquivado no livro de
  histórico não enxerga um jeito específico de arquivar, e a porta lateral que
  contorna isso passa longe da trava. Anotar um problema não é o mesmo que
  consertá-lo — é fazer com que a próxima pessoa o encontre numa página, e não
  de surpresa.

## 0.45.3

### 🧹 Internal

- Nada mudou no jogo. Isto é arrumação no livro onde o projeto anota tudo o que
  já fez. A versão antiga do jogo e a que está sendo feita agora estavam em duas
  páginas separadas, então parecia que a nova tinha perdido as últimas coisas
  que a antiga aprendeu. Nunca perdeu: tudo aquilo esteve guardado o tempo
  inteiro. Agora as duas estão na mesma página, em ordem, e o livro para de
  fingir que sumiu alguma coisa.

## 0.45.2

### 🧹 Internal

- O diário de construção sobre fabricar coisas foi corrigido antes de qualquer
  parte dele ser construída. Ele dizia que fabricar seria o que enfim deixaria
  você pousar uma fundição; acontece que as receitas do próprio jogo não te
  levam do zero até lá.

## 0.45.1

### 🧹 Internal

- Uma anotação do diário de construção sobre como fabricar e construir se ligam
  estava errada, e foi conferir o pacote de design que descobriu. Para fazer uma
  fundição você precisa de cobre e carvão; para cavar cobre e carvão você precisa
  de picareta; para fazer picareta você precisa de fundição. Nada no jogo te dá
  a primeira.
- A saída já está escrita: você vai começar o jogo segurando alguma coisa. Qual
  coisa, e o menuzinho de fazer coisas com as próprias mãos, são os próximos
  trabalhos.

## 0.45.0

### 🧹 Internal

- **Itens agora podem ter receita.** Uma coisa que é feita diz o que ela custa,
  onde ela é feita, quanto tempo leva uma e quantas saem de cada vez. Os quatro
  já estavam escritos no pacote de design e simplesmente nunca tinham sido
  lidos.
- Seis coisas novas vieram desse pacote, todas feitas numa fundição: barra de
  cobre, bloco de musgo, pano de trepadeira, moeda de cobre, couro de javali e
  pranchas de palmeira. Por enquanto são desenhadas como quadradinhos em
  branco.
- Uma planta de construção agora é uma coisa que dá para fazer, e não só uma
  coisa que dá para pousar no chão. Isso estava escrito como promessa no código
  há meses e enfim é verdade — a planta da fundição sempre carregou o preço
  dela (5 toras, 5 minérios de cobre, 5 carvões, feita nas suas próprias mãos),
  e agora tem quem leia.
- Ainda não dá para fazer nada: a bancada, o botão e o fogo vêm a seguir.

## 0.44.0

### 🧹 Internal

- O diário de construção fechou o trabalho de colocar coisas no mundo: seis
  passos, do item saber o que ele constrói até a cópia transparente que mostra
  onde a coisa cairia. Ele também anotou o passo que estava planejado e
  deliberadamente NÃO foi escrito, e por que escrevê-lo seria código que nada
  conseguiria alcançar.
- Duas dívidas agora estão no papel em vez de na cabeça de alguém: nada no jogo
  consegue pôr uma planta de construção na sua mochila ainda, então a página do
  manual sobre construir espera a bancada que vai te dar uma; e empilhar chão em
  cima de chão é recusado inteiro, em vez de respondido pela metade.
- Uma anotação dentro do código que tinha ficado velha foi corrigida — ela dava
  o motivo errado para um pedaço do projeto ainda estar faltando.

## 0.43.0

### ✨ New

- **O botão Organizar chegou.** Ele fica em cima à direita da sua mochila, e um
  aperto põe tudo no lugar: ferramentas primeiro, depois as coisas que você
  constrói, depois todo o resto, com os bolsos vazios juntinhos lá atrás.
- Pilhas da mesma coisa se juntam quando você aperta. Quatro gravetos e três
  gravetos viram sete, e uma pilha grande demais para um bolso transborda para
  o próximo em vez de ficar em pedacinhos espalhados pela mochila.
- Duas ferramentas do mesmo tipo saem com a melhor na frente, então o seu
  machado bom nunca fica escondido atrás do velho.
- Olhe a sua mão depois de apertar: a barra de itens são os mesmos bolsos,
  então o que você está segurando quase sempre muda. A página do manual também
  avisa isso.
- Comida e flecha ainda são organizadas junto com o resto — o jogo ainda não
  conhece essas coisas como um tipo próprio. Os lugares delas na fila já estão
  guardados, então nada do que você organizar hoje pula para um lugar estranho
  quando elas chegarem.

## 0.42.0

### 🧹 Internal

- A mochila agora sabe se arrumar sozinha. Tudo que tem um lugar nas gavetas vai
  para a frente nessa ordem, e os bolsos vazios ficam para trás — que é onde
  bolso vazio fica bem.
- Pilhas da mesma coisa se juntam no caminho. Quatro frutinhas num bolso e três
  em outro viram sete num bolso só; se sete for mais do que cabe num bolso, o
  que sobra começa o próximo, e a pilha mais cheia vem primeiro. Arrumar é
  metade do que um botão Organizar serve para fazer.
- Ela só avisa a tela sobre os bolsos que se mexeram mesmo. Um bolso que já
  estava com a coisa certa fica quieto, então um aperto não redesenha os trinta.
  E se a coisa que está na sua mão foi trocada debaixo de você, o jogo avisa —
  senão você estaria segurando uma coisa e dando golpe com outra.
- O botão que aperta isso é o próximo.

## 0.41.0

### 🧹 Internal

- O jogo agora sabe pôr uma coisa em ordem em relação a outra: em qual gaveta
  ela fica (uma ferramenta, uma coisa que se constrói, um material), em qual
  prateleira dentro dessa gaveta, e o quanto ela é boa. Nada aperta o botão
  ainda — isto é a tabela que o botão vai ler.
- São sete gavetas escritas, mas só três têm o que guardar hoje. Comida,
  armadura, roupa e flecha ficam com o lugar delas na fila, vazio, para que
  nada mude de posição quando elas chegarem — uma ordem que muda debaixo do
  jogador depois é pior do que uma ordem que espera.
- Todo tipo de ferramenta tem um lugar na prateleira dele, e um tipo que não
  tiver para o jogo em vez de se pôr caladinho na frente de todos.

## 0.40.0

### 🧹 Internal

- **Dá para ver onde a coisa vai ficar.** Segure uma planta de construção e uma
  cópia transparente dela acompanha o seu cursor, pousada exatamente nos
  quadradinhos que ela ocuparia — **verde** onde pode, **vermelho** onde não
  pode. Até o jogo aprender a dizer a recusa em voz alta, essa cor é a
  explicação inteira, e é ela que transforma construir de uma coisa que
  funciona numa coisa que dá para usar.
- A prévia não tem como mentir sobre o aperto, porque ela não calcula nada por
  conta própria: os dois fazem a mesma pergunta no mesmo lugar e recebem a
  mesma resposta. Um fantasma verde em cima de um quadradinho que o aperto
  recusaria é o único erro que deixaria isso pior do que nada, e agora seria
  preciso apagar código para criá-lo.
- Ela some quando deve: nada na mão que construa, ou um painel aberto na
  frente, e não há nada desenhado. O mundo atrás desse painel continua se
  mexendo, como sempre — o jogo continua nunca pausando.

## 0.39.0

### 🧹 Internal

- **Construir funciona.** Com uma planta de construção na mão, um aperto põe a
  coisa no mundo: uma fundição pousa nos dois quadradinhos que ela ocupa, uma
  ponte transforma a água para onde você apontou em pranchas onde dá para
  andar, e uma planta sai da sua mochila. É o espelho de derrubar uma árvore, e
  a segunda metade do ciclo de que esta fase inteira trata.
- Quatro coisas acontecem numa ordem, e a ordem é a promessa. O jogo descobre
  quais quadradinhos a coisa ocuparia; pergunta se ela pode ir ali; tira uma da
  sua mochila; põe no chão. Perguntar depois de tirar faria uma construção
  recusada te custar a fundição. Pôr no chão antes de tirar te daria duas.
- Uma coisa que você aponta é colocada onde ela **parece** estar: você mira no
  quadradinho em que ela se apoia, e uma coisa alta sobe a partir dali em vez
  de descer. E o que você constrói agora é do mundo de verdade — quando você se
  afasta o bastante para o jogo esquecer aquele pedaço, a sua fundição vai
  junto, em vez de ficar por lá invisível ocupando um chão que ninguém mais
  pode usar.
- Ainda não tem nada que ponha uma planta na sua mochila: as únicas que o jogo
  conhece são feitas numa bancada, e bancada é o próximo trabalho. Por isso
  esta entrada é Internal, e não New — o feito está pronto esperando um caminho
  até ele. A página do manual vem com o passo que torna isso alcançável.

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
