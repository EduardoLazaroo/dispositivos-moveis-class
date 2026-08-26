# Passo a Passo — Aula 06: Navegação entre Telas - Parte 1

**Disciplina:** Desenvolvimento de Aplicativos Móveis  
**Tema:** Navegação entre Telas - Parte 1  
---

> [!NOTE]
> **Objetivo Operacional:** Implementar roteamento básico e navegação entre páginas no Ionic/Angular utilizando o `Router` do Angular e o `NavController` do Ionic, realizando a passagem simples de parâmetros dinâmicos via URL entre telas e organizando o fluxo de navegação nativo do aplicativo.

> [!TIP]
> 💡 **Analogia Didática da Aula:** O arquivo de rotas (`app.routes.ts`) funciona como o mapa de corredores de um edifício: cada rota (`/login`, `/cadastro`, `/detalhes/:id`) é a placa indicando qual porta (página) será aberta no aplicativo.  
> 📌 **Dica Prática:** Utilize o componente `<ion-back-button defaultHref="/login">` para incluir automaticamente o botão de voltar no cabeçalho sem precisar escrever funções personalizadas de histórico.

## 📁 Padrão de Caminhos e Organização
- Pasta base da turma: `projetos`
- Projeto Mobile: `projetos/ionic_projeto`
- Projeto API: `projetos/mobile_api`

> [!IMPORTANT]
> - Manter os 3 terminais ativos durante o desenvolvimento:
>   - **Terminal A:** Mobile (`cd projetos/ionic_projeto` -> `npm run start`)
>   - **Terminal B:** API (`cd projetos/mobile_api` -> `npm start`)
>   - **Terminal C:** CLI do Ionic/Angular para geração de novas páginas
> - Injetar o serviço `Router` de `@angular/router` no construtor do componente para realizar navegações programáticas via código TypeScript.

---

## ⏱️ Roteiro Completo de Atividades (4 Horas)

### Bloco 1 - Geração da Página de Detalhes e Configuração de Rotas com Parâmetros

1. Garantir que o **Terminal A (Mobile)** está em execução:
```bash
cd projetos/ionic_projeto
npm run start
```

2. Garantir que o **Terminal B (API)** está rodando a API:
```bash
cd projetos/mobile_api
npm start
```

3. No **Terminal C (Git Bash)**, navegar para a pasta do mobile e gerar a página de detalhes:
```bash
cd projetos/ionic_projeto
ng g c pages/detalhes --type=page --standalone
```
> 💡 **O que o comando faz:**  
> O `ng g c pages/detalhes --type=page --standalone` gera a estrutura da tela Standalone em `src/app/pages/detalhes/` com os arquivos de TypeScript, HTML, SCSS e testes.

4. **Atualizar o arquivo de rotas (`src/app/app.routes.ts`) incluindo a rota dinâmica `/detalhes/:id`:**

```typescript
import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    redirectTo: 'login',
    pathMatch: 'full',
  },
  {
    path: 'login',
    loadComponent: () => import('./pages/login/login.page').then( m => m.LoginPage)
  },
  {
    path: 'cadastro',
    loadComponent: () => import('./pages/cadastro/cadastro.page').then( m => m.CadastroPage)
  },
  {
    path: 'detalhes/:id', // O símbolo :id indica um parâmetro dinâmico de URL
    loadComponent: () => import('./pages/detalhes/detalhes.page').then( m => m.DetalhesPage)
  },
];
```
> 📌 **O que significa `:id` na rota?**  
> O prefixo `:` define uma variável de rota. Isso significa que URLs como `/detalhes/1`, `/detalhes/42` ou `/detalhes/101` responderão a esta mesma rota, e o valor (ex: `42`) estará disponível para ser lido no TypeScript.

5. **Validar no navegador:**
   - Acesse manualmente no navegador: `http://localhost:8100/detalhes/101`.
   - Confirme se a página de detalhes gerada abre perfeitamente.

---

### Bloco 2 - Navegação Programática na Página de Login

1. **Abrir o arquivo TypeScript (`src/app/pages/login/login.page.ts`) e injetar o serviço `Router`:**

```typescript
import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router'; // Importação do serviço de roteamento
// Manter os demais imports do Ionic...

@Component({
  selector: 'app-login',
  templateUrl: './login.page.html',
  styleUrls: ['./login.page.scss'],
  standalone: true,
  imports: [ /* ... componentes Ionic ... */ ]
})
export class LoginPage implements OnInit {

  // Injeção de dependência do Router no construtor
  constructor(private router: Router) { }

  ngOnInit() { }

  // Navegação simples para a tela de cadastro
  irParaCadastro() {
    this.router.navigate(['/cadastro']);
  }

  // Navegação com parâmetro de URL dinâmico
  entrarComId(idUsuario: number) {
    this.router.navigate(['/detalhes', idUsuario]);
  }
}
```
> 💡 **Como funciona `this.router.navigate()`?**  
> Esse método aceita um array de segmentos de caminho. Por exemplo, `['/detalhes', 42]` resulta na URL final `/detalhes/42`, permitindo transições de tela dinâmicas via código.

2. **Atualizar o HTML (`src/app/pages/login/login.page.html`) associando os métodos aos botões:**

```html
<!-- Botão com envio de parâmetro -->
<ion-button expand="block" color="primary" class="ion-margin-top" (click)="entrarComId(42)">
  Entrar (ID: 42)
</ion-button>

<!-- Botão com navegação simples -->
<ion-button expand="block" fill="outline" color="secondary" class="ion-margin-top" (click)="irParaCadastro()">
  Criar Conta
</ion-button>
```

3. **Validar no navegador:**
   - Clique em "Criar Conta" e verifique se a aplicação transita para `/cadastro`.
   - Clique em "Entrar (ID: 42)" e verifique a navegação para `/detalhes/42`.

---

### Bloco 3 - Recebimento de Parâmetros na Página de Detalhes

1. **Editar o arquivo TypeScript (`src/app/pages/detalhes/detalhes.page.ts`) injetando o `ActivatedRoute`:**

```typescript
import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router'; // Permite ler informações da rota ativa
import { CommonModule } from '@angular/common';
import { 
  IonContent, 
  IonHeader, 
  IonTitle, 
  IonToolbar, 
  IonCard, 
  IonCardHeader, 
  IonCardTitle, 
  IonCardContent, 
  IonButton, 
  IonBackButton, 
  IonButtons 
} from '@ionic/angular/standalone';

@Component({
  selector: 'app-detalhes',
  templateUrl: './detalhes.page.html',
  styleUrls: ['./detalhes.page.scss'],
  standalone: true,
  imports: [
    CommonModule, 
    IonContent, 
    IonHeader, 
    IonTitle, 
    IonToolbar, 
    IonCard, 
    IonCardHeader, 
    IonCardTitle, 
    IonCardContent, 
    IonButton, 
    IonBackButton, 
    IonButtons
  ]
})
export class DetalhesPage implements OnInit {
  // Variável para armazenar o ID capturado da URL
  itemId: string | null = '';

  constructor(private route: ActivatedRoute) { }

  ngOnInit() {
    // Captura o parâmetro 'id' definido na rota /detalhes/:id
    this.itemId = this.route.snapshot.paramMap.get('id');
    console.log('ID recebido pela rota:', this.itemId);
  }
}
```
> 📌 **Entendendo o `this.route.snapshot.paramMap`:**  
> O `snapshot` tira uma "foto" do estado atual da rota. O método `.paramMap.get('id')` extrai exatamente o valor que foi passado na URL na posição do parâmetro `:id`.

2. **Editar o HTML (`src/app/pages/detalhes/detalhes.page.html`) incluindo o botão nativo de voltar (`<ion-back-button>`):**

```html
<ion-header [translucent]="true">
  <ion-toolbar color="primary">
    <!-- Botão de voltar integrado ao lado esquerdo da toolbar -->
    <ion-buttons slot="start">
      <ion-back-button defaultHref="/login"></ion-back-button>
    </ion-buttons>
    <ion-title>Detalhes do Item</ion-title>
  </ion-toolbar>
</ion-header>

<ion-content class="ion-padding">
  <ion-card>
    <ion-card-header>
      <ion-card-title>Item Selecionado</ion-card-title>
    </ion-card-header>
    <ion-card-content>
      <p>ID do Registro: <strong>{{ itemId }}</strong></p>
    </ion-card-content>
  </ion-card>
</ion-content>
```

3. **Validar no navegador:**
   - Navegue de Login para Detalhes e confirme a exibição do ID capturado na tela.
   - Clique na seta de voltar na barra superior e verifique o retorno limpo para a tela de Login.

---

### Bloco 4 - Validação Completa do Fluxo e Pilha de Navegação

1. **Testar o fluxo completo de navegação:**
   - `Login` -> `Cadastro` -> Voltar -> `Login` -> `Detalhes (ID: 42)` -> Voltar.

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

3. **Teste da Navegação:**
   - Clique nos botões da interface e valide a alteração de URLs e passagem de parâmetros.

---

## ✅ Saída Esperada ao Final da Aula

- Rota dinâmica `/detalhes/:id` configurada em `app.routes.ts`.
- Navegação programática via `router.navigate()` operando sem erros.
- Leitura de parâmetros de URL no TypeScript com `ActivatedRoute.snapshot.paramMap`.
- Botão `<ion-back-button>` integrado no cabeçalho com histórico de navegação funcional.

---

**De onde viemos:**  
Retomamos os aprendizados de 'Interfaces Gráficas - Parte 3', consolidando os fundamentos necessários para avançar com segurança.

**Para onde vamos:**  
A partir desta base, avançaremos para 'Navegação entre Telas - Parte 2', ampliando complexidade, autonomia e capacidade de aplicação prática.
