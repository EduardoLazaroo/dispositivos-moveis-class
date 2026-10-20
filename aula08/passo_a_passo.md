# Passo a Passo — Aula 08: Arquitetura da Aplicação e Serviços Reativos

**Disciplina:** Desenvolvimento de Aplicativos Móveis  
**Tema:** Arquitetura da Aplicação e Serviços Reativos  
---

> [!NOTE]
> **Objetivo Operacional:** Apresentar e implementar a organização arquitetural da aplicação mobile separando responsabilidades entre Páginas, Componentes e Serviços, utilizando injeção de dependência do Angular (`@Injectable`) e gerenciando o estado reativo de dados com RxJS (`BehaviorSubject`).

> [!TIP]
> 💡 **Analogia Didática da Aula:** Um serviço Angular (`@Injectable`) é como a central de dados de uma empresa: em vez de cada funcionário (página) guardar suas próprias planilhas separadas, todos se conectam à mesma central para ler e atualizar as informações em tempo real.  
> 📌 **Dica Prática:** Utilize `providedIn: 'root'` no decorator `@Injectable()` para que o serviço seja criado como um *Singleton* (instância única) compartilhado por todo o aplicativo.

## 📁 Padrão de Caminhos e Organização
- Pasta base da turma: `projetos`
- Projeto Mobile: `projetos/ionic_projeto`
- Projeto API: `projetos/mobile_api`

> [!IMPORTANT]
> - Manter os 3 terminais ativos durante o desenvolvimento:
>   - **Terminal A:** Mobile (`cd projetos/ionic_projeto` -> `npm run start`)
>   - **Terminal B:** API (`cd projetos/mobile_api` -> `npm start`)
>   - **Terminal C:** CLI do Ionic para geração de serviços
> - Criar a pasta `src/app/services` para centralizar a regra de negócio e comunicação fora das telas HTML/TS.

---

## ⏱️ Roteiro Completo de Atividades (4 Horas)

### Bloco 1 - Criação do Serviço da Aplicação (@Injectable)

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

3. No **Terminal C (Git Bash)**, gerar a pasta e o serviço `usuario`:
```bash
cd projetos/ionic_projeto
ng g s services/usuario
```
> 💡 **O que o comando faz:**  
> O `ng g s services/usuario` gera o arquivo `src/app/services/usuario.service.ts`, configurado com a anotação `@Injectable({ providedIn: 'root' })`.

4. **Editar o arquivo `src/app/services/usuario.service.ts` implementando o estado reativo com `BehaviorSubject`:**

```typescript
import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';

// Interface do modelo de dados de perfil
export interface PerfilUsuario {
  id: number;
  nome: string;
  email: string;
  perfil: string;
}

@Injectable({
  providedIn: 'root' // Disponibiliza a mesma instância do serviço para toda a aplicação
})
export class UsuarioService {
  
  // Estado inicial armazenado no BehaviorSubject
  private usuarioSubject = new BehaviorSubject<PerfilUsuario | null>({
    id: 1,
    nome: 'Usuário Aluno',
    email: 'aluno@faculdade.edu.br',
    perfil: 'Desenvolvedor'
  });

  // Exposição do estado como um Observable público para leitura
  public usuario$: Observable<PerfilUsuario | null> = this.usuarioSubject.asObservable();

  constructor() { }

  // Retorna o valor síncrono atual do estado
  obterUsuarioAtual(): PerfilUsuario | null {
    return this.usuarioSubject.getValue();
  }

  // Atualiza o estado e notifica automaticamente todos os inscritos (Subscribers)
  atualizarNome(novoNome: string) {
    const usuarioAtual = this.usuarioSubject.getValue();
    if (usuarioAtual) {
      const usuarioAtualizado = { ...usuarioAtual, nome: novoNome };
      this.usuarioSubject.next(usuarioAtualizado); // Emite o novo estado
    }
  }
}
```
> 📌 **Entendendo o `BehaviorSubject`:**  
> O `BehaviorSubject` guarda o último valor emitido. Sempre que uma tela se inscreve (`subscribe`) nele, ela recebe imediatamente o estado atual e continuará recebendo atualizações automaticamente sempre que o método `.next()` for chamado.

5. **Validar:** Salve o arquivo e certifique-se de que não existem erros de compilação.

---

### Bloco 2 - Injeção do Serviço na Página de Perfil

1. **Abrir o arquivo TypeScript (`src/app/pages/perfil/perfil.page.ts`) e injetar o `UsuarioService`:**

```typescript
import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
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
  IonLabel, 
  IonInput, 
  IonButton 
} from '@ionic/angular/standalone';
import { UsuarioService, PerfilUsuario } from '../../services/usuario.service';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-perfil',
  templateUrl: './perfil.page.html',
  styleUrls: ['./perfil.page.scss'],
  standalone: true,
  imports: [
    CommonModule, 
    FormsModule, 
    IonContent, 
    IonHeader, 
    IonTitle, 
    IonToolbar, 
    IonCard, 
    IonCardHeader, 
    IonCardTitle, 
    IonCardContent, 
    IonItem, 
    IonLabel, 
    IonInput, 
    IonButton
  ]
})
export class PerfilPage implements OnInit, OnDestroy {
  usuario: PerfilUsuario | null = null;
  novoNome: string = '';
  private inscricao: Subscription = new Subscription();

  // Injeção de dependência do serviço no construtor
  constructor(private usuarioService: UsuarioService) { }

  ngOnInit() {
    // Inscrição reativa para ouvir alterações no perfil do usuário em tempo real
    this.inscricao = this.usuarioService.usuario$.subscribe(dados => {
      this.usuario = dados;
      if (dados) {
        this.novoNome = dados.nome;
      }
    });
  }

  // Método para disparar a atualização no serviço
  salvarPerfil() {
    if (this.novoNome.trim()) {
      this.usuarioService.atualizarNome(this.novoNome);
      console.log('Perfil atualizado com sucesso no serviço reativo!');
    }
  }

  // Boa prática: Cancelar a inscrição ao destruir o componente para evitar vazamento de memória
  ngOnDestroy() {
    this.inscricao.unsubscribe();
  }
}
```

2. **Validar:** Salve o arquivo e certifique-se de que a inscrição (`subscribe`) e o cancelamento (`unsubscribe`) estão implementados.

---

### Bloco 3 - HTML da Página de Perfil e Exibição Reativa entre Telas

1. **Editar o arquivo HTML (`src/app/pages/perfil/perfil.page.html`):**

```html
<ion-header [translucent]="true">
  <ion-toolbar color="primary">
    <ion-title>Meu Perfil</ion-title>
  </ion-toolbar>
</ion-header>

<ion-content class="ion-padding">
  <ion-card *ngIf="usuario">
    <ion-card-header>
      <ion-card-title>{{ usuario.nome }}</ion-card-title>
    </ion-card-header>

    <ion-card-content>
      <ion-item lines="full">
        <ion-label>
          <h3>E-mail</h3>
          <p>{{ usuario.email }}</p>
        </ion-label>
      </ion-item>

      <ion-item lines="full">
        <ion-label>
          <h3>Perfil de Acesso</h3>
          <p>{{ usuario.perfil }}</p>
        </ion-label>
      </ion-item>

      <!-- Edição do Nome no padrão Ionic 7+ -->
      <ion-item lines="full" class="ion-margin-top">
        <ion-input label="Alterar Nome" labelPlacement="stacked" type="text" [(ngModel)]="novoNome"></ion-input>
      </ion-item>

      <ion-button expand="block" color="primary" class="ion-margin-top" (click)="salvarPerfil()">
        Salvar Alterações
      </ion-button>
    </ion-card-content>
  </ion-card>
</ion-content>
```

2. **Validar a reatividade no navegador:**
   - Altere o nome na página de Perfil e clique em "Salvar Alterações".
   - Navegue para a página de Início e observe como os dados são compartilhados e sincronizados via serviço!

---

### Bloco 4 - Auditoria de Arquitetura e Testes Integrados

1. **Verificar a organização das pastas do projeto mobile:**
   - `src/app/components/` (componentes visuais reutilizáveis)
   - `src/app/pages/` (páginas da aplicação)
   - `src/app/services/` (serviços e regras de negócio)

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

3. **Teste Reativo:**
   - Alterar dados no perfil e observar a atualização automática via RxJS nas demais telas.

---

## ✅ Saída Esperada ao Final da Aula

- Serviço `UsuarioService` criado em `src/app/services/` com o decorator `@Injectable`.
- Estado reativo gerenciado com `BehaviorSubject` e `Observable` do RxJS.
- Injeção de dependência aplicada na página de Perfil.
- Sincronização automática de dados entre telas sem acoplamento direto.

---

**De onde viemos:**  
Retomamos os aprendizados de 'Navegação entre Telas - Parte 2', consolidando os fundamentos necessários para avançar com segurança.

**Para onde vamos:**  
A partir desta base, avançaremos para 'Consumo de APIs REST e Tratamento de Erros - Parte 1', ampliando complexidade, autonomia e capacidade de aplicação prática.
