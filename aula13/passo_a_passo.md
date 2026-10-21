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
- Projeto Mobile: `projetos/ionic_projeto`
- Projeto API: `projetos/mobile_api`

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

2. **Editar o arquivo `src/app.js` adicionando a rota POST `/login` com geração de Token JWT:**

```javascript
const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken'); // Pacote para geração e validação de JWT

const app = express();
app.use(cors());
app.use(express.json());

// Segredo do servidor para assinar o token
const CHAVE_SECRETA = 'minha_chave_secreta_faculdade_2026';

app.get('/health', (_req, res) => res.status(200).json({ status: 'ok' }));

// Rota de Autenticação (Login)
app.post('/login', (req, res) => {
  const { email, senha } = req.body;

  // Validação de credenciais simuladas
  if (email === 'aluno@faculdade.edu.br' && senha === '123456') {
    // Emissão do Token JWT assinado com expiração de 2 horas
    const token = jwt.sign(
      { sub: 1, email: email, nome: 'Aluno Exemplo' },
      CHAVE_SECRETA,
      { expiresIn: '2h' }
    );

    return res.status(200).json({
      mensagem: 'Login realizado com sucesso!',
      token: token,
      usuario: { id: 1, nome: 'Aluno Exemplo', email: email }
    });
  }

  // Resposta para credenciais inválidas (Status 401 Unauthorized)
  return res.status(401).json({ erro: 'Credenciais inválidas!' });
});

module.exports = app;
```

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
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { StorageService } from './storage.service';

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
  private apiUrl = 'http://localhost:3000/login';

  constructor(
    private http: HttpClient,
    private storage: StorageService
  ) { }

  // Envia as credenciais e salva o token e dados do usuário no storage em caso de sucesso
  login(email: string, senha: string): Observable<RespostaLogin> {
    return this.http.post<RespostaLogin>(this.apiUrl, { email, senha }).pipe(
      tap(async (resposta) => {
        await this.storage.salvar('token_jwt', resposta.token);
        await this.storage.salvar('usuario_logado', resposta.usuario);
      })
    );
  }

  // Recupera o token salvo no dispositivo
  async obterToken(): Promise<string | null> {
    return await this.storage.obter<string>('token_jwt');
  }

  // Verifica se existe um token ativo salvo
  async estaAutenticado(): Promise<boolean> {
    const token = await this.obterToken();
    return !!token;
  }

  // Remove os dados da sessão (Logout)
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
    IonCardContent, 
    IonItem, 
    IonInput, 
    IonButton, 
    IonSpinner
  ]
})
export class LoginPage implements OnInit {
  email: string = 'aluno@faculdade.edu.br';
  senha: string = '123456';
  carregando: boolean = false;

  constructor(
    private authService: AuthService,
    private router: Router,
    private toastCtrl: ToastController
  ) { }

  ngOnInit() { }

  // Dispara a tentativa de login na API
  executarLogin() {
    this.carregando = true;
    this.authService.login(this.email, this.senha).subscribe({
      next: async () => {
        this.carregando = false;
        const toast = await this.toastCtrl.create({ 
          message: 'Login realizado com sucesso!', 
          duration: 2000, 
          color: 'success' 
        });
        toast.present();
        // Redireciona para o painel principal após a autenticação
        this.router.navigate(['/tabs/inicio']);
      },
      error: async (err) => {
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

2. **Validar no navegador:** Acesse `http://localhost:8100/login`.

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
