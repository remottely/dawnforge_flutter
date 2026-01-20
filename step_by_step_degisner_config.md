# Guia de Configuração do Projeto

## 📋 Pré-requisitos
- Git instalado
- Aseprite instalado (será fornecido)

---

## 🚀 Instruções de Setup

> **⚠️ IMPORTANTE:** Sempre trabalhe na branch **`development`** para ter acesso às atualizações diárias.

---

## 📝 Passo a Passo

### **1. Abra o Terminal**
- **Mac:** `Cmd + Espaço` → digite "Terminal"
- **Windows:** `Win + R` → digite "cmd" ou "powershell"

### **2. Navegue até a pasta de Documentos**

**Mac:**
```bash
cd ~/Documents
```

**Windows:**
```bash
cd %USERPROFILE%\Documents
```

### **3. Crie a estrutura de pastas**

**Mac:**
```bash
mkdir -p flutter/remottely && cd flutter/remottely
```

**Windows:**
```bash
mkdir flutter\remottely && cd flutter\remottely
```

### **4. Clone o repositório**
```bash
git clone https://github.com/remottely/dawnforge.git
```

### **5. Entre no repositório**
```bash
cd dawnforge
```

### **6. Mude para a branch development**
```bash
git checkout development
```

### **7. Verifique se está na branch correta**
```bash
git branch
```

> **Nota:** A branch atual aparecerá destacada em verde no terminal. Certifique-se de que é **"development"** e não "main". Isso é importante pois garante que você está trabalhando com os arquivos mais recentes, sincronizados em tempo real com minhas atualizações. **Sempre abra e salve arquivos estando nessa branch.**

---

## 🎨 Configuração do Aseprite

### **8. Instale o Aseprite**
- Aguarde o envio da licença que vou te passar
- Instale normalmente

### **9. Como editar assets**

1. Localize qualquer arquivo `.png` no projeto
2. Clique com o **botão direito** → **Abrir com** → **Aseprite**
3. Faça suas edições e salve em formato `.aseprite`

---

## ⚠️ Boas Práticas de Edição

### **Salvando suas modificações:**

### ✅ **RECOMENDADO:** Salve no formato `.aseprite`
- Não causa conflitos com os arquivos atuais
- Permite rastreamento de mudanças
- Facilita alinhamento posterior

### ❌ **EVITE POR ENQUANTO:** Exportar/substituir arquivos `.png`
- Pode causar conflitos de versão
- Sobrescreve e apaga os assets atuais

---

## 🔄 Mantendo-se Atualizado

Para baixar as últimas atualizações, execute:

```bash
git pull origin development
```

> **Dica:** Execute esse comando **pelo menos uma vez** toda vez que for editar algo, assim você garante que está trabalhando com a versão mais recente.

---

## 💡 Dicas Extras

- **Explore à vontade:** Teste ideias e modificações salvando em `.aseprite`
- **Flutter:** No futuro, posso te ajudar a configurar o ambiente para testes em tempo real (é bem simples!). Você poderá rodar o jogo de verdade na sua máquina local.
- **Dúvidas:** Sempre pergunte! Não existe pergunta idiota 😄

---

## 📞 Precisa de Ajuda?

Qualquer dúvida, é só chamar no WhatsApp! Estou aqui para ajudar no que precisar.

---

**Bom trabalho e divirta-se criando! 🎮✨**