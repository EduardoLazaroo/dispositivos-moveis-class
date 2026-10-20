# Passo a Passo — Aula 09: Consumo de APIs REST e Tratamento de Erros - Parte 1

**Disciplina:** Desenvolvimento de Aplicativos Móveis  
**Tema:** Consumo de APIs REST e Tratamento de Erros - Parte 1  
---

> [!NOTE]
> **Objetivo Operacional:** Integrar a aplicação mobile com o backend Node/Express utilizando `provideHttpClient` e `HttpClient` do Angular, realizando requisições HTTP GET, mapeando respostas em formato JSON e exibindo listas dinâmicas de dados na interface Ionic.

> [!TIP]
> 💡 **Analogia Didática da Aula:** O `HttpClient` do Angular é como o garçom no restaurante: o aplicativo faz o pedido na mesa (Mobile), o garçom traz da cozinha (API Node/Express) e serve os dados pronto para consumo na tela (JSON).  
> 📌 **Dica Prática:** Não se esqueça de adicionar `provideHttpClient()` no arquivo `src/main.ts` para liberar as chamadas HTTP no Angular Standalone.

## 📁 Padrão de Caminhos e Organização
- Pasta base da turma: `projetos`
- Projeto Mobile: `projetos/ionic_projeto`
- Projeto API: `projetos/mobile_api`

> [!IMPORTANT]
> - Manter obrigatoriamente os 3 terminais abertos:
>   - **Terminal A:** Mobile (`cd projetos/ionic_projeto` -> `npm run start`)
>   - **Terminal B:** API (`cd projetos/mobile_api` -> `npm start`)
>   - **Terminal C:** CLI do Ionic para geração de serviços e páginas
> - Configurar o `provideHttpClient()` no arquivo `src/main.ts` para habilitar a comunicação HTTP na arquitetura Standalone.

---

## ⏱️ Roteiro Completo de Atividades (4 Horas)

### Bloco 1 - Adição de Endpoint REST na API Node/Express

1. No **Terminal B (API)**, acessar a pasta do backend:
```bash
cd projetos/mobile_api
```

2. **Editar o arquivo `src/app.js` para incluir o endpoint GET `/produtos` com dados de teste em JSON:**

```javascript
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// Dados simulados de produtos
const produtos = [
  { id: 1, nome: 'Smartphone Android', preco: 1500.00, categoria: 'Eletrônicos' },
  { id: 2, nome: 'Fone de Ouvido Bluetooth', preco: 250.00, categoria: 'Acessórios' },
  { id: 3, nome: 'Carregador Rápido USB-C', preco: 120.00, categoria: 'Acessórios' }
];

// Rota de Health Check
app.get('/health', (_req, res) => {
  res.status(200).json({ status: 'ok' });
});

// Nova rota GET /produtos
app.get('/produtos', (_req, res) => {
  res.status(200).json(produtos);
});

module.exports = app;
```

3. Reiniciar a API no Terminal B:
```bash
npm start
```

4. **Validar a rota no terminal:**
   - **No Git Bash:**
     ```bash
     curl http://localhost:3000/produtos
     ```
   - **No PowerShell:**
     ```powershell
     Invoke-RestMethod http://localhost:3000/produtos
     ```

---

### Bloco 2 - Habilitar HttpClient no Mobile e Criar Serviço de Produto

1. No **Terminal A (Mobile)**, garantir a execução:
```bash
cd projetos/ionic_projeto
npm run start
```

2. **Editar o arquivo `src/main.ts` do projeto mobile e registrar o `provideHttpClient()` nos providers globais:**

```typescript
import { bootstrapApplication } from '@angular/platform-browser';
import { RouteReuseStrategy, provideRouter, withPreloading, PreloadAllModules } from '@angular/router';
import { IonicRouteStrategy, provideIonicAngular } from '@ionic/angular/standalone';
import { provideHttpClient } from '@angular/common/http'; // Importação do provedor HTTP

import { routes } from './app/app.routes';
import { AppComponent } from './app/app.component';

bootstrapApplication(AppComponent, {
  providers: [
    { provide: RouteReuseStrategy, useClass: IonicRouteStrategy },
    provideIonicAngular(),
    provideRouter(routes, withPreloading(PreloadAllModules)),
    provideHttpClient() // Registra o serviço HTTP no Angular Standalone
  ],
});
```

3. No **Terminal C (Git Bash)**, gerar o serviço de produtos no mobile:
```bash
cd projetos/ionic_projeto
ng g s services/produto
```

4. **Editar o arquivo `src/app/services/produto.service.ts` para realizar a requisição HTTP GET:**

```typescript
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

// Modelo da entidade Produto
export interface Produto {
  id: number;
  nome: string;
  preco: number;
  categoria: string;
}

@Injectable({
  providedIn: 'root'
})
export class ProdutoService {
  // Endereço da API backend Node/Express
  private apiUrl = 'http://localhost:3000/produtos';

  // Injeção do HttpClient no construtor
  constructor(private http: HttpClient) { }

  // Método que consome a API REST e retorna um Observable tipado com a lista de produtos
  listarProdutos(): Observable<Produto[]> {
    return this.http.get<Produto[]>(this.apiUrl);
  }
}
```
> 📌 **Por que tipar com `Observable<Produto[]>`?**  
> O `HttpClient` do Angular utiliza RxJS. Tipar a chamada com `<Produto[]>` avisa ao TypeScript exatamente qual será o formato da resposta JSON, oferecendo autocomplete e segurança de dados no código.

5. **Validar:** Salve o arquivo e certifique-se de que não existem erros de compilação.

---

### Bloco 3 - Consumo HTTP e Exibição de Lista Dinâmica na Interface

1. No **Terminal C (Git Bash)**, gerar a página de produtos no mobile:
```bash
cd projetos/ionic_projeto
ng g c pages/produtos --type=page --standalone
```

2. **Adicionar a rota em `src/app/app.routes.ts`:**
```typescript
{
  path: 'produtos',
  loadComponent: () => import('./pages/produtos/produtos.page').then(m => m.ProdutosPage)
}
```

3. **Editar o arquivo TypeScript (`src/app/pages/produtos/produtos.page.ts`):**

```typescript
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { 
  IonContent, 
  IonHeader, 
  IonTitle, 
  IonToolbar, 
  IonList, 
  IonItem, 
  IonLabel, 
  IonBadge, 
  IonSpinner 
} from '@ionic/angular/standalone';
import { ProdutoService, Produto } from '../../services/produto.service';

@Component({
  selector: 'app-produtos',
  templateUrl: './produtos.page.html',
  styleUrls: ['./produtos.page.scss'],
  standalone: true,
  imports: [
    CommonModule, 
    IonContent, 
    IonHeader, 
    IonTitle, 
    IonToolbar, 
    IonList, 
    IonItem, 
    IonLabel, 
    IonBadge, 
    IonSpinner
  ]
})
export class ProdutosPage implements OnInit {
  produtos: Produto[] = [];
  carregando: boolean = true;

  constructor(private produtoService: ProdutoService) { }

  ngOnInit() {
    this.carregarProdutos();
  }

  // Realiza a chamada HTTP e atualiza o estado da tela
  carregarProdutos() {
    this.carregando = true;
    this.produtoService.listarProdutos().subscribe({
      next: (dados) => {
        this.produtos = dados;
        this.carregando = false;
      },
      error: (erro) => {
        console.error('Erro ao buscar produtos da API:', erro);
        this.carregando = false;
      }
    });
  }
}
```

4. **Editar o HTML (`src/app/pages/produtos/produtos.page.html`):**

```html
<ion-header [translucent]="true">
  <ion-toolbar color="primary">
    <ion-title>Catálogo de Produtos</ion-title>
  </ion-toolbar>
</ion-header>

<ion-content class="ion-padding">
  <!-- Spinner exibido enquanto aguarda a API -->
  <div *ngIf="carregando" class="ion-text-center ion-padding">
    <ion-spinner name="crescent"></ion-spinner>
    <p>Carregando produtos da API...</p>
  </div>

  <!-- Lista dinâmica de produtos retornados da API Node -->
  <ion-list *ngIf="!carregando">
    <ion-item *ngFor="let item of produtos">
      <ion-label>
        <h2>{{ item.nome }}</h2>
        <p>Categoria: {{ item.categoria }}</p>
      </ion-label>
      <ion-badge slot="end" color="success">R$ {{ item.preco.toFixed(2) }}</ion-badge>
    </ion-item>
  </ion-list>
</ion-content>
```

5. **Validar no navegador:** Acesse `http://localhost:8100/produtos` e veja os dados da API sendo renderizados dinamicamente na lista Ionic.

---

### Bloco 4 - Validação da Integração Frontend + Backend

1. Confirmar que os 3 itens exibidos no celular/navegador vêm da resposta em JSON da API.
2. Adicionar temporariamente um 4º item no array em `src/app.js` da API e recarregar a página no navegador para confirmar a sincronia.
3. Desligar a API (Ctrl+C no Terminal B) e atualizar o app para observar o log de tratamento no bloco `error` da requisição HTTP.

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

3. **Teste de Integração API + Mobile:**
   - Acessar `http://localhost:8100/produtos` no navegador.

---

## ✅ Saída Esperada ao Final da Aula

- API Node/Express disponibilizando o endpoint `/produtos` em JSON.
- Provedor `provideHttpClient()` ativado no `main.ts` do projeto Ionic.
- Serviço `ProdutoService` efetuando chamadas `http.get<Produto[]>()`.
- Tela de catálogo consumindo o backend e renderizando listas dinâmicas com `<ion-list>` e `<ion-item>`.

---

**De onde viemos:**  
Retomamos os aprendizados de 'Arquitetura da Aplicação', consolidando os fundamentos necessários para avançar com segurança.

**Para onde vamos:**  
A partir desta base, avançaremos para 'Consumo de APIs REST e Tratamento de Erros - Parte 2', ampliando complexidade, autonomia e capacidade de aplicação prática.
