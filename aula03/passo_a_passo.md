# Passo a Passo — Aula 03: Interfaces Gráficas - Parte 1

**Disciplina:** Desenvolvimento de Aplicativos Móveis  
**Tema:** Interfaces Gráficas - Parte 1  
---

> [!NOTE]
> **Objetivo Operacional:** Construir a primeira interface gráfica funcional do aplicativo mobile utilizando componentes visuais do Ionic 7+ e Angular Standalone (header, cards, inputs com rótulos integrados, botões e listas), organizando a hierarquia visual, ajustando temas com SCSS e garantindo boas práticas de UX/UI em contexto mobile.

> [!TIP]
> 💡 **Analogia Didática da Aula:** Componentes Ionic são como blocos de LEGO prontos: em vez de fabricar um botão ou um cabeçalho do zero no CSS, você encaixa `<ion-header>`, `<ion-card>` e `<ion-button>`.  
> 📌 **Dica Prática:** No Ionic 7+, os rótulos de campos de texto são definidos diretamente no `<ion-input>` usando `label="..."` e `labelPlacement="stacked"`, eliminando a necessidade da tag `<ion-label>` separada.

## 📁 Padrão de Caminhos e Organização
- Pasta base da turma: `projetos`
- Projeto Mobile: `projetos/ionic_projeto`
- Projeto API: `projetos/mobile_api`

> [!IMPORTANT]
> - Manter os terminais abertos durante a prática:
>   - **Terminal A:** Mobile (`cd projetos/ionic_projeto` -> `npm run start`)
>   - **Terminal B:** API (`cd projetos/mobile_api` -> `npm start`)
>   - **Terminal C:** Comandos CLI da turma (para gerar novos componentes e instalar pacotes)

---

## ⏱️ Roteiro Completo de Atividades (4 Horas)

### Bloco 1 - Inicialização e Criação da Página de Login

1. Garantir que o **Terminal A (Mobile)** está rodando a aplicação Ionic:
```bash
cd projetos/ionic_projeto
npm run start
```

2. Garantir que o **Terminal B (API)** está rodando a API Node:
```bash
cd projetos/mobile_api
npm start
```

3. Abrir um **terceiro terminal (Terminal C - Git Bash)** na pasta do projeto mobile para executar comandos de geração de código:
```bash
cd projetos/ionic_projeto
```

4. **Gerar a página Standalone de `login` usando o CLI do Angular:**
```bash
ng g c pages/login --type=page --standalone
```
> 💡 **Por que usar `ng g c --standalone`?**  
> O comando `ng g c` (do Angular CLI) cria a página no padrão **Angular Standalone puro** com exatamente os **4 arquivos essenciais** dentro de `src/app/pages/login/`:
> - `login.page.ts`: Componente Standalone em TypeScript (`@Component({ standalone: true })`).
> - `login.page.html`: Estrutura da interface visual HTML.
> - `login.page.scss`: Estilos estilizados da página.
> - `login.page.spec.ts`: Arquivo de testes unitários.  
> *Isso evita a geração de módulos legados (`login.module.ts` e `login-routing.module.ts`) da arquitetura antiga.*

5. **Configurar o arquivo de rotas (`src/app/app.routes.ts`) para definir a página `login` como a rota principal da aplicação:**

```typescript
import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    redirectTo: 'login',
    pathMatch: 'full', // Redireciona a raiz do app diretamente para a tela de login
  },
  {
    path: 'login',
    loadComponent: () => import('./pages/login/login.page').then( m => m.LoginPage) // Carregamento sob demanda (Lazy Loading)
  },
];
```
> 📌 **Por que usar Lazy Loading?**  
> A função `loadComponent` com `import()` carrega os arquivos da página `login` apenas quando o usuário acessa a rota, tornando a inicialização do aplicativo muito mais rápida.

6. **Validar no navegador:**
   - Acesse `http://localhost:8100/` no navegador.
   - Confirme se a aplicação redireciona automaticamente para `http://localhost:8100/login` exibindo a página inicial recém-gerada.

---

### Bloco 2 - Estruturação Visual com Componentes Ionic 7+

1. **Abrir o arquivo TypeScript da página (`src/app/pages/login/login.page.ts`) e importar apenas os componentes utilizados no HTML:**

```typescript
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import {
  IonContent,
  IonHeader,
  IonTitle,
  IonToolbar,
  IonCard,
  IonCardHeader,
  IonCardTitle,
  IonCardSubtitle,
  IonCardContent,
  IonItem,
  IonInput,
  IonButton
} from '@ionic/angular/standalone';

@Component({
  selector: 'app-login',
  templateUrl: './login.page.html',
  styleUrls: ['./login.page.scss'],
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    IonContent,
    IonHeader,
    IonTitle,
    IonToolbar,
    IonCard,
    IonCardHeader,
    IonCardTitle,
    IonCardSubtitle,
    IonCardContent,
    IonItem,
    IonInput,
    IonButton
  ]
})
export class LoginPage implements OnInit {
  constructor() { }

  ngOnInit() { }
}
```
> 📌 **Clean Code & Tree Shaking:** Importamos no array `imports` unicamente os elementos Ionic que a página realmente utiliza. Não inclua componentes desnecessários para evitar código morto e manter o bundle enxuto.

2. **Abrir o arquivo HTML (`src/app/pages/login/login.page.html`) e adicionar a estrutura visual da tela de login no padrão Ionic 7+:**

```html
<!-- Cabeçalho Superior Fixo da Tela -->
<ion-header [translucent]="true">
  <ion-toolbar color="primary">
    <ion-title>Portal Mobile</ion-title>
  </ion-toolbar>
</ion-header>

<!-- Conteúdo Principal Rolável -->
<!-- 💡 class="ion-padding": utilitário nativo Ionic que aplica espaçamento interno padrão mobile -->
<!-- 💡 class="custom-background": classe customizada no SCSS para definir a cor de fundo -->
<ion-content class="ion-padding custom-background">

  <!-- 📌 POR QUE UMA DIV ENVOLVENDO O CARD? (login-container) -->
  <!-- Ela funciona como um wrapper de layout responsivo: limita a largura em 450px e centraliza a tela (margin: 0 auto) em tablets/desktops -->
  <div class="login-container">
    
    <!-- 📌 POR QUE A HIERARQUIA DO CARD? -->
    <!-- ion-card agrupa visualmente o formulário. Ele engloba o ion-card-header (título/subtítulo) e o ion-card-content (inputs e botões) -->
    <ion-card class="login-card">
      
      <ion-card-header>
        <ion-card-title>Acesso ao Sistema</ion-card-title>
        <ion-card-subtitle>Informe suas credenciais para continuar</ion-card-subtitle>
      </ion-card-header>

      <ion-card-content>
        <!-- 📌 POR QUE O ION-ITEM ENVOLVE O ION-INPUT? -->
        <!-- ion-item alinha o campo com bordas e espaçamentos padrão de formulários Ionic -->
        <!-- 💡 SINTAXE IONIC 7+: label="..." e labelPlacement="stacked" ficam dentro do ion-input, eliminando a tag <ion-label> antiga -->
        <ion-item lines="full" class="custom-item">
          <ion-input label="E-mail" labelPlacement="stacked" type="email" placeholder="seu.email@exemplo.com"></ion-input>
        </ion-item>

        <!-- Campo Senha com rótulo embutido -->
        <ion-item lines="full" class="custom-item">
          <ion-input label="Senha" labelPlacement="stacked" type="password" placeholder="Digite sua senha"></ion-input>
        </ion-item>

        <!-- Botões de Ação com classe utilitária ion-margin-top para criar espaçamento superior -->
        <ion-button expand="block" color="primary" class="ion-margin-top">
          Entrar
        </ion-button>

        <ion-button expand="block" fill="outline" color="secondary" class="ion-margin-top">
          Criar Conta
        </ion-button>
      </ion-card-content>
    </ion-card>

  </div>
</ion-content>
```

3. **Validar no navegador:**
   - Salve os arquivos.
   - Verifique que a página recarrega exibindo a barra superior azul, o cartão centralizado com os campos de e-mail e senha e os dois botões estilizados.

---

### Bloco 3 - Estilização SCSS, Variáveis CSS e Ajustes de UX/UI

1. **Abrir o arquivo de estilos (`src/app/pages/login/login.page.scss`) e adicionar as regras de layout e personalização:**

```scss
// Fundo personalizado do container da página
.custom-background {
  --background: #f4f5f8;
}

// Container centralizado com limite de largura para telas maiores
.login-container {
  max-width: 450px;
  margin: 0 auto;
  padding-top: 20px;
}

// Estilização do Cartão Ionic
.login-card {
  border-radius: 16px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  background: #ffffff;
}

ion-card-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: #1e293b;
}

ion-card-subtitle {
  color: #64748b;
  font-size: 0.9rem;
}

// Ajustes nos itens de formulário
.custom-item {
  --background: transparent;
  --padding-start: 0;
  margin-bottom: 12px;
}

// Personalização do botão
ion-button {
  --border-radius: 8px;
  font-weight: 600;
  height: 48px;
}
```

2. **Validar no navegador:**
   - Observe o arredondamento das bordas do card (`16px`), o espaçamento interno e a sombra suave (`box-shadow`).
   - Teste o foco nos campos clicando nos inputs.

---

### Bloco 4 - Adição de Listas, Badges e Importação de Novos Componentes

1. **Atualizar o arquivo TypeScript (`src/app/pages/login/login.page.ts`) adicionando `IonList`, `IonBadge` e `IonLabel` (necessários para a lista informativa):**

```typescript
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import {
  IonContent,
  IonHeader,
  IonTitle,
  IonToolbar,
  IonCard,
  IonCardHeader,
  IonCardTitle,
  IonCardSubtitle,
  IonCardContent,
  IonItem,
  IonInput,
  IonButton,
  IonList,
  IonBadge,
  IonLabel
} from '@ionic/angular/standalone';

@Component({
  selector: 'app-login',
  templateUrl: './login.page.html',
  styleUrls: ['./login.page.scss'],
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    IonContent,
    IonHeader,
    IonTitle,
    IonToolbar,
    IonCard,
    IonCardHeader,
    IonCardTitle,
    IonCardSubtitle,
    IonCardContent,
    IonItem,
    IonInput,
    IonButton,
    IonList,
    IonBadge,
    IonLabel
  ]
})
export class LoginPage implements OnInit {
  constructor() { }

  ngOnInit() { }
}
```

2. **Atualizar o arquivo HTML (`src/app/pages/login/login.page.html`) incluindo uma lista informativa com badges:**

```html
<ion-header [translucent]="true">
  <ion-toolbar color="primary">
    <ion-title>Portal Mobile</ion-title>
  </ion-toolbar>
</ion-header>

<ion-content class="ion-padding custom-background">
  <!-- Container responsivo que centraliza o conteúdo em telas maiores -->
  <div class="login-container">
    
    <!-- Cartão de formulário principal -->
    <ion-card class="login-card">
      <ion-card-header>
        <ion-card-title>Acesso ao Sistema</ion-card-title>
        <ion-card-subtitle>Informe suas credenciais para continuar</ion-card-subtitle>
      </ion-card-header>

      <ion-card-content>
        <ion-item lines="full" class="custom-item">
          <ion-input label="E-mail" labelPlacement="stacked" type="email" placeholder="seu.email@exemplo.com"></ion-input>
        </ion-item>

        <ion-item lines="full" class="custom-item">
          <ion-input label="Senha" labelPlacement="stacked" type="password" placeholder="Digite sua senha"></ion-input>
        </ion-item>

        <ion-button expand="block" color="primary" class="ion-margin-top">
          Entrar
        </ion-button>

        <ion-button expand="block" fill="outline" color="secondary" class="ion-margin-top">
          Criar Conta
        </ion-button>
      </ion-card-content>
    </ion-card>

    <!-- 📌 POR QUE A HIERARQUIA DA LISTA? (ion-list -> ion-item -> ion-label + ion-badge) -->
    <!-- ion-list agrupa um conjunto de itens; cada ion-item representa uma linha; -->
    <!-- ion-label contem o texto principal (h2/p) e ion-badge slot="end" fixa o selo/status no canto direito da linha -->
    <ion-list class="info-list ion-margin-top">
      <ion-item>
        <ion-label>
          <h2>Status da API</h2>
          <p>Backend Node/Express ativo</p>
        </ion-label>
        <ion-badge slot="end" color="success">Online</ion-badge>
      </ion-item>

      <ion-item>
        <ion-label>
          <h2>Versão do App</h2>
          <p>Ionic Angular Standalone</p>
        </ion-label>
        <ion-badge slot="end" color="tertiary">v1.0.0</ion-badge>
      </ion-item>
    </ion-list>

  </div>
</ion-content>
```

3. **Adicionar o estilo da lista no SCSS (`src/app/pages/login/login.page.scss`):**

```scss
// Estilização da lista informativa (bordas arredondadas e sombra leve)
.info-list {
  border-radius: 12px;
  background: #ffffff;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}
```

4. **Verificar a API no Terminal B:**
   - **No Git Bash:**
     ```bash
     curl http://localhost:3000/health
     ```
   - **No PowerShell:**
     ```powershell
     Invoke-RestMethod http://localhost:3000/health
     ```

5. **Validar a responsividade no navegador:**
   - Abra o **Developer Tools** (`F12`).
   - Ative o modo de dispositivo móvel (`Ctrl + Shift + M`).
   - Teste em resoluções como **iPhone SE (375px)** e **Pixel 7 (412px)**.

---

## ❓ Perguntas de Rápida Fixação (Fechamento da Aula)

> 💡 **Para o Professor:** Utilize estas perguntas nos últimos 5 a 10 minutos da aula para validar o entendimento dos alunos sobre a estrutura de tags e componentes.

1. **No Ionic 7+, por que não precisamos mais utilizar a tag `<ion-label>` isolada dentro do campo de texto `<ion-input>`?**
   * **Resposta:** O próprio `<ion-input>` aceita os atributos `label="E-mail"` e `labelPlacement="stacked"` integrados, tornando o código HTML mais limpo e reduzindo tags desnecessárias.

2. **Por que envolvemos o cartão de login dentro de uma `<div class="login-container">` com `max-width: 450px` e `margin: 0 auto` no SCSS?**
   * **Resposta:** Serve como um container de layout responsivo. Ele impede que o cartão fique esticado e desproporcional em telas maiores (tablets e desktops), centralizando a interface.

3. **Qual a função da hierarquia `<ion-list>` -> `<ion-item>` -> `<ion-label>` e `<ion-badge slot="end">`?**
   * **Resposta:** O `<ion-list>` organiza um grupo de linhas; cada `<ion-item>` representa uma linha contendo o texto (`<ion-label>`) e uma etiqueta alinhada à direita (`<ion-badge slot="end">`).

4. **No arquivo TypeScript (`login.page.ts`), por que importamos no array `imports: [...]` unicamente os elementos Ionic que usamos no HTML?**
   * **Resposta:** Aplica a boa prática de *Clean Code* e *Tree Shaking*, garantindo que a aplicação não carregue componentes desnecessários (código morto) e mantendo o aplicativo leve.

---

## 🔄 Fluxo Resumido de Execução Diária

1. **Terminal A (Mobile):**
```bash
cd projetos/ionic_projeto
npm run start
```

2. **Terminal B (API):**
```bash
cd projetos/mobile_api
npm start
```

3. **Teste rápido da API:**
```bash
curl http://localhost:3000/health
```

4. **Teste rápido do Mobile:**
   - Acessar `http://localhost:8100` no navegador.

---

## ✅ Saída Esperada ao Final da Aula

- Nova página `login` criada com `ng g c pages/login --type=page --standalone`.
- Formatação de entradas no padrão moderno do Ionic 7+ (`label="..."` e `labelPlacement="stacked"`).
- Array de `imports` limpo sem código morto ou componentes desnecessários.
- Interface gráfica estruturada e testada em emulação mobile.

---

**De onde viemos:**  
Retomamos os aprendizados de 'Configuração do Ambiente', consolidando os fundamentos necessários para avançar com segurança.

**Para onde vamos:**  
A partir desta base, avançaremos para 'Interfaces Gráficas - Parte 2', ampliando complexidade, autonomia e capacidade de aplicação prática.

