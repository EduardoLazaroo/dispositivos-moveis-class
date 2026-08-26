# Passo a Passo — Aula 05: Interfaces Gráficas - Parte 3

**Disciplina:** Desenvolvimento de Aplicativos Móveis  
**Tema:** Interfaces Gráficas - Parte 3  
---

> [!NOTE]
> **Objetivo Operacional:** Aprimorar a construção de interfaces com componentes reutilizáveis no Angular/Ionic, aplicar propriedades dinâmicas com `@Input()`, projeção de conteúdo com `<ng-content>`, padronização de tema global em SCSS/CSS e refinamento de UX/UI para manter consistência visual no aplicativo.

> [!TIP]
> 💡 **Analogia Didática da Aula:** Ajustar temas e criar componentes reutilizáveis no Ionic é como a pintura e os acabamentos de uma frota de carros: você cria um único modelo de peça (componente) ou ajusta a paleta no `variables.css` e todo o aplicativo ganha uma identidade visual padronizada instantaneamente.  
> 📌 **Dica Prática:** Use variáveis CSS globais (como `--ion-color-primary`) para alterar as cores do aplicativo inteiro em um único arquivo.

## 📁 Padrão de Caminhos e Organização
- Pasta base da turma: `projetos`
- Projeto Mobile: `projetos/ionic_projeto`
- Projeto API: `projetos/mobile_api`

> [!IMPORTANT]
> - Manter os 3 terminais ativos durante o desenvolvimento:
>   - **Terminal A:** Mobile (`cd projetos/ionic_projeto` -> `npm run start`)
>   - **Terminal B:** API (`cd projetos/mobile_api` -> `npm start`)
>   - **Terminal C:** CLI do Ionic para geração de componentes
> - Criar a pasta `src/app/components` para organizar os componentes reutilizáveis da aplicação.

---

## ⏱️ Roteiro Completo de Atividades (4 Horas)

### Bloco 1 - Criação de Componente Reutilizável de Card Informativo

1. Garantir que o **Terminal A (Mobile)** está rodando:
```bash
cd projetos/ionic_projeto
npm run start
```

2. Garantir que o **Terminal B (API)** está em execução:
```bash
cd projetos/mobile_api
npm start
```

3. No **Terminal C (Git Bash)**, navegar para a pasta do mobile e gerar o componente reutilizável `card-status`:
```bash
cd projetos/ionic_projeto
ng g c components/card-status --standalone
```
> 💡 **Entendendo o comando:**  
> O `ng g c components/card-status --standalone` gera uma pasta dentro de `src/app/components/card-status/` com os arquivos `.ts`, `.html`, `.scss` e `.spec.ts`, prontos para serem importados em qualquer página do app.

4. **Editar o arquivo TypeScript (`src/app/components/card-status/card-status.component.ts`) adicionando propriedades dinamizadas via `@Input()`:**

```typescript
import { Component, Input, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { 
  IonCard, 
  IonCardHeader, 
  IonCardTitle, 
  IonCardSubtitle, 
  IonCardContent, 
  IonIcon, 
  IonBadge 
} from '@ionic/angular/standalone';

@Component({
  selector: 'app-card-status',
  templateUrl: './card-status.component.html',
  styleUrls: ['./card-status.component.scss'],
  standalone: true,
  imports: [
    CommonModule, 
    IonCard, 
    IonCardHeader, 
    IonCardTitle, 
    IonCardSubtitle, 
    IonCardContent, 
    IonIcon, 
    IonBadge
  ]
})
export class CardStatusComponent implements OnInit {
  // Propriedades recebidas pelo componente pai através do HTML
  @Input() titulo: string = '';
  @Input() subtitulo: string = '';
  @Input() status: string = 'Normal';
  @Input() corStatus: string = 'success';

  constructor() { }

  ngOnInit() { }
}
```
> 📌 **O que faz o decorator `@Input()`?**  
> O `@Input()` permite que uma página externa passe informações para dentro do componente reutilizável (por exemplo, `<app-card-status titulo="Conexão">`), tornando o componente genérico e adaptável a diferentes cenários.

5. **Validar:** Certifique-se de que o código compila sem erros no terminal.

---

### Bloco 2 - HTML e SCSS do Componente Reutilizável

1. **Editar o arquivo HTML (`src/app/components/card-status/card-status.component.html`) para definir o layout do cartão com `<ng-content>`:**

```html
<ion-card class="status-card">
  <ion-card-header>
    <div class="header-row">
      <ion-card-title>{{ titulo }}</ion-card-title>
      <ion-badge [color]="corStatus">{{ status }}</ion-badge>
    </div>
    <ion-card-subtitle>{{ subtitulo }}</ion-card-subtitle>
  </ion-card-header>

  <ion-card-content>
    <!-- O ng-content projeta qualquer elemento HTML enviado entre as tags <app-card-status> -->
    <ng-content></ng-content>
  </ion-card-content>
</ion-card>
```
> 💡 **Para que serve o `<ng-content>`?**  
> Funciona como um "slot" livre. Todo texto ou elemento HTML colocado dentro da tag do componente (ex: `<app-card-status><p>Texto extra</p></app-card-status>`) será renderizado exatamente onde o `<ng-content></ng-content>` está posicionado.

2. **Editar o arquivo SCSS (`src/app/components/card-status/card-status.component.scss`):**

```scss
.status-card {
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  margin: 12px 0;

  .header-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  ion-card-title {
    font-size: 1.1rem;
    font-weight: 700;
  }
}
```

3. **Validar:** Salve os arquivos e confirme se não existem erros de compilação.

---

### Bloco 3 - Utilização do Componente em Páginas Existentes e Tema Global

1. **Abrir o arquivo da página de login (`src/app/pages/login/login.page.ts`) e importar o novo componente:**

```typescript
// Importe o componente reutilizável no topo do arquivo
import { CardStatusComponent } from '../../components/card-status/card-status.component';

// Adicione CardStatusComponent ao array de imports do decorator @Component:
/*
@Component({
  ...
  imports: [ ..., CardStatusComponent ]
})
*/
```

2. **Incluir a chamada do componente no HTML (`src/app/pages/login/login.page.html`):**

```html
<app-card-status
  titulo="Conexão de Rede"
  subtitulo="Monitoramento da API em tempo real"
  status="Conectado"
  corStatus="success">
  <p>Sua API Node/Express está operando normalmente na porta 3000.</p>
</app-card-status>
```

3. **Atualizar as variáveis globais de tema no arquivo `src/theme/variables.css` (ou `.scss`):**

```css
:root {
  /* Altera a cor primária global da aplicação para azul moderno */
  --ion-color-primary: #3b82f6;
  --ion-color-primary-rgb: 59, 130, 246;
  --ion-color-primary-contrast: #ffffff;

  /* Altera a cor secundária global para ciano */
  --ion-color-secondary: #06b6d4;
  --ion-color-secondary-contrast: #ffffff;
}
```

4. **Validar no navegador:**
   - Acesse `http://localhost:8100/login`.
   - Observe que a cor primária do aplicativo mudou e o novo cartão reutilizável aparece renderizado perfeitamente abaixo do formulário.

---

### Bloco 4 - Auditoria de Consistência e Testes de Responsividade

1. **Testar responsividade dinamicamente:**
   - No navegador, abra a inspeção de elementos (`F12`) e altere o tamanho da tela (`Ctrl + Shift + M`).
   - Teste a exibição em **375px (iPhone SE)** e **412px (Pixel 7)**.

2. **Validar consistência entre telas:**
   - Compare o visual da tela de Login e de Cadastro para garantir que os botões, fontes e arredondamentos sigam a mesma identidade.

3. **Testar a saúde do backend na API Node:**
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

3. **Teste visual do App:**
   - Acessar `http://localhost:8100` e verificar a renderização dos componentes reutilizáveis.

---

## ✅ Saída Esperada ao Final da Aula

- Componente reutilizável `CardStatusComponent` criado em `src/app/components/card-status/`.
- Passagem de dados via `@Input()` e projeção de conteúdo com `<ng-content>` operacionais.
- Tema global padronizado em `variables.css`.
- Interface refinada com consistência visual e usabilidade testada.

---

**De onde viemos:**  
Retomamos os aprendizados de 'Interfaces Gráficas - Parte 2', consolidando os fundamentos necessários para avançar com segurança.

**Para onde vamos:**  
A partir desta base, avançaremos para 'Navegação entre Telas - Parte 1', ampliando complexidade, autonomia e capacidade de aplicação prática.
