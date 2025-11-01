# 🤖 Guia de Prompts para Claude - Darkness Dungeon

Este documento explica como usar prompts efetivamente com o Claude para garantir que os padrões definidos no `CLAUDE.md` sejam sempre aplicados.

## 🤔 **Como o Claude Funciona com Arquivos**

O Claude **NÃO lê automaticamente** arquivos do seu workspace a menos que:

1. **Você referencie explicitamente** o arquivo no prompt
2. **O arquivo esteja no contexto** da conversa atual
3. **Você use ferramentas** para ler o arquivo

## 🛠️ **Como Garantir que o Claude Use o CLAUDE.md**

### **Opção 1: Referência Explícita (Recomendada)**
```
Por favor, leia primeiro o arquivo CLAUDE.md e aplique os padrões 
definidos nele ao [sua solicitação]
```

**Exemplo:**
```
Por favor, leia primeiro o arquivo CLAUDE.md e aplique os padrões 
definidos nele ao criar uma nova classe AudioManager para gerenciar 
sons do jogo.
```

### **Opção 2: Incluir no Início de Prompts Importantes**
```
Seguindo os padrões do CLAUDE.md, preciso que você [sua solicitação]
```

**Exemplo:**
```
Seguindo os padrões do CLAUDE.md, preciso que você refatore esta 
classe para usar nomenclatura camelCase e organizar melhor o código.
```

### **Opção 3: Pedir para Ler Automaticamente**
```
Antes de começar, por favor leia o CLAUDE.md para entender os 
padrões do projeto e então [sua solicitação]
```

**Exemplo:**
```
Antes de começar, por favor leia o CLAUDE.md para entender os 
padrões do projeto e então crie um sistema de inventory seguindo 
a arquitetura Manager.
```

## 🚀 **Templates de Prompts Prontos**

### **Para Criar Novos Arquivos/Classes:**
```
CLAUDE.md + Crie uma nova classe [NomeClasse]Manager responsável por 
[funcionalidade] seguindo os padrões arquiteturais estabelecidos.
```

### **Para Refatoração de Código:**
```
Leia o CLAUDE.md primeiro e então refatore este código aplicando 
todos os padrões de nomenclatura e organização definidos:

[CÓDIGO AQUI]
```

### **Para Melhorias de Código:**
```
Seguindo os padrões do CLAUDE.md, melhore este arquivo aplicando:
- Nomenclatura camelCase
- Constantes _kConstantName
- Organização de código
- Documentação adequada

[CÓDIGO AQUI]
```

### **Para Debugging e Análise:**
```
CLAUDE.md + Analise este código e identifique quais padrões 
estabelecidos não estão sendo seguidos:

[CÓDIGO AQUI]
```

## 📋 **Atalhos Rápidos**

### **Atalho Simples:**
```
CLAUDE.md + [sua solicitação]
```

### **Atalho para Código:**
```
CLAUDE.md + aplique os padrões a este código:
[CÓDIGO]
```

### **Atalho para Criação:**
```
CLAUDE.md + crie [descrição do que quer criar]
```

## 🔄 **Alternativas para Automação**

### **Opção A: Snippet Personalizado no Editor**
Crie um snippet no seu editor favorito:

**Comando:** `!claude`
**Expansão:**
```
Leia primeiro o CLAUDE.md e aplique os padrões definidos. 
```

### **Opção B: Template de Prompt Padrão**
Salve este template e use sempre:
```
📋 CONTEXTO: Projeto Flutter Darkness Dungeon
📖 PADRÕES: Seguir CLAUDE.md (ler primeiro se necessário)
🎯 SOLICITAÇÃO: [SUA_SOLICITAÇÃO_AQUI]
```

### **Opção C: Macro de Teclado**
Configure uma macro que digite automaticamente:
```
Por favor, leia primeiro o arquivo CLAUDE.md e aplique os padrões definidos nele ao 
```

## ✅ **Checklist para Prompts Efetivos**

Antes de enviar seu prompt, verifique:

- [ ] **Referenciou o CLAUDE.md** explicitamente
- [ ] **Especificou claramente** o que deseja
- [ ] **Incluiu contexto** suficiente (código, arquivos, etc.)
- [ ] **Mencionou padrões específicos** se relevante
- [ ] **Definiu o escopo** da solicitação

## 🎯 **Exemplos Práticos de Uso**

### **Exemplo 1: Criando Nova Funcionalidade**
```
Leia o CLAUDE.md primeiro e então crie um InventoryManager seguindo 
os padrões arquiteturais. Preciso de métodos para adicionar, remover 
e listar itens, com sistema de logging e validação de estado.
```

### **Exemplo 2: Refatorando Código Existente**
```
CLAUDE.md + refatore esta classe para seguir todos os padrões:

class ItemSystem {
  List items = [];
  
  void add(item) {
    items.add(item);
  }
  
  void remove(item) {
    items.remove(item);
  }
}
```

### **Exemplo 3: Debugging e Melhoria**
```
Seguindo os padrões do CLAUDE.md, identifique problemas neste código 
e sugira melhorias aplicando nomenclatura camelCase, constantes _k, 
e organização adequada:

[CÓDIGO AQUI]
```

### **Exemplo 4: Análise de Conformidade**
```
CLAUDE.md + analise se este GameManager está seguindo todos os 
padrões estabelecidos e liste quais ajustes são necessários:

[CÓDIGO AQUI]
```

## 🔧 **Dicas Avançadas**

### **Para Múltiplas Solicitações:**
```
CLAUDE.md + preciso que você:
1. Analise este código
2. Aplique os padrões
3. Adicione documentação
4. Sugira melhorias

[CÓDIGO AQUI]
```

### **Para Projetos Grandes:**
```
Contexto: Seguindo CLAUDE.md para projeto Darkness Dungeon
Tarefa: Criar sistema completo de [funcionalidade] incluindo:
- Classes Manager
- Constantes _k
- Logging
- Documentação
```

### **Para Revisão de Código:**
```
CLAUDE.md + faça code review deste arquivo verificando conformidade 
com os padrões e sugira melhorias específicas:

[CÓDIGO AQUI]
```

## 🎉 **Resultado Esperado**

Usando estes prompts, o Claude irá:

✅ **Aplicar automaticamente** os padrões do CLAUDE.md
✅ **Manter consistência** em todo o código
✅ **Seguir nomenclatura** camelCase
✅ **Usar constantes** _kConstantName
✅ **Organizar código** conforme estrutura definida
✅ **Incluir documentação** adequada
✅ **Implementar logging** quando apropriado

---

## 💡 **Lembre-se:**

> **A chave é sempre referenciar o CLAUDE.md no início do prompt!**

Isso garante que todos os padrões estabelecidos sejam respeitados e mantém a qualidade e consistência do código do projeto Darkness Dungeon.

---

**Última atualização:** 11 de outubro de 2025