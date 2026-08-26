# Passo a Passo — Aula 02: Configuração do Ambiente

**Disciplina:** Desenvolvimento de Aplicativos Móveis  
**Tema:** Configuração do Ambiente  
---

> [!NOTE]
> **Objetivo Operacional:** Preparar o ambiente completo para criar e executar os dois projetos da disciplina:
> - Frontend mobile em Ionic/Angular.
> - Backend API em Node/Express.

> [!TIP]
> 💡 **Analogia Didática da Aula:** Arquitetura de 2 Projetos: O Frontend Mobile (Ionic) é o painel interativo do carro (botões, telas); a API Backend (Node/Express) é o motor sob o capô. Sempre manteremos os 2 terminais abertos!  
> 📌 **Dica Prática:** Terminal A roda o Mobile (`npm run start`); Terminal B roda a API (`npm start`).

## 📁 Padrão de Caminhos e Organização
- Pasta base da turma: `projetos`
- Projeto Mobile: `projetos/ionic_projeto`
- Projeto API: `projetos/mobile_api`

> [!IMPORTANT]
> - Sempre abrir 2 terminais quando começar a trabalhar:
> - Utilizar o terminal **GIT BASH**
> - Terminal A: Mobile
> - Terminal B: API

## ⏱️ Roteiro Completo de Atividades (4 Horas)

### Bloco 1 - Ferramentas e Validação do Ambiente

1. Abrir o terminal **Git Bash**.

2. Validar ferramentas essenciais instaladas:
```bash
node -v
```

```bash
npm -v
```

3. Instalar CLIs globais do Ionic e Angular:
```bash
npm install -g @ionic/cli @angular/cli
```

4. Validar instalações globais:
```bash
ionic -v
```

```bash
ng version
```

---

### Bloco 2 - Criar Mobile do Zero

1. Ir para a pasta base:
```bash
cd projetos
```

2. Criar o projeto Ionic com Angular (modo não interativo):
```bash
ionic start ionic_projeto tabs --type=angular --no-interactive
```
> 📌 **Entendendo cada parâmetro do comando:**
> - **`ionic start`**: Comando principal da CLI do Ionic para inicializar um novo projeto do zero.
> - **`ionic_projeto`**: Nome da pasta e do projeto que será criado na máquina.
> - **`tabs`**: Modelo de layout inicial (cria a aplicação com navegação por abas na parte inferior).
> - **`--type=angular`**: Define a tecnologia/framework base do projeto (`Angular` + `TypeScript`).
> - **`--no-interactive`**: Executa a criação no modo automático/silencioso, aceitando todas as configurações padrão sem interromper a execução com perguntas interativas no terminal.

3. Entrar no projeto:
```bash
cd ionic_projeto
```

4. Instalar dependências (se necessário):
```bash
npm install
```

5. Executar o projeto no navegador local:
```bash
npm run start
```

6. Abrir no navegador a URL exibida no terminal (geralmente `http://localhost:8100`).

7. Confirmar que a tela inicial abriu sem erro.

8. **Testar a aplicação no celular (Rede Local / Wi-Fi):**
   - Para rodar o projeto de forma que outros dispositivos na mesma rede consigam acessar, execute:
   ```bash
   npx ionic serve --external
   ```
   > 💡 **Como funciona:**
   > 1. O parâmetro `--external` expõe a aplicação na rede local e mostra o endereço IP do seu computador no terminal (ex: `http://192.168.1.15:8100`).
   > 2. Certifique-se de que o computador e o celular estão conectados na **mesma rede Wi-Fi**.
   > 3. No navegador do celular (Chrome, Safari, etc.), digite a URL contendo o IP exibido no terminal para visualizar e testar o app.

---

### Bloco 3 - Criar API Backend do Zero com Código Pronto

1. Abrir um **novo terminal Git Bash** (não fechar o terminal do mobile).

2. Voltar para a pasta base:
```bash
cd projetos
```

3. Criar e entrar na pasta da API:
```bash
mkdir mobile_api
cd mobile_api
```

4. **Inicializar o projeto Node.js:**
```bash
npm init -y
```
> 💡 **Entendendo o comando:**  
> O `npm init` cria o arquivo `package.json`, que funciona como o registro do projeto Node.js (guarda nome, versão, dependências e scripts). A flag `-y` (*yes*) aceita automaticamente todas as configurações padrão.

5. **Instalar as dependências da API:**
```bash
npm install express cors dotenv mysql2 bcryptjs jsonwebtoken
```
> 📌 **Do que se trata cada dependência?**
> - **`express`**: Framework web para Node.js que simplifica a criação de rotas e APIs HTTP.
> - **`cors`**: Middleware que habilita *Cross-Origin Resource Sharing*, permitindo que a aplicação Mobile (que roda em porta diferente) faça requisições HTTP para a API sem ser bloqueada pelo navegador.
> - **`dotenv`**: Gerencia variáveis de ambiente carregadas a partir de um arquivo `.env` (como senhas de banco e portas), mantendo dados sensíveis fora do código.
> - **`mysql2`**: Driver para conectar e executar consultas no banco de dados MySQL/MariaDB.
> - **`bcryptjs`**: Biblioteca para criptografia (hashing) segura de senhas antes de salvá-las no banco.
> - **`jsonwebtoken`**: Implementação de tokens JWT (*JSON Web Token*) para autenticação e controle de acesso a rotas protegidas.

6. Criar a pasta do código-fonte:
```bash
mkdir src
```

7. **Criar o arquivo `src/app.js` com o seguinte conteúdo:**
```javascript
// Importação dos módulos principais
const express = require('express');
const cors = require('cors');

// Inicializa a aplicação Express
const app = express();

// Middlewares globais: liberação de acesso (CORS) e leitura de JSON no corpo das requisições
app.use(cors());
app.use(express.json());

// Rota de verificação de saúde da API (Health Check)
app.get('/health', (_req, res) => {
  res.status(200).json({ status: 'ok' });
});

// Exporta a instância do app
module.exports = app;
```

8. **Criar o arquivo `src/server.js` com o seguinte conteúdo:**
```javascript
// Importa a aplicação configurada em app.js
const app = require('./app');

// Define a porta do servidor
const PORT = 3000;

// Inicializa o servidor HTTP
app.listen(PORT, () => {
  console.log(`API em execucao: http://localhost:${PORT}`);
});
```

9. **No arquivo `package.json`, ajustar os scripts para ficarem assim:**
```json
"scripts": {
  "start": "node src/server.js"
}
```
> 💡 **Para que serve isso?**  
> Cria o atalho padrão `npm start`. Em vez de digitar `node src/server.js` no terminal toda vez, você roda apenas `npm start`, padronizando a execução em qualquer máquina ou ambiente.

10. Subir a API:
```bash
npm start
```

---

### Bloco 4 - Validação Completa

1. No terminal da API, confirmar a mensagem:
   - `API em execucao: http://localhost:3000`

2. **Testar o endpoint de saúde:**
   - **No Git Bash (Recomendado):**
     ```bash
     curl http://localhost:3000/health
     ```
     *Resultado esperado:* `{"status":"ok"}`

   - **No PowerShell:**
     ```powershell
     Invoke-RestMethod http://localhost:3000/health
     ```
     *Resultado esperado:*
     ```text
     status
     ------
     ok
     ```

3. Confirmar que o mobile continua aberto no outro terminal.

4. Encerrar (`Ctrl + C`) e subir novamente os 2 projetos para validar a repetibilidade:
   - **Terminal A (Mobile):**
     ```bash
     cd projetos/ionic_projeto
     npm run start
     ```
   - **Terminal B (API):**
     ```bash
     cd projetos/mobile_api
     npm start
     ```

---

## ❓ Perguntas de Rápida Fixação (Fechamento da Aula)

> 💡 **Para o Professor:** Utilize estas perguntas nos últimos 5 a 10 minutos da aula para validar o entendimento dos alunos sobre o ambiente e os comandos.

1. **Por que mantemos dois terminais abertos simultaneamente durante o desenvolvimento?**
   * **Resposta:** Um terminal executa o Frontend Mobile (Ionic/Angular na porta `8100`) e o outro executa o Backend API (Node/Express na porta `3000`).

2. **Qual comando usamos para testar a aplicação no celular físico conectado na mesma rede Wi-Fi?**
   * **Resposta:** `npx ionic serve --external`.

3. **Como fazemos um teste rápido via linha de comando no Git Bash para saber se a nossa API está no ar?**
   * **Resposta:** `curl http://localhost:3000/health`.

4. **Para que serve o script `"start": "node src/server.js"` no arquivo `package.json` da API?**
   * **Resposta:** Para criar o atalho padrão `npm start`, simplificando e padronizando a execução do servidor em qualquer ambiente.

---

## 🔄 Fluxo Resumido de Execução Diária

1. Terminal A (Mobile):
```bash
cd projetos/ionic_projeto
npm run start
```

2. Terminal B (API):
```bash
cd projetos/mobile_api
npm start
```

3. Teste rápido da API:
```bash
curl http://localhost:3000/health
```

---

## ✅ Saída Esperada ao Final da Aula

- Mobile executando no navegador e acessível pelo celular na mesma rede local.
- API executando na porta 3000.
- Endpoint `/health` respondendo status ok.
- Aluno apto a iniciar a implementação da próxima semana.

---

**De onde viemos:**  
Retomamos os aprendizados de 'Introdução ao Desenvolvimento Mobile', consolidando os fundamentos necessários para avançar com segurança.

**Para onde vamos:**  
A partir desta base, avançaremos para 'Interfaces Gráficas - Parte 1', ampliando complexidade, autonomia e capacidade de aplicação prática.

