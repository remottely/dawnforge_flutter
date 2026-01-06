# IMPORTANT BEFORE LAUNCH:

- [DONE] EquippedHandType deve ser HandItemType e Item deve ser HandItem pois todos os items do jogo hj sao itens capazes de serem segurados pelo player e eu quero q tanto as keys de maps quanto os ids dos items sejam tipados pelo tipo e nao mais strings, entao as keys e ids serão do tipo HandItemType.

- [PRIORITY] cropId deve ser do tipo HandItemId, refatore no codigo

- [DONE] prompt: hoje eu possuo a logica de harvest onde eu consigo colher crops e trees, porem o meu tree ele nao deve simplesmente sumir do tile e sim continuar la so q resetando o tempo de colheita apenas, assim como inclusive quero acrescentar essa funcionalidade para crops. entao oq vc deve fazer primeiro é adicionar essa logica para crops com colheita recorrentes e em seguida adicionar que isTree segue a mesma logica, depois de crescido eles apenas oferecem colheitas de tempos em tempos. e sempre depois de colher eles voltam dois estagios, e a cada dia novo q passa de um estagio para o outro(sprite) demora agora 2 dias e nao mais 1 dia como é feito durante o crescimento do crop/tree.

- [PRIORITY] prompt: melhore essa logica de requireWaterForRegrowth, pois todos os crops precisarão de???

- [PRIORITY] prompt: hj em DDMinePlayerView eu utilizo FarmToolActionDef, só q eu preciso q vc crie MineToolActionDef q eu não possuo hj com o _handleMine assim como tenho para outros _handle em FarmToolActionDef hj. crie _handleMine para mim e toda lógica necessaria para que a minha ação de mineração funcione. No caso eu quero q primeiro vc me crie um documento contendo os 10 passos (como prompts) necessarios para que essa feature fique completa. a ideia é eu ter uma picareta que quebre pedras, e ao quebra-las eu automaticamente adquiro(sem dropar itens para depois colhe-los do chão). lembrando que isso tudo ficara em um novo modulo no meu jogo, assim como existe o modulo "farm", preciso do modulo "mine" com a funcionalidade basica de quebrar e colher pedras, assim como faco com crops hj em farm só que com a logica bem mais simples.

- [DONE] prompt: hj, quando eu entro em contato com MarketDecoration ele para o player e abre o MarketPanel, porem eu consigo continuar andando com o player por tras, oq é o esperado mesmo. mas quando eu ando com o player mesmo com o MarketPanel aberto, ele fica piscando o MarketPanel, ou seja, reabindo, preciso que a logica do contato funcione assim: quando ele entra na zona de contato com MarketDecoration a primeira vez, nada acontece, ele na vdd espera o player dar o input de "isInteractionAction" para entao abrir o MarketPanel. quando o MarketPanel abre, se ele andar o MarketPanel fecha. E se dentro da zona ele interagir novamente com "isInteractionAction", então o MarketPanel abre. mantena o botao de fechar o MarketPanel.

- [PRIORITY] quero mudar um comportamento, hj quando estou com o market aberto, eu so consigo comprar e vender itens com o touch ou mouse, queria na vdd utilizar os inputs de keyboardDirectionalKeys() para ao inves de controlar o player andando (ou seja, deve bloquear q ele ande no jogo enquanto o market estiver aberto), esses botoes de direcoes deve na verdade navegar entre os itens do grid de compra do market e os kSlotNavNextKey e kSlotNavPrevKey navegar entre os itens do inventario para venda. e kInteractionKey compra o item elecionado 1x e kPrimaryActionKey vende o item do inventario 1x.

- [PRIORITY] 

- [PRIORITY] 

- [PRIORITY] 

- [PRIORITY] 

- [PRIORITY] 

- [PRIORITY] 

- [PRIORITY] 

- [PRIORITY] refatorar as animacoes do player, usar cabelo dark(marrom) e trocar animacao de cagar q cria um buraco

- [PRIORITY] prompt: leia o meu projeto, só oq for necessario para a conclusao da tarefa, crie um documento com todos os prompts necessarios para a refatoraca a seguir:
preciso melhorar a organizacao dos itens do meu jogo como um todo, hj é tudo muito confuso e repetitivo, recrie toda a logica de configuracao(definitions), recuperacao e manipulacao desses dados para q fique mais centralizado, modularizado e sem repetição de logica. estou clonando stardew valley e preciso deixar redondo essa questao antes de lancar o jogo.

- [PRIORITY] mudar "farm_tile" para "grid_tile"

- [NOT_PRIORITY] criar um programa dart com todos os meus itens do jogo de maneira tipada e q a partir desta configuracao tipada ele cria os meus json database assets posteriormente evitando erros durante a execucao do jogo. ou inicialmente apenas criando arquivos definitions ja definindo diretamente no jogo??

- [NOT_PRIORITY] mudar todos os inputs do jogo para se alinhar com SV

- [NOT_PRIORITY] adicionar "arar"?

- [NOT_PRIORITY] adicionar mouse como ponteiro 16x16 do meu jogo seguindo a logica de SV.

- [NOT_PRIORITY] add as outras camadas de DDDefensePlayer, elimine ShieldDefenseComponent e ShieldDefenseInputHandler

- [NOT_PRIORITY] add as outras camadas de DDConsumablePlayer

- [PRIORITY] configurar o ySortingFromStage de todos os crops antes de lançar o jogo

- [PRIORITY] remover iconPath de weapons(crops)

- [PRIORITY] A primeira vez que 

- [PRIORITY] criar sprite para harvestBasket

- [PRIORITY] criar sprite e animacao para ironSword

- [PRIORITY] quando o dia virar, o player deve spawnar na posicao x,y da cama(MVP local fixo)

- [NOT_PRIORITY] quero adicionar uma nova funcionalidade ao jogo, onde utilizando LogicalKeyboardKey.space(e um equivalente no joystick) eu consiga pausar o jogo por inteiro, incluindo o relogio do jogo

- [PRIORITY] Adicionar musicas finais + adicionar segunda camada q toca ao mesmo tempo de natureza, passaros etc(um som de natureza para cada mapa)!

- [PRIORITY]

- [PRIORITY]

- [PRIORITY]

- [PRIORITY] melhorar a maneira como é renderizado os crops, pois a base do crop(render) deveria bater com a base do crop(sprite) para nao dar bug visual no fake 3D(ordem Y)

- [PRIORITY] Impossibilitar do player sair destruindo tudo sem querer com picareta no jogo??

- [PRIORITY] No SV não existe um equipamento em si para colheita, vc pode colher a qualquer momento, porém se vc tiver com uma picareta na hr da colheita, ele destroi a plata ao inves de colher. fazer funcionar da mesma maneira ou mudar o comportamento? manter o implementado atualmente com harvestBasket??

- [PRIORITY] "X" da conflito da defesa com interacao, priorizar defesa sempre? refatorar.

- [PRIORITY] a defesa deve durar sempre um tempo em especifico e nao o tempo q ficar pressionado "X" infinitamente

- [PRIORITY] picareta quebra literalmente tudo, desfaz farm tiles (acao reversad)

- [PRIORITY] garantir que conversation seja o display de qualquer interacao q demande mensagem na tela. inclusive sobre alerta de "sem estamina"?

- [PRIORITY] gameplay diario(missoes) deve ser um overlay q sobrepoem-se por toda a tela do jogo.

- [PRIORITY] gameplay menu(config, etc) deve ser um overlay q sobrepoem-se por toda a tela do jogo.

- [PRIORITY] comecar novo jogo com 500 de ouro

- [PRIORITY] A chave deve deixar de ser um item vinculado ao player e passar a ser um item do inventario, e para consumi-la na door, é preciso estar com ela equipada no momento, ou seja, slot da chave selecionada, assim como ocorre o comportamento de todos os itens consumiveis do SV.

- [PRIORITY] hoje eu chamo de stamina oq deveria ser energy do sv pois estou fazendo um clone. renomear

- [PRIORITY] No SV eu posso selecionar slots vazios, fazer o mesmo aqui?

- [PRIORITY] No SV mobile, quando o usuario apenas sai do jogo, ele salva mesmo nao mudando de um dia para o outro, ou seja, salva o ultimo momento do player no jogo, faco o mesmo para o meu jogo?

- [PRIORITY] Finalizar comportamento de mudanca entre landscape/portraitup na versão mobile/web. setar sempre antes de carregar o jogo?(limitação do bonfire/flame). E ai

1. manter o mundo no size inicial porem permitir mudar a orientecao mesmo assim e ai o usuario bloqueia manualmente a orientacao no dispositivo dele, ou
2. bloquear a orientacao apos iniciar o jogo??

- [PRIORITY] toggleFullscreen deve estar visivel para todos os modos web, keyboard/joystick

- [PRIORITY] mudar o design dos action buttons para nao ser fireball e sword

- [PRIORITY] criar um botao q ocupa a tela inteira para modo web: cmd + shift + f

- [PRIORITY] refactor executionStartFrame to be injected

- [PRIORITY] change battle music, and all musics on the game to keyn music??

- [PRIORITY] transformar ataque bola de fogo evrmelho em azul

- [PRIORITY] mudar a logica de regeneracao da vida em contato com a tocha ligada? mudar para em contato com a cama? criar cama!

- [PRIORITY] renomear "isPrimaryAction", "isRunAction", etc para "isActionPrimary", "isActionRun", etc.

- [PRIORITY] a reatividade do inventario esta ruim, quando clico "G" deveria refletir a limpeza do inventario/jogo em tempo real. quando clico em "G" alem de nao apagar tudo do inventario em tempo real, quando eu reincio o jogo ele reiniciar com o inventario vazio sendo q deveria trazer os itens iniciais de base de teste, mas eles so aparecem se eu fechar e abrir o inventario ou interagir com trocas do equipamento. quero uma solucao robusta em tempo real e q priorize tb o desempenho.

- [PRIORITY] hoje eu possuo o onJoystickAction, hoje existente em Keyboard do bonfire. nele consigo hoje utilizar os inputs do player na classe do player. mas agora eu preciso q vc faca com q esse onJoystickAction(q gerencia tanto o keyboard quanto o joystick do meu jogo), para q funcione tb em FarmInputHandler. hoje o FarmInputHandler só funciona no keyboard, mas quero tb q ele funciona na versão mobile, com input de joystick.

<!-- - [PRIORITY] quando eu carrego o meu jogo, ele deveria ja vir com o ultimo item equipado e salvo do player, tendo tb o feedback visual do inventario e do equipamento refletidos corretamente -->

- [PRIORITY] setar a cor de fundo dos mapas para a cor dos tiles do chao para quando der problemas de (criacao de linhas) nos mapas, ele nao ficar tão visivel.

- [PRIORITY] refatorar assets para nao haver tiles repitidos nunca. decidir isso quando tiver certeza dos assets do jogo final!

- [PRIORITY] criar uma maneira do jogo nunca quebrar todo por conta de um exception. trata-los!! principalmente pq um asset nao existe.

- [PRIORITY] change snake_case names "strawberry_seed_bag" to camelCase "strawberrySeedBag"

- [PRIORITY] Configurar os items de seed em items_icons_database

- [PRIORITY] Refact crops_database to be like items_icons_database structure

- [DONE] **Nota**: Ajuste os índices de row/column conforme a posição real dos sprites no atlas.

- [PRIORITY?] fazer o load da hand do player carregar oq ja possuimos salvo do player funcionando?

- [PRIORITY] fazer o load e save como estado do jogo como um todo

- [DONE] render in all conversations the actual player sprite animation dynamically

- [PRIORITY] enhance: create a logic that we dont need to declare each crop asset path to pubspec.yaml like: "assets/images/gameplay/farm/crops/strawberry/"

- [DONE] farm crops need to have 3D behavior, fix it

- [DONE] seeds planted cant have 3D behavior, fix it

- [PRIORITY] fix die multiple times in the same second bug the game, handle cannot die more than once.

- [PRIORITY] refactor all tiled decoration nomenclatures

- [PRIORITY] verify if need the \_activeAnimationLockCount logic

- [PRIORITY] remove EquipmentToCustomPlayerAdapter from codebase??

- [PRIORITY] Change background musics

---

# Enhance:

- [DONE] add torch ON/OFF interaction

- [NOT_PRIORITY] save torch state

- [NOT_PRIORITY] Create a way to config game view size dynamically, small, medium, large by changed user.

- [NOT_PRIORITY] continuous attack with continuous press attack (space bar)

- [NOT_PROPRITY?] Future action: Refact all assets???

- [NOT_PRIORITY] Add dynamic crop icons render when harvest action

---

# Fix:

- [DONE] move map player spawn location to player center component and not top left of the component

- [DONE] Player walk/run then attack, after attack steel previous attack walk/run animation

- [PRIORITY] attacks particles animations

- [PRIORITY] add "X" to display keyboard configuration. And change all keyboard display layout.

- [PRIORITY] emote bug, displaying outside gameplayscreen area

- [PRIORITY] win and die do not show in same time. how to resolve this issue? do to every enemy "enemy.idle"?

- [PRIORITY] organize all project exports in one file

- forest_1.json:

  - [PRIORITY] colission behavior

- farm tile:

  - [DONE] priority
  - [DONE] render not showing

- enemies:

  - [PRIORITY] run in direction of the player when receive player ranged attack

- characters:

  - [DONE] boss die explosion not in the same size as boss sprite
  - [DONE] mini boss collision size
  - [DONE] create a helper hitbox size calculation based on spriteSize/textureSize/componentSize

- fireball attack:

  - [DONE] collision size and position

- UI dialogues:

  - [DONE] force player to stop in every conversation
  - [PRIORITY] force "game pause" in every UI display
  - [PRIORITY] execute player.idle even in victory and game over dialogs

- Audio:

  - [DONE] put music_gameplay_background.mp3 back

---

# Documentation:

- [PRIORITY] Create documentation that explains that config layer represents "constants, factories, builders, etc." in the same class.

---

- AI Prompts:

  - Preciso que você finalize o planejamento da logica inicial de meu farmable. Levando em conta que quero fazer o clone do SV... TODO(Kevin): finalizar esse prompt

  - Preciso que você percorra todo o meu código fazendo melhorias onde necessário para deixar tudo bem implementado e padronizado. use como referência o módulo de "lib/gameplay/characters/player/knight", utilizando o MVC e camada de config.

---
