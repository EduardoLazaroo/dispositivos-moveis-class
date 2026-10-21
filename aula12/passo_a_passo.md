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
- Projeto Mobile: `projetos/ionic_projeto`
- Projeto API: `projetos/mobile_api`

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
import { Observable, from, of } from 'rxjs';
import { tap, catchError } from 'rxjs/operators';
import { StorageService } from './storage.service';

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
  private CACHE_KEY = 'produtos_cache';

  constructor(
    private http: HttpClient,
    private storage: StorageService
  ) { }

  // Busca dados na API. Se obtiver sucesso, salva no cache local.
  // Caso ocorra falha de rede (catchError), restaura os dados do storage local!
  listarComCache(): Observable<Produto[]> {
    return this.http.get<Produto[]>(this.apiUrl).pipe(
      tap(async (produtos) => {
        // Salva uma cópia dos produtos atualizados no disco do dispositivo
        await this.storage.salvar(this.CACHE_KEY, produtos);
      }),
      catchError(async () => {
        console.warn('Rede indisponível! Recuperando dados do cache local...');
        const dadosLocais = await this.storage.obter<Produto[]>(this.CACHE_KEY);
        return dadosLocais || [];
      }) as any
    );
  }
}
```
> 📌 **Entendendo os Operadores RxJS (`tap` e `catchError`):**
> - **`tap`**: Executa um efeito colateral sem alterar a resposta do Observable. Aqui usarmos para salvar a cópia local.
> - **`catchError`**: Intercepta falhas HTTP (ex: servidor offline). Em vez de travar a tela, ele intercepta a exceção e retorna a lista de cache previamente salva.

3. **Validar:** Salve o arquivo e verifique que o código compila sem erros no terminal.

---

### Bloco 2 - Criação do Gerenciador de Pendências Offline

1. **Editar o serviço de armazenamento (`src/app/services/storage.service.ts`) adicionando o controle de fila de pendências:**

```typescript
// Adicionar dentro da classe StorageService:

// Adiciona uma ação pendente à fila local offline
async adicionarPendencia(item: any): Promise<void> {
  const pendencias = (await this.obter<any[]>('pendencias_offline')) || [];
  pendencias.push(item);
  await this.salvar('pendencias_offline', pendencias);
}

// Retorna todas as pendências aguardando sincronização
async obterPendencias(): Promise<any[]> {
  return (await this.obter<any[]>('pendencias_offline')) || [];
}

// Limpa a fila de pendências após sincronizar com o servidor
async limparPendencias(): Promise<void> {
  await this.remover('pendencias_offline');
}
```

2. **Validar:** Salve o arquivo e certifique-se de que os métodos de pendências estão disponíveis.

---

### Bloco 3 - Atualização da Interface para Indicar Modo Cache/Offline

1. **Editar a página de produtos (`src/app/pages/produtos/produtos.page.ts`) para chamar o método reativo de cache:**

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
  IonButton 
} from '@ionic/angular/standalone';
import { ProdutoService, Produto } from '../../services/produto.service';
import { ToastController } from '@ionic/angular/standalone';

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
    IonButton
  ]
})
export class ProdutosPage implements OnInit {
  produtos: Produto[] = [];

  constructor(
    private produtoService: ProdutoService,
    private toastCtrl: ToastController
  ) { }

  ngOnInit() {
    this.carregar();
  }

  carregar() {
    this.produtoService.listarComCache().subscribe(dados => {
      this.produtos = dados;
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
