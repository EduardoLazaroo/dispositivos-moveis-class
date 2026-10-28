# Passo a Passo — Aula 12: Persistência Local - Parte 2 (Estratégia Offline & Cache)

**Disciplina:** Desenvolvimento de Aplicativos Móveis  
**Tema:** Persistência Local - Parte 2 (Estratégia Offline & Cache)  
---

> [!NOTE]
> **Objetivo Operacional:** Desenvolver o mecanismo de sincronização e cache offline entre o armazenamento local do dispositivo (`StorageService`) e a API backend Node/Express, garantindo a exibição de dados mesmo quando a rede estiver indisponível e gerenciando filas de pendências offline.

> [!TIP]
> 💡 **Analogia Didática da Aula:** O cache offline com RxJS funciona como a cópia salva de um livro que você baixa no celular: se você estiver sem sinal no metrô, continua lendo o livro baixado (cache). Quando a internet volta, o app atualiza o livro silenciosamente em segundo plano.  
> 📌 **Dica Prática:** Combine os operadores `tap` (para salvar em cache) e `catchError` (para recuperar dados salvos em caso de queda de rede) no seu `ProdutoService`.

## 📁 Padrão de Caminhos e Organização
- Pasta base da turma: `projetos`
- Projeto Mobile: `projetos/ionic_projeto` (ou `projeto_mobile`)
- Projeto API: `projetos/mobile_api` (ou `agenda-mobile-api`)

> [!IMPORTANT]
> - Manter os 3 terminais ativos durante o desenvolvimento:
>   - **Terminal A:** Mobile (`cd projetos/ionic_projeto` -> `npm run start`)
>   - **Terminal B:** API (`cd projetos/mobile_api` -> `npm start`)
>   - **Terminal C:** CLI do Ionic
> - Integrar a combinação de `StorageService` e `ProdutoService` para gerenciar a resiliência offline de produtos.

---

## ⏱️ Roteiro Completo de Atividades (4 Horas)

### Bloco 1 - Implementação do Cache Local de Produtos no Serviço

1. No **Terminal A (Mobile)**, garantir a execução do servidor web:
```bash
cd projetos/ionic_projeto
npm run start
```

2. **Editar o arquivo do serviço (`src/app/services/produto.service.ts`) implementando o método com resiliência de cache (`listarComCache`):**

```typescript
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
// Observable representa um resultado que chegará no futuro.
// from() converte uma Promise em Observable para podermos usar operadores RxJS.
import { Observable, from } from 'rxjs';
// tap executa efeitos paralelos; catchError trata falhas; map transforma valores emitidos.
import { tap, catchError, map } from 'rxjs/operators';
import { StorageService } from './storage.service';

// Este contrato define a estrutura esperada para cada produto vindo da API e do cache.
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
  // Endereço da API que fornece a lista atualizada de produtos.
  private apiUrl = 'http://localhost:3000/produtos';
  // Chave fixa usada para salvar e recuperar a mesma lista no armazenamento local.
  private CACHE_KEY = 'produtos_cache';

  constructor(
    // HttpClient realiza as requisições HTTP para o backend.
    private http: HttpClient,
    // StorageService grava e lê dados persistentes no dispositivo.
    private storage: StorageService
  ) { }

  // Requisição comum, sem fallback de cache.
  listarProdutos(): Observable<Produto[]> {
    return this.http.get<Produto[]>(this.apiUrl);
  }

  // Partial<Produto> permite enviar apenas os campos necessários ao cadastrar.
  criarProduto(produto: Partial<Produto>): Observable<Produto> {
    return this.http.post<Produto>(this.apiUrl, produto);
  }

  // O id é acrescentado ao final da URL para excluir um produto específico.
  excluirProduto(id: number): Observable<any> {
    return this.http.delete(`${this.apiUrl}/${id}`);
  }

  // pipe() monta uma sequência de etapas para tratar a resposta da API.
  listarComCache(): Observable<Produto[]> {
    return this.http.get<Produto[]>(this.apiUrl).pipe(
      tap((produtos) => {
        // Salva uma cópia atualizada, sem modificar a lista que seguirá para a tela.
        // void deixa explícito que não aguardamos a Promise de gravação nesta etapa.
        void this.storage.salvar(this.CACHE_KEY, produtos);
      }),
      catchError(() => {
        // Se a requisição HTTP falhar, não encerramos o fluxo com erro.
        console.warn('Rede indisponível! Recuperando dados do cache local...');
        // obter() retorna Promise; from() a transforma em Observable compatível com RxJS.
        return from(this.storage.obter<Produto[]>(this.CACHE_KEY)).pipe(
          // Caso seja o primeiro acesso offline e não exista cache, exibe uma lista vazia.
          map((dadosLocais) => dadosLocais || [])
        );
      })
    );
  }
}
```
> 📌 **Entendendo os Operadores RxJS (`tap` e `catchError`):**
> - **`tap`**: Executa um efeito colateral sem alterar a resposta do Observable. Aqui usamos para salvar a cópia local.
> - **`catchError`**: Intercepta falhas HTTP (ex: servidor offline). Em vez de travar a tela, ele intercepta a exceção e retorna a lista de cache previamente salva.
> - **`from`**: Converte a `Promise` retornada pelo `StorageService` em um `Observable`, permitindo continuar usando `pipe`.
> - **`map`**: Ajusta o dado emitido. Neste caso, converte `null` (cache inexistente) em `[]` (lista vazia).

> 📌 **Fluxo do cache:** com internet, a API responde e `tap` atualiza a cópia local. Sem internet, `catchError` substitui a resposta da API pelo conteúdo salvo na chave `produtos_cache`. Assim, a página sempre recebe uma lista de `Produto`, mesmo no primeiro acesso offline.

3. **Validar:** Salve o arquivo e verifique que o código compila sem erros no terminal.

---

### Bloco 2 - Criação do Gerenciador de Pendências Offline

1. **Editar o serviço de armazenamento (`src/app/services/storage.service.ts`) adicionando o controle de fila de pendências:**

```typescript
// Adicionar dentro da classe StorageService:

// Cada pendência pode representar uma ação que será enviada ao servidor depois.
// Exemplo: { tipo: 'criar-produto', dados: novoProduto }.
async adicionarPendencia(item: any): Promise<void> {
  // Se a fila ainda não existir, começa com um array vazio.
  const pendencias = (await this.obter<any[]>('pendencias_offline')) || [];
  // push adiciona a nova ação ao final, preservando as pendências já armazenadas.
  pendencias.push(item);
  // Salva o array inteiro novamente porque o storage grava um valor por chave.
  await this.salvar('pendencias_offline', pendencias);
}

// Retorna uma lista pronta para percorrer, mesmo que não haja itens pendentes.
async obterPendencias(): Promise<any[]> {
  return (await this.obter<any[]>('pendencias_offline')) || [];
}

// Execute somente depois de confirmar que todas as ações foram sincronizadas.
async limparPendencias(): Promise<void> {
  await this.remover('pendencias_offline');
}
```

2. **Validar:** Salve o arquivo e certifique-se de que os métodos de pendências estão disponíveis.

---

### Bloco 3 - Atualização da Interface para Indicar Modo Cache/Offline

1. **Editar a página de produtos (`src/app/pages/produtos/produtos.page.ts`) integrando o método `listarComCache()` e mantendo suporte ao Refresher e Exclusão:**

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
    IonRefresher, 
    IonRefresherContent
  ]
})
export class ProdutosPage implements OnInit {
  // A lista começa vazia e é preenchida pela API ou pelo cache local.
  produtos: Produto[] = [];

  constructor(
    // Serviço que busca produtos e aplica a estratégia de cache.
    private produtoService: ProdutoService,
    // Controladores do Ionic usados para mostrar mensagens e confirmações.
    private toastCtrl: ToastController,
    private alertCtrl: AlertController
  ) { }

  // ngOnInit é chamado quando a página é criada; aqui iniciamos a primeira carga.
  ngOnInit() {
    this.carregarProdutos();
  }

  // event é opcional: ele existe quando o usuário puxa a tela para atualizar.
  carregarProdutos(event?: any) {
    this.produtoService.listarComCache().subscribe({
      next: (dados) => {
        // "dados" pode vir da API ou do cache, mas sempre tem o formato Produto[].
        this.produtos = dados;
        // complete() encerra a animação do refresher, quando ela foi acionada.
        if (event) event.target.complete();
      },
      error: async () => {
        // Este caso cobre uma falha que não conseguiu ser resolvida pelo cache.
        if (event) event.target.complete();
        const toast = await this.toastCtrl.create({
          message: 'Modo offline: exibindo produtos em cache.',
          duration: 3000,
          color: 'warning'
        });
        toast.present();
      }
    });
  }

  // Exibe uma confirmação antes de executar uma ação que não pode ser desfeita.
  async confirmarExclusao(id: number) {
    const alert = await this.alertCtrl.create({
      header: 'Confirmar Exclusão',
      message: 'Deseja realmente remover este produto?',
      buttons: [
        { text: 'Cancelar', role: 'cancel' },
        {
          text: 'Excluir',
          role: 'destructive',
          // handler só é chamado se o usuário confirmar a exclusão.
          handler: () => this.remover(id)
        }
      ]
    });
    await alert.present();
  }

  // Após excluir no servidor, recarregamos a lista para refletir a alteração na tela.
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

2. **Validar no navegador:** Acesse `http://localhost:8100/produtos` e confirme que a lista é renderizada normalmente e salvou a cópia local no storage.

---

### Bloco 4 - Testes de Desconexão e Sincronização de Cache

1. **Testar em modo Online:** Acesse `http://localhost:8100/produtos` com a API rodando no Terminal B.
2. **Interromper a API:** No **Terminal B**, pressione `Ctrl + C` para desligar o servidor Node/Express.
3. **Testar a resiliência Offline:** Atualize a página do navegador (`F5`) ou feche o navegador e reabra o aplicativo.
4. **Verificar o resultado:** A lista de produtos continuará sendo exibida normalmente na tela, lendo os dados salvos no cache do dispositivo!
5. **Religar a API:** Execute `npm start` no Terminal B. Requisões subsequentes atualizarão a cópia local silenciosamente.

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

3. **Teste de Sincronismo e Cache:**
   - Desligar/religar a API no Terminal B para validar a resiliência offline do aplicativo.

---

## ✅ Saída Esperada ao Final da Aula

- Estratégia de cache offline com RxJS (`pipe`, `tap`, `catchError`) no `ProdutoService`.
- Armazenamento em segundo plano da lista de produtos na chave `produtos_cache`.
- Exibição de dados garantida na interface mesmo quando o servidor backend estiver offline.
- Fila de gerenciamento de pendências offline funcional em `StorageService`.

---

**De onde viemos:**  
Retomamos os aprendizados de 'Persistência Local - Parte 1', consolidando os fundamentos necessários para avançar com segurança.

**Para onde vamos:**  
A partir desta base, avançaremos para 'Recursos Nativos do Dispositivo - Parte 1', ampliando complexidade, autonomia e capacidade de aplicação prática.
