# Passo a Passo — Aula 13: Autenticação e Emissão de JWT - Parte 1

**Disciplina:** Desenvolvimento de Aplicativos Móveis  
**Tema:** Autenticação e Emissão de JWT - Parte 1  
---

> [!NOTE]
> **Objetivo Operacional:** Implementar o backend de autenticação com emissão de Tokens JWT no Node/Express e integrar a tela de login do aplicativo mobile para autenticar credenciais, validar respostas e armazenar o token de sessão com segurança no dispositivo.

> [!TIP]
> 💡 **Analogia Didática da Aula:** Um Token JWT é como uma pulseira VIP de festival: após validar seu ingresso no portão (login), você recebe a pulseira (JWT). Para entrar nas atrações (rotas protegidas), você mostra a pulseira sem precisar comprovar sua identidade a cada segundo.  
> 📌 **Dica Prática:** Armazene o token de sessão usando o `StorageService` logo após a resposta bem-sucedida do endpoint de `/login`.

## 📁 Padrão de Caminhos e Organização
- Pasta base da turma: `projetos`
- Projeto Mobile: `projetos/ionic_projeto` (ou `projeto_mobile`)
- Projeto API: `projetos/mobile_api` (ou `agenda-mobile-api`)

> [!IMPORTANT]
> - Manter os 3 terminais ativos durante o desenvolvimento:
>   - **Terminal A:** Mobile (`cd projetos/ionic_projeto` -> `npm run start`)
>   - **Terminal B:** API (`cd projetos/mobile_api` -> `npm start`)
>   - **Terminal C:** CLI do Ionic
> - Garantir a instalação e utilização dos pacotes `jsonwebtoken` e `cors` no backend da API Node/Express.

---

## ⏱️ Roteiro Completo de Atividades (4 Horas)

### Bloco 1 - Criação do Endpoint /login com JWT na API Node/Express

1. No **Terminal B (API)**, acessar a pasta do servidor:
```bash
cd projetos/mobile_api
```

2. **Atualizar o arquivo `src/app.js` sem remover os endpoints de produtos criados nas Aulas 09 e 10. Adicione a importação, a chave secreta e a rota abaixo ao arquivo existente:**

```javascript
// Biblioteca que cria e verifica tokens JWT no servidor.
const jwt = require('jsonwebtoken');

// Esta chave assina o token: somente o servidor deve conhecê-la.
// Em um projeto real, guarde-a em uma variável de ambiente, nunca no código versionado.
const CHAVE_SECRETA = 'minha_chave_secreta_faculdade_2026';

// POST recebe dados no corpo da requisição; neste caso, e-mail e senha do formulário.
app.post('/login', (req, res) => {
  // Desestruturação: extrai as propriedades enviadas em req.body.
  const { email, senha } = req.body;

  // Credenciais fixas apenas para a demonstração. Em produção, consulte o banco de dados
  // e compare a senha usando hash (por exemplo, bcrypt).
  if (email === 'aluno@faculdade.edu.br' && senha === '123456') {
    // O payload contém dados de identificação. Nunca coloque a senha dentro do token.
    const token = jwt.sign(
      // sub (subject) identifica o usuário dono deste token.
      { sub: 1, email: email, nome: 'Aluno Exemplo' },
      CHAVE_SECRETA,
      // Após duas horas, o token expira e uma nova autenticação será necessária.
      { expiresIn: '2h' }
    );

    // 200 significa que o login foi processado com sucesso.
    return res.status(200).json({
      mensagem: 'Login realizado com sucesso!',
      token: token,
      usuario: { id: 1, nome: 'Aluno Exemplo', email: email }
    });
  }

  // 401 informa que o cliente não apresentou credenciais válidas.
  return res.status(401).json({ erro: 'Credenciais inválidas!' });
});
```
> 📌 **O que é (e o que não é) um JWT:**  
> O token possui dados codificados e uma assinatura que o servidor consegue verificar. Ele não é uma senha e seu conteúdo não deve guardar informações sigilosas, pois o payload pode ser decodificado. A segurança vem da assinatura feita com a chave secreta e da validação dessa assinatura nas rotas protegidas.

> 📌 **Por que usar `concatMap` no login?**  
> `StorageService.salvar()` retorna uma `Promise`. `concatMap` converte as duas gravações em uma etapa do fluxo RxJS e espera sua conclusão. Portanto, o callback `next` da página somente é executado depois que o token e os dados do usuário foram persistidos.

> [!IMPORTANT]
> Mantenha no mesmo arquivo as rotas `/health`, `GET /produtos`, `POST /produtos` e `DELETE /produtos/:id`. Esta aula acrescenta autenticação; ela não substitui o catálogo criado anteriormente.

3. Reiniciar a API no Terminal B:
```bash
npm start
```

4. **Validar o endpoint `/login` via terminal:**
   - **No Git Bash:**
     ```bash
     curl -X POST http://localhost:3000/login -H "Content-Type: application/json" -d '{"email":"aluno@faculdade.edu.br","senha":"123456"}'
     ```
   - **No PowerShell:**
     ```powershell
     Invoke-RestMethod -Uri http://localhost:3000/login -Method POST -ContentType "application/json" -Body '{"email":"aluno@faculdade.edu.br","senha":"123456"}'
     ```

---

### Bloco 2 - Criação do Serviço AuthService no Projeto Mobile

1. No **Terminal C (Git Bash)**, gerar o serviço de autenticação no mobile:
```bash
cd projetos/ionic_projeto
ng g s services/auth
```

2. **Editar o arquivo `src/app/services/auth.service.ts` implementando chamada HTTP POST e salvamento do Token:**

```typescript
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
// Observable representa a resposta HTTP; from() transforma uma Promise em Observable.
import { Observable, from } from 'rxjs';
// concatMap aguarda uma etapa assíncrona; map devolve a resposta original após essa etapa.
import { concatMap, map } from 'rxjs/operators';
import { StorageService } from './storage.service';

// Contrato TypeScript para a resposta bem-sucedida recebida de POST /login.
export interface RespostaLogin {
  token: string;
  usuario: {
    id: number;
    nome: string;
    email: string;
  };
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  // URL do endpoint responsável por validar as credenciais.
  private apiUrl = 'http://localhost:3000/login';

  constructor(
    // HttpClient envia a requisição HTTP para a API.
    private http: HttpClient,
    // StorageService mantém token e dados do usuário mesmo após fechar o app.
    private storage: StorageService
  ) { }

  // Envia um objeto com email e senha no corpo da requisição POST.
  login(email: string, senha: string): Observable<RespostaLogin> {
    return this.http.post<RespostaLogin>(this.apiUrl, { email, senha }).pipe(
      // concatMap aguarda o salvamento antes de liberar a resposta para a página.
      concatMap((resposta) =>
        from(Promise.all([
          // A resposta só chega aqui quando a API retorna sucesso (HTTP 2xx).
          this.storage.salvar('token_jwt', resposta.token),
          // Também persistimos dados úteis para exibir o usuário logado nas próximas telas.
          this.storage.salvar('usuario_logado', resposta.usuario)
        ])).pipe(
          // Após salvar as duas chaves, devolvemos a resposta original ao subscribe().
          map(() => resposta)
        )
      )
    );
  }

  // Promise<string | null>: retorna null quando ainda não existe sessão salva.
  async obterToken(): Promise<string | null> {
    return await this.storage.obter<string>('token_jwt');
  }

  // !! converte o token (string ou null) em true ou false.
  // A validação da assinatura e expiração será aprofundada na próxima aula.
  async estaAutenticado(): Promise<boolean> {
    const token = await this.obterToken();
    return !!token;
  }

  // Logout remove as duas chaves para que o app não reutilize a sessão anterior.
  async logout(): Promise<void> {
    await this.storage.remover('token_jwt');
    await this.storage.remover('usuario_logado');
  }
}
```

3. **Validar:** Salve o arquivo e certifique-se de que não existem erros no terminal.

---

### Bloco 3 - Integração do AuthService na Página de Login

1. **Editar o arquivo TypeScript da tela de login (`src/app/pages/login/login.page.ts`):**

```typescript
import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
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
  IonCardSubtitle,
  IonCardContent, 
  IonItem, 
  IonInput, 
  IonButton, 
  IonSpinner 
} from '@ionic/angular/standalone';
import { ToastController } from '@ionic/angular/standalone';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.page.html',
  styleUrls: ['./login.page.scss'],
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
    IonCardSubtitle,
    IonCardContent, 
    IonItem, 
    IonInput, 
    IonButton, 
    IonSpinner
  ]
})
export class LoginPage implements OnInit {
  // Valores iniciais apenas para facilitar os testes com as credenciais simuladas.
  email: string = 'aluno@faculdade.edu.br';
  senha: string = '123456';
  // Controla o spinner e impede cliques repetidos enquanto a API responde.
  carregando: boolean = false;

  constructor(
    // Serviço que envia as credenciais e salva a sessão após o sucesso.
    private authService: AuthService,
    // Router navega entre páginas sem recarregar todo o aplicativo.
    private router: Router,
    // ToastController cria mensagens rápidas na parte inferior da tela.
    private toastCtrl: ToastController
  ) { }

  // Mantido para atender à interface OnInit; a tela não precisa de carga inicial extra.
  ngOnInit() { }

  // Navega para uma rota já cadastrada em app.routes.ts.
  irParaCadastro() {
    this.router.navigate(['/cadastro']);
  }

  // subscribe inicia a requisição HTTP retornada pelo Observable de login().
  executarLogin() {
    // A interface muda imediatamente para indicar que a requisição está em andamento.
    this.carregando = true;
    this.authService.login(this.email, this.senha).subscribe({
      next: async () => {
        // A API aceitou as credenciais e o AuthService armazenou os dados da sessão.
        this.carregando = false;
        const toast = await this.toastCtrl.create({ 
          message: 'Login realizado com sucesso!', 
          duration: 2000, 
          color: 'success' 
        });
        toast.present();
        // Só navegamos para a área interna após receber uma resposta de sucesso.
        this.router.navigate(['/tabs/inicio']);
      },
      error: async (err) => {
        // Erros HTTP, como 401, chegam neste callback.
        this.carregando = false;
        const toast = await this.toastCtrl.create({ 
          message: err.error?.erro || 'Credenciais inválidas!', 
          duration: 3000, 
          color: 'danger' 
        });
        toast.present();
      }
    });
  }
}
```

2. **Editar o arquivo HTML (`src/app/pages/login/login.page.html`) vinculando os campos com `[(ngModel)]` e conectando o botão ao `executarLogin()`:**

```html
<!-- O cabeçalho permanece visível enquanto o conteúdo da tela pode rolar. -->
<ion-header [translucent]="true">
  <ion-toolbar color="primary">
    <ion-title>Portal Mobile</ion-title>
  </ion-toolbar>
</ion-header>

<!-- Conteúdo Principal Rolável -->
<ion-content class="ion-padding custom-background">
  <div class="login-container">
    
    <!-- Cartão de formulário principal -->
    <ion-card class="login-card">
      <ion-card-header>
        <ion-card-title>Acesso ao Sistema</ion-card-title>
        <ion-card-subtitle>Informe suas credenciais para continuar</ion-card-subtitle>
      </ion-card-header>

      <ion-card-content>
        <!-- [(ngModel)] mantém o campo e a variável email sincronizados nos dois sentidos. -->
        <ion-item lines="full" class="custom-item">
          <ion-input label="E-mail" labelPlacement="stacked" type="email" [(ngModel)]="email" placeholder="seu.email@exemplo.com"></ion-input>
        </ion-item>

        <!-- type="password" mascara o texto na tela; isso não substitui a segurança no servidor. -->
        <ion-item lines="full" class="custom-item">
          <ion-input label="Senha" labelPlacement="stacked" type="password" [(ngModel)]="senha" placeholder="Digite sua senha"></ion-input>
        </ion-item>

        <!-- (click) chama o método TypeScript; [disabled] bloqueia um segundo envio enquanto carregando for true. -->
        <ion-button expand="block" color="primary" class="ion-margin-top" (click)="executarLogin()" [disabled]="carregando">
          <!-- *ngIf adiciona o spinner somente durante a requisição. -->
          <ion-spinner *ngIf="carregando" name="crescent"></ion-spinner>
          <!-- O texto "Entrar" volta a aparecer quando carregando for false. -->
          <span *ngIf="!carregando">Entrar</span>
        </ion-button>

        <!-- Botão de cadastro -->
        <ion-button expand="block" fill="outline" color="secondary" class="ion-margin-top" (click)="irParaCadastro()">
          Criar Conta
        </ion-button>
      </ion-card-content>
    </ion-card>

  </div>
</ion-content>
```

3. **Validar no navegador:** Acesse `http://localhost:8100/login`.

---

### Bloco 4 - Testes de Autenticação e Armazenamento do Token

1. Digitar o e-mail e senha corretos e clicar em "Entrar".
2. Confirmar a exibição do Toast verde de sucesso e o redirecionamento automático para a rota `/tabs/inicio`.
3. Abrir o DevTools (`F12` -> Application -> Storage) e validar se a chave `token_jwt` está salva com a string codificada do JWT.
4. Testar o envio de senha incorreta para verificar o bloqueio com Toast vermelho.

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

3. **Teste de Autenticação:**
   - Testar o envio de credenciais válidas e inválidas na tela de login.

---

## ✅ Saída Esperada ao Final da Aula

- Endpoint `POST /login` na API Express gerando Tokens JWT válidos.
- Serviço `AuthService` efetuando login e salvando token no `StorageService`.
- Formulário de login integrado respondendo em tempo real.
- Token JWT persistido localmente e navegação para a área interna funcional.

---

**De onde viemos:**  
Retomamos os aprendizados de 'Persistência Local - Parte 2', consolidando os fundamentos necessários para avançar com segurança.

**Para onde vamos:**  
A partir desta base, avançaremos para 'Autenticação e Proteção de Rotas - Parte 2', ampliando complexidade, autonomia e capacidade de aplicação prática.
