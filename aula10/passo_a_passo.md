# Passo a Passo — Aula 10: Consumo de APIs REST e Tratamento de Erros - Parte 2

**Disciplina:** Desenvolvimento de Aplicativos Móveis  
**Tema:** Consumo de APIs REST e Tratamento de Erros - Parte 2  
---

> [!NOTE]
> **Objetivo Operacional:** Aprimorar o consumo de APIs REST implementando operações de escrita e remoção (POST/DELETE), adicionando componentes visuais de feedback (`ToastController`, `AlertController`), funcionalidade de puxar para atualizar (`<ion-refresher>`) e tratamento robusto de exceções e erros HTTP.

> [!TIP]
> 💡 **Analogia Didática da Aula:** Operações CRUD na API são como gerenciar uma caderneta: Criar (`POST`), Ler (`GET`), Atualizar (`PUT`) e Deletar (`DELETE`). A API responde com notificações instantâneas (`Toast`) confirmando o sucesso ou falha da operação.  
> 📌 **Dica Prática:** Responda com os códigos de status HTTP apropriados na API Node: `200` (Sucesso), `201` (Criado com sucesso), `400` (Dados inválidos) e `404` (Recurso não encontrado).

## 📁 Padrão de Caminhos e Organização
- Pasta base da turma: `projetos`
- Projeto Mobile: `projetos/ionic_projeto`
- Projeto API: `projetos/mobile_api`

> [!IMPORTANT]
> - Manter os 3 terminais ativos durante o desenvolvimento:
>   - **Terminal A:** Mobile (`cd projetos/ionic_projeto` -> `npm run start`)
>   - **Terminal B:** API (`cd projetos/mobile_api` -> `npm start`)
>   - **Terminal C:** CLI do Ionic
> - Injetar `ToastController` e `AlertController` no construtor da página para exibir notificações flutuantes e modais de confirmação.

---

## ⏱️ Roteiro Completo de Atividades (4 Horas)

### Bloco 1 - Adição de Endpoints POST e DELETE na API Express

1. No **Terminal B (API)**, acessar a pasta do backend:
```bash
cd projetos/mobile_api
```

2. **Editar o arquivo `src/app.js` para incluir suporte às rotas POST e DELETE:**

```javascript
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// Array mutável em memória simulando o banco de dados
let produtos = [
  { id: 1, nome: 'Smartphone Android', preco: 1500.00, categoria: 'Eletrônicos' },
  { id: 2, nome: 'Fone de Ouvido Bluetooth', preco: 250.00, categoria: 'Acessórios' }
];

app.get('/health', (_req, res) => res.status(200).json({ status: 'ok' }));
app.get('/produtos', (_req, res) => res.status(200).json(produtos));

// Rota POST /produtos (Criar)
app.post('/produtos', (req, res) => {
  const { nome, preco, categoria } = req.body;
  if (!nome || !preco) {
    return res.status(400).json({ erro: 'Nome e preço são obrigatórios!' });
  }
  const novo = { id: Date.now(), nome, preco: Number(preco), categoria: categoria || 'Geral' };
  produtos.push(novo);
  res.status(201).json(novo);
});

// Rota DELETE /produtos/:id (Remover)
app.delete('/produtos/:id', (req, res) => {
  const id = Number(req.params.id);
  produtos = produtos.filter(p => p.id !== id);
  res.status(200).json({ mensagem: 'Produto removido com sucesso!' });
});

module.exports = app;
```

3. Reiniciar a API no Terminal B:
```bash
npm start
```

4. **Validar a inclusão via requisição no terminal:**
   - **No Git Bash:**
     ```bash
     curl -X POST http://localhost:3000/produtos -H "Content-Type: application/json" -d '{"nome":"Teclado","preco":180}'
     ```
   - **No PowerShell:**
     ```powershell
     Invoke-RestMethod -Uri http://localhost:3000/produtos -Method POST -ContentType "application/json" -Body '{"nome":"Teclado","preco":180}'
     ```

---

### Bloco 2 - Atualização do ProdutoService para Operações de Escrita

1. **Editar o arquivo do serviço no projeto mobile (`src/app/services/produto.service.ts`):**

```typescript
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

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
  private apiUrl = 'http://localhost:3000/produtos';

  constructor(private http: HttpClient) { }

  listarProdutos(): Observable<Produto[]> {
    return this.http.get<Produto[]>(this.apiUrl);
  }

  // Método para criar um novo produto via POST
  criarProduto(produto: Partial<Produto>): Observable<Produto> {
    return this.http.post<Produto>(this.apiUrl, produto);
  }

  // Método para excluir um produto via DELETE
  excluirProduto(id: number): Observable<any> {
    return this.http.delete(`${this.apiUrl}/${id}`);
  }
}
```

2. **Validar:** Salve o arquivo e confirme a ausência de erros no terminal.

---

### Bloco 3 - Feedback de Usuário com Toast, Alert e Pull-to-Refresh

1. **Editar o arquivo TypeScript (`src/app/pages/produtos/produtos.page.ts`) integrando `ToastController` e `AlertController`:**

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
  IonButton, 
  IonIcon, 
  IonRefresher, 
  IonRefresherContent 
} from '@ionic/angular/standalone';
import { ToastController, AlertController } from '@ionic/angular/standalone';
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
    IonButton, 
    IonIcon, 
    IonRefresher, 
    IonRefresherContent
  ]
})
export class ProdutosPage implements OnInit {
  produtos: Produto[] = [];

  constructor(
    private produtoService: ProdutoService,
    private toastCtrl: ToastController,
    private alertCtrl: AlertController
  ) { }

  ngOnInit() {
    this.carregarProdutos();
  }

  // Carrega a lista e encerra o evento do refresher se existir
  carregarProdutos(event?: any) {
    this.produtoService.listarProdutos().subscribe({
      next: (dados) => {
        this.produtos = dados;
        if (event) event.target.complete();
      },
      error: async () => {
        if (event) event.target.complete();
        const toast = await this.toastCtrl.create({
          message: 'Falha ao conectar com o servidor da API!',
          duration: 3000,
          color: 'danger'
        });
        toast.present();
      }
    });
  }

  // Exibe o modal de confirmação de exclusão
  async confirmarExclusao(id: number) {
    const alert = await this.alertCtrl.create({
      header: 'Confirmar Exclusão',
      message: 'Deseja realmente remover este produto?',
      buttons: [
        { text: 'Cancelar', role: 'cancel' },
        {
          text: 'Excluir',
          role: 'destructive',
          handler: () => this.remover(id)
        }
      ]
    });
    await alert.present();
  }

  // Executa a remoção e exibe notificação de sucesso
  remover(id: number) {
    this.produtoService.excluirProduto(id).subscribe({
      next: async () => {
        const toast = await this.toastCtrl.create({ 
          message: 'Produto excluído com sucesso!', 
          duration: 2000, 
          color: 'success' 
        });
        toast.present();
        this.carregarProdutos();
      }
    });
  }
}
```

2. **Editar o HTML (`src/app/pages/produtos/produtos.page.html`) incluindo `<ion-refresher>` e o botão de exclusão:**

```html
<ion-header [translucent]="true">
  <ion-toolbar color="primary">
    <ion-title>Gestão de Produtos</ion-title>
  </ion-toolbar>
</ion-header>

<ion-content class="ion-padding">
  <!-- Puxar para atualizar (Pull-to-Refresh) -->
  <ion-refresher slot="fixed" (ionRefresh)="carregarProdutos($event)">
    <ion-refresher-content></ion-refresher-content>
  </ion-refresher>

  <ion-list>
    <ion-item *ngFor="let item of produtos">
      <ion-label>
        <h2>{{ item.nome }}</h2>
        <p>R$ {{ item.preco.toFixed(2) }}</p>
      </ion-label>
      <ion-button slot="end" color="danger" fill="clear" (click)="confirmarExclusao(item.id)">
        Excluir
      </ion-button>
    </ion-item>
  </ion-list>
</ion-content>
```

3. **Validar no navegador:**
   - Acesse `http://localhost:8100/produtos`.
   - Clique em "Excluir" em um produto e verifique a abertura do alerta de confirmação.
   - Confirme a exclusão e veja o Toast verde de sucesso.

---

### Bloco 4 - Testes de Erros e Puxar para Atualizar (Pull-to-Refresh)

1. Testar o evento de deslizar para baixo (Pull-to-Refresh) na tela móvel.
2. Desligar o servidor Node no Terminal B (`Ctrl+C`) e puxar para atualizar na tela do celular/navegador para visualizar o Toast vermelho de erro de conexão.
3. Ligar novamente a API e confirmar a recuperação normal do sistema.

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

3. **Teste do CRUD:**
   - Testar o ciclo de leitura, inserção, exclusão e refresher no aplicativo.

---

## ✅ Saída Esperada ao Final da Aula

- API Express com suporte a endpoints `POST` e `DELETE`.
- Métodos `criarProduto()` e `excluirProduto()` no `ProdutoService`.
- Confirmação de exclusão com modal `<ion-alert>`.
- Notificações de feedback flutuantes com `<ion-toast>`.
- Atualização da lista via gesto de deslizar com `<ion-refresher>`.

---

**De onde viemos:**  
Retomamos os aprendizados de 'Consumo de APIs REST e Tratamento de Erros - Parte 1', consolidando os fundamentos necessários para avançar com segurança.

**Para onde vamos:**  
A partir desta base, avançaremos para 'Persistência Local - Parte 1', ampliando complexidade, autonomia e capacidade de aplicação prática.
