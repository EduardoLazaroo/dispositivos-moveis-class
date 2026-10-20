# Passo a Passo — Aula 07: Navegação entre Telas - Parte 2

**Disciplina:** Desenvolvimento de Aplicativos Móveis  
**Tema:** Navegação entre Telas - Parte 2  
---

> [!NOTE]
> **Objetivo Operacional:** Aprimorar os padrões de navegação da aplicação integrando navegação por abas inferiores (`<ion-tabs>`) e menu lateral deslizante (`<ion-menu>`), organizando fluxos de rotas filhas (*children routes*) e melhorando a usabilidade em aplicativos corporativos.

> [!TIP]
> 💡 **Analogia Didática da Aula:** A estrutura de abas e menu lateral funciona como o controle remoto de uma TV smart: as abas inferiores são os botões de atalho rápido para as funções mais usadas (Início, Perfil), enquanto o menu lateral é o menu completo de configurações da conta.  
> 📌 **Dica Prática:** Use a propriedade `children` no arquivo `app.routes.ts` para agrupar páginas que compartilham a mesma barra de abas.

## 📁 Padrão de Caminhos e Organização
- Pasta base da turma: `projetos`
- Projeto Mobile: `projetos/ionic_projeto`
- Projeto API: `projetos/mobile_api`

> [!IMPORTANT]
> - Manter os 3 terminais ativos durante o desenvolvimento:
>   - **Terminal A:** Mobile (`cd projetos/ionic_projeto` -> `npm run start`)
>   - **Terminal B:** API (`cd projetos/mobile_api` -> `npm start`)
>   - **Terminal C:** CLI do Ionic para geração de páginas
> - Organizar as rotas filhas (*children*) no arquivo `app.routes.ts` dentro do componente container `TabsPage`.

---

## ⏱️ Roteiro Completo de Atividades (4 Horas)

### Bloco 1 - Criação da Estrutura de Abas (Tabs Page) e Rotas Filhas

1. Garantir que o **Terminal A (Mobile)** está em execução:
```bash
cd projetos/ionic_projeto
npm run start
```

2. Garantir que o **Terminal B (API)** está em execução:
```bash
cd projetos/mobile_api
npm start
```

3. No **Terminal C (Git Bash)**, gerar a página container `tabs` e as duas páginas filhas `inicio` e `perfil`:
```bash
cd projetos/ionic_projeto
ng g c pages/tabs --type=page --standalone
ng g c pages/inicio --type=page --standalone
ng g c pages/perfil --type=page --standalone
```
> 💡 **Entendendo a estratégia:**  
> A página Standalone `tabs` atuará como um container (moldura) que segura a barra inferior de botões. As páginas filhas `inicio` e `perfil` serão carregadas dinamicamente no centro da tela conforme a aba selecionada.

4. **Editar o arquivo de rotas (`src/app/app.routes.ts`) registrando as rotas filhas (`children`):**

```typescript
import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    redirectTo: 'tabs/inicio',
    pathMatch: 'full',
  },
  {
    path: 'login',
    loadComponent: () => import('./pages/login/login.page').then( m => m.LoginPage)
  },
  {
    path: 'tabs',
    loadComponent: () => import('./pages/tabs/tabs.page').then( m => m.TabsPage),
    // Declaração de rotas filhas sob a casca do 'tabs'
    children: [
      {
        path: 'inicio',
        loadComponent: () => import('./pages/inicio/inicio.page').then( m => m.InicioPage)
      },
      {
        path: 'perfil',
        loadComponent: () => import('./pages/perfil/perfil.page').then( m => m.PerfilPage)
      },
      {
        path: '',
        redirectTo: 'inicio',
        pathMatch: 'full'
      }
    ]
  }
];
```
> 📌 **Como funcionam `children` routes?**  
> As rotas filhas herdam o contexto do componente pai (`tabs.page`). Ao acessar `/tabs/inicio`, o Angular renderiza o `TabsPage` e injeta o `InicioPage` no canal de saída do container.

5. **Validar no navegador:** Acesse `http://localhost:8100/tabs/inicio` e verifique o redirecionamento.

---

### Bloco 2 - Construção da Barra de Abas (ion-tab-bar)

1. **Editar o arquivo TypeScript (`src/app/pages/tabs/tabs.page.ts`) importando os componentes de abas e ícones:**

```typescript
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { 
  IonTabs, 
  IonTabBar, 
  IonTabButton, 
  IonIcon, 
  IonLabel 
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { homeOutline, personOutline } from 'ionicons/icons';

@Component({
  selector: 'app-tabs',
  templateUrl: './tabs.page.html',
  styleUrls: ['./tabs.page.scss'],
  standalone: true,
  imports: [
    CommonModule, 
    IonTabs, 
    IonTabBar, 
    IonTabButton, 
    IonIcon, 
    IonLabel
  ]
})
export class TabsPage implements OnInit {
  constructor() {
    // Registro explícito dos ícones SVG utilizados nas abas
    addIcons({ homeOutline, personOutline });
  }

  ngOnInit() { }
}
```

2. **Editar o HTML (`src/app/pages/tabs/tabs.page.html`) com a barra de abas inferior:**

```html
<ion-tabs>
  <!-- Barra de abas fixada na parte inferior (slot="bottom") -->
  <ion-tab-bar slot="bottom" color="light">
    
    <!-- Aba Início -->
    <ion-tab-button tab="inicio" href="/tabs/inicio">
      <ion-icon name="home-outline"></ion-icon>
      <ion-label>Início</ion-label>
    </ion-tab-button>

    <!-- Aba Perfil -->
    <ion-tab-button tab="perfil" href="/tabs/perfil">
      <ion-icon name="person-outline"></ion-icon>
      <ion-label>Perfil</ion-label>
    </ion-tab-button>

  </ion-tab-bar>
</ion-tabs>
```

3. **Validar no navegador:** Acesse `http://localhost:8100/tabs/inicio` e teste a alternância de tela ao clicar nos botões de abas inferiores.

---

### Bloco 3 - Criação do Menu Lateral (ion-menu)

1. **Editar o arquivo principal do aplicativo (`src/app/app.component.html`) para integrar o `<ion-menu>`:**

```html
<!-- Menu Lateral Deslizante -->
<ion-menu contentId="main-content">
  <ion-header>
    <ion-toolbar color="primary">
      <ion-title>Menu Principal</ion-title>
    </ion-toolbar>
  </ion-header>

  <ion-content class="ion-padding">
    <ion-list lines="none">
      <ion-item button routerLink="/tabs/inicio">
        <ion-label>Início</ion-label>
      </ion-item>
      
      <ion-item button routerLink="/tabs/perfil">
        <ion-label>Meu Perfil</ion-label>
      </ion-item>
      
      <ion-item button routerLink="/login">
        <ion-label color="danger">Sair do App</ion-label>
      </ion-item>
    </ion-list>
  </ion-content>
</ion-menu>

<!-- Área de Conteúdo Principal vinculada ao id main-content -->
<div class="ion-page" id="main-content">
  <ion-router-outlet></ion-router-outlet>
</div>
```

2. **Editar o HTML da página de início (`src/app/pages/inicio/inicio.page.html`) para incluir o botão de disparar o menu (`<ion-menu-button>`):**

```html
<ion-header [translucent]="true">
  <ion-toolbar color="primary">
    <!-- Botão que abre o menu lateral -->
    <ion-buttons slot="start">
      <ion-menu-button></ion-menu-button>
    </ion-buttons>
    <ion-title>Painel Principal</ion-title>
  </ion-toolbar>
</ion-header>

<ion-content class="ion-padding">
  <h2>Bem-vindo ao Sistema Mobile!</h2>
  <p>Utilize as abas inferiores ou o menu lateral para navegar entre os módulos.</p>
</ion-content>
```

3. **Validar no navegador:** Clique no ícone de "hambúrguer" no canto superior esquerdo e confirme a abertura suave do menu lateral.

---

### Bloco 4 - Testes de Integração de Navegação e Ajustes Visuais

1. **Testar fluxos combinados:**
   - Navegue entre as Abas (Início <-> Perfil).
   - Abra o Menu Lateral e clique em "Sair do App" para voltar à tela de Login.

2. **Testar a saúde do backend na API Node:**
   - **No Git Bash:**
     ```bash
     curl http://localhost:3000/health
     ```
   - **No PowerShell:**
     ```powershell
     Invoke-RestMethod http://localhost:3000/health
     ```

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

3. **Teste do App:**
   - Acessar `http://localhost:8100/tabs/inicio` e testar a sincronia das abas e do menu lateral.

---

## ✅ Saída Esperada ao Final da Aula

- Estrutura de abas (`<ion-tabs>`) funcional com rotas filhas em `app.routes.ts`.
- Barra inferior com ícones e rótulos para Início e Perfil.
- Menu lateral (`<ion-menu>`) com opção de atalho para módulos e botão de logout.
- Interface responsiva com padrão completo de navegação mobile.

---

**De onde viemos:**  
Retomamos os aprendizados de 'Navegação entre Telas - Parte 1', consolidando os fundamentos necessários para avançar com segurança.

**Para onde vamos:**  
A partir desta base, avançaremos para 'Consumo de APIs - Parte 1', ampliando complexidade, autonomia e capacidade de aplicação prática.
