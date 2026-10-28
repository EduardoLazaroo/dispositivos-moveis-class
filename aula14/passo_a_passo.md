# Passo a Passo — Aula 14: Autenticação e Proteção de Rotas - Parte 2

**Disciplina:** Desenvolvimento de Aplicativos Móveis  
**Tema:** Autenticação e Proteção de Rotas - Parte 2  
---

> [!NOTE]
> **Objetivo Operacional:** Proteger rotas no aplicativo mobile com Guards funcionais do Angular (`CanActivateFn`), criar um HTTP Interceptor funcional para anexar automaticamente o cabeçalho `Authorization: Bearer <TOKEN>` nas requisições da API e implementar o fluxo completo de Logout.

> [!TIP]
> 💡 **Analogia Didática da Aula:** O Guard de Rota (`authGuard`) é como a portaria da empresa (impede que visitantes entrem em áreas restritas sem crachá), enquanto o HTTP Interceptor (`jwtInterceptor`) é o carimbo automático no verso de todas as cartas enviadas pelo correio.  
> 📌 **Dica Prática:** Registre o Interceptor no arquivo `src/main.ts` utilizando a função `provideHttpClient(withInterceptors([jwtInterceptor]))`.

## 📁 Padrão de Caminhos e Organização
- Pasta base da turma: `projetos`
- Projeto Mobile: `projetos/ionic_projeto` (ou `projeto_mobile`)
- Projeto API: `projetos/mobile_api` (ou `agenda-mobile-api`)

> [!IMPORTANT]
> - Manter os 3 terminais ativos durante o desenvolvimento:
>   - **Terminal A:** Mobile (`cd projetos/ionic_projeto` -> `npm run start`)
>   - **Terminal B:** API (`cd projetos/mobile_api` -> `npm start`)
>   - **Terminal C:** CLI do Angular/Ionic
> - Injetar o `AuthService` dentro do Guard funcional utilizando a função `inject()`.

---

## ⏱️ Roteiro Completo de Atividades (4 Horas)

### Bloco 1 - Criação do Guard de Proteção de Rotas (authGuard)

1. No **Terminal C (Git Bash)**, gerar o Guard funcional no projeto mobile:
```bash
cd projetos/ionic_projeto
npx ng generate guard guards/auth --functional
```

2. **Editar o arquivo `src/app/guards/auth.guard.ts` implementando a verificação de autenticação:**

```typescript
import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

// Guard funcional CanActivateFn
export const authGuard: CanActivateFn = async (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);

  // Verifica se o usuário possui um token válido no storage
  const autenticado = await authService.estaAutenticado();

  if (autenticado) {
    return true; // Permite o acesso à rota protegida
  }

  // Redireciona para o login caso não esteja autenticado
  router.navigate(['/login']);
  return false; // Bloqueia o acesso
};
```
> 📌 **O que é um Guard Funcional (`CanActivateFn`)?**  
> É o padrão moderno do Angular que elimina a necessidade de criar classes com `@Injectable`. Ele usa a função `inject()` para resolver dependências e retorna um booleano ou uma Promise/Observable de permissão.

3. **Atualizar o arquivo de rotas (`src/app/app.routes.ts`) preservando todas as rotas já criadas e aplicando o `authGuard` às áreas internas existentes:**

```typescript
import { Routes } from '@angular/router';
import { authGuard } from './guards/auth.guard';

export const routes: Routes = [
  {
    path: '',
    redirectTo: 'tabs/inicio',
    pathMatch: 'full',
  },
  {
    path: 'login',
    loadComponent: () => import('./pages/login/login.page').then( m => m.LoginPage)
  },
  {
    path: 'cadastro',
    loadComponent: () => import('./pages/cadastro/cadastro.page').then( m => m.CadastroPage)
  },
  {
    path: 'detalhes/:id',
    loadComponent: () => import('./pages/detalhes/detalhes.page').then( m => m.DetalhesPage),
    canActivate: [authGuard]
  },
  {
    path: 'tabs',
    loadComponent: () => import('./pages/tabs/tabs.page').then( m => m.TabsPage),
    canActivate: [authGuard], // Protege todas as rotas filhas do 'tabs'
    children: [
      {
        path: 'inicio',
        loadComponent: () => import('./pages/inicio/inicio.page').then( m => m.InicioPage)
      },
      {
        path: 'perfil',
        loadComponent: () => import('./pages/perfil/perfil.page').then( m => m.PerfilPage)
      },
      {
        path: '',
        redirectTo: 'inicio',
        pathMatch: 'full'
      }
    ]
  },
  {
    path: 'produtos',
    loadComponent: () => import('./pages/produtos/produtos.page').then( m => m.ProdutosPage),
    canActivate: [authGuard]
  },
  {
    path: 'configuracoes',
    loadComponent: () => import('./pages/configuracoes/configuracoes.page').then( m => m.ConfiguracoesPage),
    canActivate: [authGuard]
  }
];
```
> [!IMPORTANT]
> Use este arquivo como base acumulada. Nas aulas seguintes, acrescente novas rotas protegidas ao mesmo array e preserve as rotas mostradas acima.

4. **Validar no navegador:** Tente acessar diretamente `http://localhost:8100/tabs/inicio` sem ter realizado login e confirme se a aplicação redireciona automaticamente para `/login`.

---

### Bloco 2 - Criação do Interceptor HTTP para Envio do Token JWT

1. No **Terminal C (Git Bash)**, gerar o HTTP Interceptor no projeto mobile:
```bash
cd projetos/ionic_projeto
npx ng generate interceptor interceptors/jwt --functional
```

2. **Editar o arquivo `src/app/interceptors/jwt.interceptor.ts`:**

```typescript
import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { from } from 'rxjs';
import { switchMap } from 'rxjs/operators';
import { AuthService } from '../services/auth.service';

export const jwtInterceptor: HttpInterceptorFn = (req, next) => {
  const authService = inject(AuthService);

  // Converte a Promise do token em um Observable para clonar a requisição HTTP
  return from(authService.obterToken()).pipe(
    switchMap(token => {
      if (token) {
        // Clona a requisição adicionando o cabeçalho Authorization Bearer Token
        const requisicaoClonada = req.clone({
          setHeaders: {
            Authorization: `Bearer ${token}`
          }
        });
        return next(requisicaoClonada);
      }
      return next(req);
    })
  );
};
```
> [!IMPORTANT]
> Confirme que a propriedade do interceptor esteja exatamente como `Authorization: 'Bearer ' + token`. Ela deve usar o token recuperado do `AuthService` e não pode conter asteriscos, texto de exemplo ou valor fixo.

3. **Registrar o interceptor no arquivo `src/main.ts`:**

```typescript
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { jwtInterceptor } from './app/interceptors/jwt.interceptor';

// No array de providers do bootstrapApplication:
/*
bootstrapApplication(AppComponent, {
  providers: [
    ...
    provideHttpClient(withInterceptors([jwtInterceptor]))
  ],
});
*/
```

4. **Validar:** Salve o arquivo e certifique-se de que não existem erros de compilação.

---

### Bloco 3 - Middleware de Validação JWT na API Express

1. No **Terminal B (API)**, acessar a pasta da API:
```bash
cd projetos/mobile_api
```

2. **Editar o arquivo `src/app.js` adicionando um middleware para verificar o token JWT em rotas protegidas:**

```javascript
const jwt = require('jsonwebtoken');

// Middleware de verificação de token JWT
function autenticarToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Extrai a string do "Bearer <TOKEN>"

  if (!token) {
    return res.status(401).json({ erro: 'Acesso negado: Token não fornecido!' });
  }

  jwt.verify(token, CHAVE_SECRETA, (err, usuario) => {
    if (err) {
      return res.status(403).json({ erro: 'Token inválido ou expirado!' });
    }
    req.usuario = usuario;
    next();
  });
}

// Endpoint protegido da API
app.get('/perfil-protegido', autenticarToken, (req, res) => {
  res.status(200).json({ mensagem: 'Dados confidenciais acessados!', usuario: req.usuario });
});
```

3. Reiniciar a API no Terminal B:
```bash
npm start
```

4. **Validar no terminal a tentativa de acesso sem token (deve retornar HTTP 401 Unauthorized):**
   - **No Git Bash:**
     ```bash
     curl http://localhost:3000/perfil-protegido
     ```
   - **No PowerShell:**
     ```powershell
     Invoke-RestMethod http://localhost:3000/perfil-protegido -Method GET
     ```

---

### Bloco 4 - Implementação do Fluxo de Logout e Validação Integrada

1. **Editar a página de perfil (`src/app/pages/perfil/perfil.page.ts`) injetando o `AuthService` e o `Router`:**

```typescript
// Adicionar as importações no topo:
import { AuthService } from '../../services/auth.service';
import { Router } from '@angular/router';

// Injetar no construtor da classe PerfilPage:
constructor(
  private usuarioService: UsuarioService,
  private authService: AuthService,
  private router: Router
) { }

// Adicionar o método de logout:
async realizarLogout() {
  await this.authService.logout();
  this.router.navigate(['/login']);
}
```

2. **Editar o HTML da página de perfil (`src/app/pages/perfil/perfil.page.html`) adicionando o botão de Logout:**

```html
<!-- Adicionar dentro do ion-card-content, logo abaixo do botão "Salvar Alterações": -->
<ion-button expand="block" color="danger" fill="outline" class="ion-margin-top" (click)="realizarLogout()">
  Sair da Conta (Logout)
</ion-button>
```

3. **Testar o fluxo completo no navegador:**
   - Faça login na aplicação.
   - Abra a aba de inspeção de rede (`F12` -> Network) e faça uma requisição para a API.
   - Verifique que o cabeçalho `Authorization: Bearer <TOKEN>` é enviado automaticamente pelo Interceptor.
   - Na página de Perfil, clique em "Sair da Conta (Logout)" e tente acessar `/tabs/inicio` diretamente na barra de endereços para confirmar o bloqueio pelo Guard.

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

3. **Teste de Segurança:**
   - Testar o bloqueio de rotas protegidas antes e depois do login.

---

## ✅ Saída Esperada ao Final da Aula

- `authGuard` funcional impedindo acesso não autenticado à rota `/tabs`.
- `jwtInterceptor` injetando o cabeçalho `Bearer Token` em todas as requisições HTTP do mobile.
- Middleware `autenticarToken` na API Express rejeitando chamadas não autorizadas.
- Função de Logout encerrando a sessão e retornando à página de Login.

---

**De onde viemos:**  
Retomamos os aprendizados de 'Autenticação e Emissão de JWT - Parte 1', consolidando os fundamentos necessários para avançar com segurança.

**Para onde vamos:**  
A partir desta base, avançaremos para 'Recursos Nativos do Dispositivo - Parte 1', ampliando complexidade, autonomia e capacidade de aplicação prática.
