# Passo a Passo — Aula 17: Projeto Integrador - Parte 1 (Arquitetura e Cadastro Base)

**Disciplina:** Desenvolvimento de Aplicativos Móveis  
**Tema:** Projeto Integrador - Parte 1 (Arquitetura e Cadastro Base)  
---

> [!NOTE]
> **Objetivo Operacional:** Iniciar o desenvolvimento prático do Projeto Integrador da disciplina, integrando a estrutura de dados no backend Node/Express, a API REST completa de gerenciamento da entidade de domínio (ex: Chamados/Tarefas) e a criação da interface visual de cadastro e listagem dinâmica no frontend Ionic/Angular.

> [!TIP]
> 💡 **Analogia Didática da Aula:** O Projeto Integrador é como a montagem final do veículo: nas primeiras 16 semanas fabricamos as peças separadas (telas, rotas, formulários, chamadas HTTP, storage e JWT), e agora unimos todas essas partes em um produto real pronto para uso.  
> 📌 **Dica Prática:** Reutilize os serviços `StorageService`, `AuthService` e os componentes criados nas aulas anteriores para agilizar a construção do projeto final.

## 📁 Padrão de Caminhos e Organização
- Pasta base da turma: `projetos`
- Projeto Mobile: `projetos/ionic_projeto` (ou `projeto_mobile`)
- Projeto API: `projetos/mobile_api` (ou `agenda-mobile-api`)

> [!IMPORTANT]
> - Manter os 3 terminais ativos durante o desenvolvimento:
>   - **Terminal A:** Mobile (`cd projetos/ionic_projeto` -> `npm run start`)
>   - **Terminal B:** API (`cd projetos/mobile_api` -> `npm start`)
>   - **Terminal C:** CLI do Ionic
> - O Projeto Integrador consolida todas as competências da disciplina: Interfaces, Navegação, APIs REST, Storage Local e Autenticação JWT.

---

## ⏱️ Roteiro Completo de Atividades (4 Horas)

### Bloco 1 - Definição do Escopo e Estrutura da API do Projeto Integrador

1. No **Terminal B (API)**, acessar a pasta da API:
```bash
cd projetos/mobile_api
```

2. **Atualizar o arquivo `src/app.js` configurando as rotas REST para a entidade do projeto integrador (`/chamados`) e preservando produtos, autenticação e o endpoint protegido das aulas anteriores:**

```javascript
const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');

const app = express();
app.use(cors());
app.use(express.json());

const CHAVE_SECRETA = 'minha_chave_secreta_faculdade_2026';

// Base de dados simulada em memória
let produtos = [
  { id: 1, nome: 'Smartphone Android', preco: 1500.00, categoria: 'Eletrônicos' },
  { id: 2, nome: 'Fone de Ouvido Bluetooth', preco: 250.00, categoria: 'Acessórios' },
  { id: 3, nome: 'Carregador Rápido USB-C', preco: 120.00, categoria: 'Acessórios' }
];

let chamados = [
  { id: 1, titulo: 'Suporte em Rede', descricao: 'Configurar roteador do prédio A', status: 'Pendente', prioridade: 'Alta' },
  { id: 2, titulo: 'Troca de Monitor', descricao: 'Substituir monitor com defeito na sala 03', status: 'Em Andamento', prioridade: 'Média' }
];

app.get('/health', (_req, res) => res.status(200).json({ status: 'ok' }));

// Rota de Autenticação JWT (mantida para suportar o fluxo completo de login)
app.post('/login', (req, res) => {
  const { email, senha } = req.body;
  if (email === 'aluno@faculdade.edu.br' && senha === '123456') {
    const token = jwt.sign(
      { sub: 1, email, nome: 'Aluno Exemplo' },
      CHAVE_SECRETA,
      { expiresIn: '2h' }
    );
    return res.status(200).json({
      mensagem: 'Login realizado com sucesso!',
      token,
      usuario: { id: 1, nome: 'Aluno Exemplo', email }
    });
  }
  return res.status(401).json({ erro: 'Credenciais inválidas!' });
});

// Rotas de Produtos (mantidas para catálogo e cache offline)
app.get('/produtos', (_req, res) => res.status(200).json(produtos));

app.post('/produtos', (req, res) => {
  const { nome, preco, categoria } = req.body;
  if (!nome || !preco) {
    return res.status(400).json({ erro: 'Nome e preço são obrigatórios!' });
  }
  const novo = {
    id: Date.now(),
    nome,
    preco: Number(preco),
    categoria: categoria || 'Geral'
  };
  produtos.push(novo);
  return res.status(201).json(novo);
});

app.delete('/produtos/:id', (req, res) => {
  const id = Number(req.params.id);
  const produtoExiste = produtos.some(produto => produto.id === id);
  if (!produtoExiste) {
    return res.status(404).json({ erro: 'Produto não encontrado!' });
  }
  produtos = produtos.filter(produto => produto.id !== id);
  return res.status(200).json({ mensagem: 'Produto removido com sucesso!' });
});

function autenticarToken(req, res, next) {
  const authHeader = req.headers.authorization;
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ erro: 'Acesso negado: token não fornecido!' });
  }

  jwt.verify(token, CHAVE_SECRETA, (erro, usuario) => {
    if (erro) {
      return res.status(403).json({ erro: 'Token inválido ou expirado!' });
    }
    req.usuario = usuario;
    return next();
  });
}

app.get('/perfil-protegido', autenticarToken, (req, res) => {
  res.status(200).json({ mensagem: 'Dados confidenciais acessados!', usuario: req.usuario });
});

// Rotas do Projeto Integrador: Chamados
app.get('/chamados', (_req, res) => res.status(200).json(chamados));

app.post('/chamados', (req, res) => {
  const { titulo, descricao, prioridade } = req.body;
  if (!titulo) return res.status(400).json({ erro: 'Título é obrigatório!' });

  const novo = {
    id: Date.now(),
    titulo,
    descricao: descricao || '',
    status: 'Pendente',
    prioridade: prioridade || 'Média'
  };
  chamados.push(novo);
  res.status(201).json(novo);
});

module.exports = app;
```

3. Reiniciar a API no Terminal B:
```bash
npm start
```

4. **Validar a rota via terminal:**
   - **No Git Bash:**
     ```bash
     curl http://localhost:3000/chamados
     ```
   - **No PowerShell:**
     ```powershell
     Invoke-RestMethod http://localhost:3000/chamados
     ```

---

### Bloco 2 - Criação do Serviço ChamadoService no Mobile

1. No **Terminal C (Git Bash)**, gerar o serviço `chamado` no mobile:
```bash
cd projetos/ionic_projeto
ng g s services/chamado
```

2. **Editar o arquivo `src/app/services/chamado.service.ts`:**

```typescript
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

// Interface da entidade do Projeto Integrador
export interface Chamado {
  id: number;
  titulo: string;
  descricao: string;
  status: string;
  prioridade: string;
}

@Injectable({
  providedIn: 'root'
})
export class ChamadoService {
  private apiUrl = 'http://localhost:3000/chamados';

  constructor(private http: HttpClient) { }

  // Busca a lista de chamados na API
  listar(): Observable<Chamado[]> {
    return this.http.get<Chamado[]>(this.apiUrl);
  }

  // Cria um novo chamado no backend
  criar(chamado: Partial<Chamado>): Observable<Chamado> {
    return this.http.post<Chamado>(this.apiUrl, chamado);
  }
}
```

3. **Validar:** Salve o arquivo e certifique-se de que não existem erros no código.

---

### Bloco 3 - Criação da Tela de Listagem e Formulário do Projeto

1. No **Terminal C (Git Bash)**, gerar a página `chamados`:
```bash
cd projetos/ionic_projeto
ng g c pages/chamados --type=page --standalone
```

2. **Adicionar a rota em `src/app/app.routes.ts`:**
```typescript
{
  path: 'chamados',
  loadComponent: () => import('./pages/chamados/chamados.page').then(m => m.ChamadosPage),
  canActivate: [authGuard]
}
```
> 📌 Importe `authGuard` de `./guards/auth.guard` no início do arquivo de rotas e acrescente este objeto ao array `routes` existente.

3. **Editar o arquivo TypeScript (`src/app/pages/chamados/chamados.page.ts`):**

```typescript
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
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
  IonInput, 
  IonSelect, 
  IonSelectOption, 
  IonCard, 
  IonCardHeader, 
  IonCardTitle, 
  IonCardContent 
} from '@ionic/angular/standalone';
import { ChamadoService, Chamado } from '../../services/chamado.service';

@Component({
  selector: 'app-chamados',
  templateUrl: './chamados.page.html',
  styleUrls: ['./chamados.page.scss'],
  standalone: true,
  imports: [
    CommonModule, 
    FormsModule, 
    IonContent, 
    IonHeader, 
    IonTitle, 
    IonToolbar, 
    IonList, 
    IonItem, 
    IonLabel, 
    IonBadge, 
    IonButton, 
    IonInput, 
    IonSelect, 
    IonSelectOption, 
    IonCard, 
    IonCardHeader, 
    IonCardTitle, 
    IonCardContent
  ]
})
export class ChamadosPage implements OnInit {
  lista: Chamado[] = [];
  novoTitulo: string = '';
  novaDescricao: string = '';
  novaPrioridade: string = 'Média';

  constructor(private chamadoService: ChamadoService) { }

  ngOnInit() {
    this.carregar();
  }

  carregar() {
    this.chamadoService.listar().subscribe(dados => this.lista = dados);
  }

  salvar() {
    if (!this.novoTitulo.trim()) return;

    this.chamadoService.criar({
      titulo: this.novoTitulo,
      descricao: this.novaDescricao,
      prioridade: this.novaPrioridade
    }).subscribe(() => {
      this.novoTitulo = '';
      this.novaDescricao = '';
      this.carregar(); // Recarrega a lista atualizada
    });
  }
}
```

4. **Editar o HTML (`src/app/pages/chamados/chamados.page.html`):**

```html
<ion-header [translucent]="true">
  <ion-toolbar color="primary">
    <ion-title>Projeto Integrador - Chamados</ion-title>
  </ion-toolbar>
</ion-header>

<ion-content class="ion-padding">
  <!-- Cartão de Formulário -->
  <ion-card>
    <ion-card-header>
      <ion-card-title>Novo Chamado</ion-card-title>
    </ion-card-header>
    <ion-card-content>
      <ion-item lines="full">
        <ion-input label="Título" labelPlacement="stacked" type="text" [(ngModel)]="novoTitulo" placeholder="Digite o título"></ion-input>
      </ion-item>
      
      <ion-item lines="full">
        <ion-input label="Descrição" labelPlacement="stacked" type="text" [(ngModel)]="novaDescricao" placeholder="Digite a descrição"></ion-input>
      </ion-item>

      <ion-button expand="block" color="primary" class="ion-margin-top" (click)="salvar()">
        Abrir Chamado
      </ion-button>
    </ion-card-content>
  </ion-card>

  <!-- Lista de Chamados Cadastrados -->
  <h3 class="ion-margin-top">Chamados Cadastrados</h3>
  <ion-list>
    <ion-item *ngFor="let c of lista">
      <ion-label>
        <h2>{{ c.titulo }}</h2>
        <p>{{ c.descricao }}</p>
      </ion-label>
      <ion-badge slot="end" color="warning">{{ c.status }}</ion-badge>
    </ion-item>
  </ion-list>
</ion-content>
```

5. **Validar no navegador:** Acesse `http://localhost:8100/chamados`.

---

### Bloco 4 - Integração Inicial e Teste do Fluxo de Cadastro

1. Preencher os campos do formulário na tela e clicar em "Abrir Chamado".
2. Confirmar que a requisição é salva na API Node e exibida imediatamente na lista dinâmica.
3. Testar a recuperação dos dados via requisição no terminal.
4. Validar o alinhamento visual e responsividade no DevTools (`Ctrl + Shift + M`).

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

3. **Teste do Projeto Integrador:**
   - Acessar `http://localhost:8100/chamados` e cadastrar novos chamados.

---

## ✅ Saída Esperada ao Final da Aula

- Entidade de domínio do Projeto Integrador configurada na API Express.
- Serviço `ChamadoService` integrado com os métodos REST `GET` e `POST`.
- Formulário de abertura de chamados e listagem dinâmica operacionais.
- Fluxo completo do projeto integrador validado do frontend ao backend.

---

**De onde viemos:**  
Retomamos os aprendizados de 'Recursos Nativos do Dispositivo - Parte 2', consolidando os fundamentos necessários para avançar com segurança.

**Para onde vamos:**  
A partir desta base, avançaremos para 'Projeto Integrador - Parte 2', ampliando complexidade, autonomia e capacidade de aplicação prática.
