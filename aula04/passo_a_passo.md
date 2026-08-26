# Passo a Passo — Aula 04: Interfaces Gráficas - Parte 2

**Disciplina:** Desenvolvimento de Aplicativos Móveis  
**Tema:** Interfaces Gráficas - Parte 2  
---

> [!NOTE]
> **Objetivo Operacional:** Desenvolver formulários interativos com data binding bidirecional no Ionic 7+/Angular Standalone, aplicando `FormsModule`, rotulagem moderna com `label` e `labelPlacement="stacked"`, validações visuais de campos obrigatórios e exibição de feedbacks dinâmicos e estados de carregamento ao usuário.

> [!TIP]
> 💡 **Analogia Didática da Aula:** Um formulário com `[(ngModel)]` funciona como um espelho de duas vias (conhecido como "banana na caixa"): o que o usuário digita no campo visual (HTML) é atualizado instantaneamente na variável do código (TypeScript) e vice-versa.  
> 📌 **Dica Prática:** No Ionic 7+, os atributos `label="..."` e `labelPlacement="stacked"` são colocados diretamente na tag `<ion-input>`, tornando desnecessário o uso da tag `<ion-label>` e reduzindo os imports no TypeScript.

## 📁 Padrão de Caminhos e Organização
- Pasta base da turma: `projetos`
- Projeto Mobile: `projetos/ionic_projeto`
- Projeto API: `projetos/mobile_api`

> [!IMPORTANT]
> - Manter os terminais ativos durante o desenvolvimento:
>   - **Terminal A:** Mobile (`cd projetos/ionic_projeto` -> `npm run start`)
>   - **Terminal B:** API (`cd projetos/mobile_api` -> `npm start`)
>   - **Terminal C:** CLI do Angular/Ionic para geração de páginas

---

## ⏱️ Roteiro Completo de Atividades (4 Horas)

### Bloco 1 - Criação da Página de Cadastro e Estrutura de Rotas

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

3. No **Terminal C (Git Bash)**, navegar para a pasta do projeto mobile e gerar a página de cadastro:
```bash
cd projetos/ionic_projeto
ng g c pages/cadastro --type=page --standalone
```
> 💡 **O que o comando faz:**  
> O `ng g c pages/cadastro --type=page --standalone` gera os 4 arquivos essenciais da página Standalone dentro de `src/app/pages/cadastro/` (`.page.ts`, `.page.html`, `.page.scss` e `.page.spec.ts`), sem criar arquivos de módulos legados.

4. **Atualizar o arquivo de rotas (`src/app/app.routes.ts`) para registrar a nova rota `/cadastro`:**

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
    loadComponent: () => import('./pages/cadastro/cadastro.page').then( m => m.CadastroPage) // Rota da tela de cadastro
  },
];
```

5. **Validar no navegador:**
   - Acesse `http://localhost:8100/cadastro` no navegador.
   - Confirme que a página de cadastro gerada carrega sem erros.

---

### Bloco 2 - Data Binding Bidirecional com ngModel e Validação no TypeScript

1. **Abrir o arquivo TypeScript (`src/app/pages/cadastro/cadastro.page.ts`) e estruturar os imports enxutos do Ionic 7+:**

```typescript
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms'; // Obrigatório para o uso de [(ngModel)]
import {
  IonContent,
  IonHeader,
  IonTitle,
  IonToolbar,
  IonCard,
  IonCardHeader,
  IonCardTitle,
  IonCardContent,
  IonItem,
  IonInput,
  IonButton,
  IonText,
  IonSpinner
} from '@ionic/angular/standalone';

@Component({
  selector: 'app-cadastro',
  templateUrl: './cadastro.page.html',
  styleUrls: ['./cadastro.page.scss'],
  standalone: true,
  imports: [
    CommonModule,
    FormsModule, // Registrado para habilitar formulários reativos/bidirecionais
    IonContent,
    IonHeader,
    IonTitle,
    IonToolbar,
    IonCard,
    IonCardHeader,
    IonCardTitle,
    IonCardContent,
    IonItem,
    IonInput,
    IonButton,
    IonText,
    IonSpinner
  ]
})
export class CadastroPage implements OnInit {

  // Objeto que armazena os dados digitados no formulário
  usuario = {
    nome: '',
    email: '',
    senha: ''
  };

  // Variáveis para controle de feedback visual
  mensagemErro = '';
  mensagemSucesso = '';
  carregando = false;

  constructor() { }

  ngOnInit() { }

  // Função disparada ao clicar no botão de cadastro
  cadastrar() {
    // Limpa mensagens anteriores
    this.mensagemErro = '';
    this.mensagemSucesso = '';

    // Validação 1: Campos obrigatórios
    if (!this.usuario.nome || !this.usuario.email || !this.usuario.senha) {
      this.mensagemErro = 'Preencha todos os campos obrigatórios!';
      return;
    }

    // Validação 2: Tamanho mínimo da senha
    if (this.usuario.senha.length < 6) {
      this.mensagemErro = 'A senha deve ter pelo menos 6 caracteres!';
      return;
    }

    // Ativa o estado de carregamento
    this.carregando = true;

    // Simula uma requisição com atraso de 1.5 segundos
    setTimeout(() => {
      this.carregando = false;
      this.mensagemSucesso = 'Cadastro realizado com sucesso!';
      console.log('Dados do formulário salvos:', this.usuario);
    }, 1500);
  }
}
```
> 📌 **Entendendo os Imports:**  
> Como utilizamos `label="Nome"` e `labelPlacement="stacked"` diretamente no `<ion-input>`, não precisamos importar `IonLabel`, mantendo o bundle leve.

2. **Validar:** Salve o arquivo e certifique-se de que não há erros de sintaxe no terminal.

---

### Bloco 3 - HTML do Formulário no Padrão Ionic 7+

1. **Abrir o arquivo HTML (`src/app/pages/cadastro/cadastro.page.html`) e conectar os campos com a diretiva `[(ngModel)]` e rótulos integrados:**

```html
<!-- Cabeçalho Superior -->
<ion-header [translucent]="true">
  <ion-toolbar color="primary">
    <ion-title>Cadastro de Usuário</ion-title>
  </ion-toolbar>
</ion-header>

<!-- Conteúdo Principal -->
<ion-content class="ion-padding custom-background">
  <div class="form-container">
    
    <ion-card class="form-card">
      <ion-card-header>
        <ion-card-title>Criar Nova Conta</ion-card-title>
      </ion-card-header>

      <ion-card-content>
        <!-- Campo Nome Completo -->
        <ion-item lines="full" class="custom-item">
          <ion-input label="Nome Completo" labelPlacement="stacked" type="text" [(ngModel)]="usuario.nome" placeholder="Digite seu nome"></ion-input>
        </ion-item>

        <!-- Campo E-mail -->
        <ion-item lines="full" class="custom-item">
          <ion-input label="E-mail" labelPlacement="stacked" type="email" [(ngModel)]="usuario.email" placeholder="seu.email@exemplo.com"></ion-input>
        </ion-item>

        <!-- Campo Senha -->
        <ion-item lines="full" class="custom-item">
          <ion-input label="Senha" labelPlacement="stacked" type="password" [(ngModel)]="usuario.senha" placeholder="Mínimo 6 caracteres"></ion-input>
        </ion-item>

        <!-- Mensagem de Erro (Exibida dinamicamente) -->
        <div *ngIf="mensagemErro" class="ion-padding-vertical">
          <ion-text color="danger">
            <p class="feedback-msg">{{ mensagemErro }}</p>
          </ion-text>
        </div>

        <!-- Mensagem de Sucesso (Exibida dinamicamente) -->
        <div *ngIf="mensagemSucesso" class="ion-padding-vertical">
          <ion-text color="success">
            <p class="feedback-msg">{{ mensagemSucesso }}</p>
          </ion-text>
        </div>

        <!-- Botão de Envio com Estado de Loading -->
        <ion-button expand="block" color="primary" class="ion-margin-top" (click)="cadastrar()" [disabled]="carregando">
          <ion-spinner *ngIf="carregando" name="crescent"></ion-spinner>
          <span *ngIf="!carregando">Finalizar Cadastro</span>
        </ion-button>
      </ion-card-content>
    </ion-card>

  </div>
</ion-content>
```
> 💡 **Como funciona a sintaxe `[(ngModel)]` com Ionic 7+?**  
> O `[(ngModel)]` continua gerenciando o data binding bidirecional perfeitamente, enquanto `label="E-mail"` e `labelPlacement="stacked"` cuidam do alinhamento nativo do rótulo no `<ion-input>`.

2. **Validar no navegador:**
   - Tente clicar em "Finalizar Cadastro" com os campos vazios para observar a mensagem vermelha de erro.
   - Digite um nome e e-mail, mas insira uma senha com 3 caracteres para testar a validação de tamanho.
   - Preencha tudo corretamente e observe o spinner de carregamento funcionando por 1.5s antes de exibir a mensagem de sucesso verde.

---

### Bloco 4 - Estilização SCSS e Validação Responsiva em Dispositivos Móveis

1. **Atualizar o arquivo de estilos (`src/app/pages/cadastro/cadastro.page.scss`):**

```scss
.custom-background {
  --background: #f8fafc;
}

.form-container {
  max-width: 480px;
  margin: 0 auto;
  padding-top: 16px;
}

.form-card {
  border-radius: 16px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.06);
}

.feedback-msg {
  font-size: 0.9rem;
  font-weight: 600;
  margin: 4px 0;
}

ion-button {
  --border-radius: 8px;
  height: 48px;
}
```

2. **Validar a API no Terminal B:**
   - **No Git Bash:**
     ```bash
     curl http://localhost:3000/health
     ```
   - **No PowerShell:**
     ```powershell
     Invoke-RestMethod http://localhost:3000/health
     ```

3. **Validar a responsividade no DevTools do navegador:**
   - Pressione `F12` e ative o modo de dispositivo móvel (`Ctrl + Shift + M`).
   - Teste em telas pequenas como **iPhone SE (375px)** e **Pixel 7 (412px)**.

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

3. **Teste rápido do Formulário:**
   - Acessar `http://localhost:8100/cadastro` no navegador.

---

## ✅ Saída Esperada ao Final da Aula

- Página `cadastro` criada e integrada ao sistema de rotas do Angular.
- Formulário funcional no padrão moderno Ionic 7+ com `[(ngModel)]` e `labelPlacement="stacked"`.
- Array de `imports` limpo sem componentes não utilizados.
- Validações ativas para campos obrigatórios e tamanho de senha.
