# Passo a Passo — Aula 18: Projeto Integrador - Parte 2 (CRUD Completo e Filtros Dinâmicos)

**Disciplina:** Desenvolvimento de Aplicativos Móveis  
**Tema:** Projeto Integrador - Parte 2 (CRUD Completo e Filtros Dinâmicos)  
---

> [!NOTE]
> **Objetivo Operacional:** Evoluir o aplicativo do Projeto Integrador adicionando operações completas de atualização de status e remoção de registros (PUT/DELETE), filtros de busca em tempo real com `<ion-searchbar>` e tratamento de dados com confirmação modal (`AlertController`).

> [!TIP]
> 💡 **Analogia Didática da Aula:** Um filtro de busca com `ion-searchbar` é como a lupa de um detetive em um arquivo: conforme você digita o nome do documento, a prateleira oculta os itens irrelevantes e destaca apenas o registro desejado.  
> 📌 **Dica Prática:** Utilize o método `.filter()` do JavaScript no TypeScript para realizar pesquisas instantâneas sem sobrecarregar o servidor com novas chamadas HTTP.

## 📁 Padrão de Caminhos e Organização
- Pasta base da turma: `projetos`
- Projeto Mobile: `projetos/ionic_projeto` (ou `projeto_mobile`)
- Projeto API: `projetos/mobile_api` (ou `agenda-mobile-api`)

> [!IMPORTANT]
> - Manter os 3 terminais ativos durante o desenvolvimento:
>   - **Terminal A:** Mobile (`cd projetos/ionic_projeto` -> `npm run start`)
>   - **Terminal B:** API (`cd projetos/mobile_api` -> `npm start`)
>   - **Terminal C:** CLI do Ionic
> - Garantir que as alterações de status e exclusão do Projeto Integrador respondam com feedbacks visuais de Toast no frontend.

---

## ⏱️ Roteiro Completo de Atividades (4 Horas)

### Bloco 1 - Implementação de PUT e DELETE para o Projeto Integrador na API

1. No **Terminal B (API)**, acessar a pasta do backend:
```bash
cd projetos/mobile_api
```

2. **Editar o arquivo `src/app.js` adicionando as rotas PUT e DELETE para a entidade de chamados:**

```javascript
// Adicionar ao src/app.js:

// Rota PUT /chamados/:id (Atualizar status)
app.put('/chamados/:id', (req, res) => {
  const id = Number(req.params.id);
  const { status } = req.body;
  const item = chamados.find(c => c.id === id);

  if (!item) return res.status(404).json({ erro: 'Chamado não encontrado!' });

  if (status) item.status = status;
  res.status(200).json(item);
});

// Rota DELETE /chamados/:id (Remover)
app.delete('/chamados/:id', (req, res) => {
  const id = Number(req.params.id);
  chamados = chamados.filter(c => c.id !== id);
  res.status(200).json({ mensagem: 'Chamado removido com sucesso!' });
});
```

3. Reiniciar a API no Terminal B:
```bash
npm start
```

4. **Validar os novos endpoints via terminal:**
   - **No Git Bash:**
     ```bash
     curl -X PUT http://localhost:3000/chamados/1 -H "Content-Type: application/json" -d '{"status":"Concluído"}'
     ```
   - **No PowerShell:**
     ```powershell
     Invoke-RestMethod -Uri http://localhost:3000/chamados/1 -Method PUT -ContentType "application/json" -Body '{"status":"Concluído"}'
     ```

---

### Bloco 2 - Atualização do ChamadoService com Métodos PUT e DELETE

1. **Editar o serviço no projeto mobile (`src/app/services/chamado.service.ts`):**

```typescript
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

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

  listar(): Observable<Chamado[]> {
    return this.http.get<Chamado[]>(this.apiUrl);
  }

  criar(chamado: Partial<Chamado>): Observable<Chamado> {
    return this.http.post<Chamado>(this.apiUrl, chamado);
  }

  // Atualiza o status do chamado via PUT
  atualizarStatus(id: number, status: string): Observable<Chamado> {
    return this.http.put<Chamado>(`${this.apiUrl}/${id}`, { status });
  }

  // Exclui o chamado via DELETE
  excluir(id: number): Observable<any> {
    return this.http.delete(`${this.apiUrl}/${id}`);
  }
}
```

2. **Validar:** Salve o arquivo e confirme a integridade do código.

---

### Bloco 3 - Adição de Filtros (ion-searchbar) e Ações de Status na Interface

1. **Editar o arquivo TypeScript (`src/app/pages/chamados/chamados.page.ts`):**

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
  IonCardContent, 
  IonSearchbar 
} from '@ionic/angular/standalone';
import { AlertController, ToastController } from '@ionic/angular/standalone';
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
    IonCardContent, 
    IonSearchbar
  ]
})
export class ChamadosPage implements OnInit {
  lista: Chamado[] = [];
  listaFiltrada: Chamado[] = [];
  termoBusca: string = '';
  novoTitulo: string = '';
  novaDescricao: string = '';
  novaPrioridade: string = 'Média';

  constructor(
    private chamadoService: ChamadoService,
    private alertCtrl: AlertController,
    private toastCtrl: ToastController
  ) { }

  ngOnInit() {
    this.carregar();
  }

  carregar() {
    this.chamadoService.listar().subscribe(dados => {
      this.lista = dados;
      this.filtrar(); // Aplica o filtro atual após recarregar
    });
  }

  // Cadastro de novo chamado
  salvar() {
    if (!this.novoTitulo.trim()) return;

    this.chamadoService.criar({
      titulo: this.novoTitulo,
      descricao: this.novaDescricao,
      prioridade: this.novaPrioridade
    }).subscribe(() => {
      this.novoTitulo = '';
      this.novaDescricao = '';
      this.carregar();
    });
  }

  // Filtra dinamicamente a lista local por título ou descrição
  filtrar() {
    if (!this.termoBusca.trim()) {
      this.listaFiltrada = this.lista;
    } else {
      this.listaFiltrada = this.lista.filter(c => 
        c.titulo.toLowerCase().includes(this.termoBusca.toLowerCase()) ||
        c.descricao.toLowerCase().includes(this.termoBusca.toLowerCase())
      );
    }
  }

  // Altera o status entre Pendente e Concluído
  async alterarStatus(id: number, statusAtual: string) {
    const novoStatus = statusAtual === 'Pendente' ? 'Concluído' : 'Pendente';
    this.chamadoService.atualizarStatus(id, novoStatus).subscribe(async () => {
      const toast = await this.toastCtrl.create({ 
        message: 'Status atualizado com sucesso!', 
        duration: 2000, 
        color: 'success' 
      });
      toast.present();
      this.carregar();
    });
  }

  // Exclui com modal de confirmação
  async remover(id: number) {
    const alert = await this.alertCtrl.create({
      header: 'Confirmar Exclusão',
      message: 'Deseja excluir este chamado do projeto?',
      buttons: [
        { text: 'Cancelar', role: 'cancel' },
        {
          text: 'Excluir',
          role: 'destructive',
          handler: () => {
            this.chamadoService.excluir(id).subscribe(() => this.carregar());
          }
        }
      ]
    });
    await alert.present();
  }
}
```

2. **Editar o HTML (`src/app/pages/chamados/chamados.page.html`) mantendo o formulário de cadastro e adicionando a barra de busca `<ion-searchbar>`:**

```html
<ion-header [translucent]="true">
  <ion-toolbar color="primary">
    <ion-title>Projeto Integrador - Chamados</ion-title>
  </ion-toolbar>
  
  <!-- Barra de Pesquisa em Tempo Real -->
  <ion-toolbar color="primary">
    <ion-searchbar [(ngModel)]="termoBusca" (ionInput)="filtrar()" placeholder="Pesquisar chamados..."></ion-searchbar>
  </ion-toolbar>
</ion-header>

<ion-content class="ion-padding">
  <!-- Formulário para Criar Novos Chamados -->
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

      <ion-item lines="full">
        <ion-select label="Prioridade" labelPlacement="stacked" [(ngModel)]="novaPrioridade">
          <ion-select-option value="Baixa">Baixa</ion-select-option>
          <ion-select-option value="Média">Média</ion-select-option>
          <ion-select-option value="Alta">Alta</ion-select-option>
        </ion-select>
      </ion-item>

      <ion-button expand="block" color="primary" class="ion-margin-top" (click)="salvar()">
        Abrir Chamado
      </ion-button>
    </ion-card-content>
  </ion-card>

  <!-- Lista Filtrada com Ações de Status e Remoção -->
  <h3 class="ion-margin-top">Chamados Cadastrados</h3>
  <ion-list>
    <ion-item *ngFor="let c of listaFiltrada">
      <ion-label>
        <h2>{{ c.titulo }}</h2>
        <p>{{ c.descricao }}</p>
      </ion-label>

      <!-- Botão de alterar status -->
      <ion-button slot="end" fill="clear" color="primary" (click)="alterarStatus(c.id, c.status)">
        {{ c.status }}
      </ion-button>

      <!-- Botão de excluir -->
      <ion-button slot="end" fill="clear" color="danger" (click)="remover(c.id)">
        Excluir
      </ion-button>
    </ion-item>
  </ion-list>
</ion-content>
```

3. **Validar no navegador:** Acesse `http://localhost:8100/chamados` e teste a busca em tempo real e a exclusão de itens.

---

### Bloco 4 - Testes de Integração Completa CRUD do Projeto

1. Digite termos na barra de busca e confirme que o filtro oculta os registros não correspondentes.
2. Clique no botão de status para alterar a pendência e verifique a atualização persistida na API.
3. Teste a exclusão com confirmação visual em alerta.

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

3. **Teste CRUD Completo:**
   - Acessar `http://localhost:8100/chamados` e testar cadastro, busca, edição de status e exclusão.

---

## ✅ Saída Esperada ao Final da Aula

- Endpoints `PUT` e `DELETE` no backend Node.js operacionais.
- Métodos `atualizarStatus()` e `excluir()` no `ChamadoService`.
- Barra de pesquisa dinâmica com `<ion-searchbar>` e filtro no frontend.
- CRUD completo funcional do Projeto Integrador.

---

**De onde viemos:**  
Retomamos os aprendizados de 'Projeto Integrador - Parte 1', consolidando os fundamentos necessários para avançar com segurança.

**Para onde vamos:**  
A partir desta base, avançaremos para 'Projeto Integrador - Parte 3', ampliando complexidade, autonomia e capacidade de aplicação prática.
