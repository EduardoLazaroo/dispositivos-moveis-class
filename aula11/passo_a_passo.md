# Passo a Passo — Aula 11: Persistência Local - Parte 1

**Disciplina:** Desenvolvimento de Aplicativos Móveis  
**Tema:** Persistência Local - Parte 1  
---

> [!NOTE]
> **Objetivo Operacional:** Implementar persistência de dados local no dispositivo móvel utilizando o plugin oficial `@capacitor/preferences`, criando um serviço assíncrono de chave-valor para salvar configurações do usuário, preferências de sistema e dados offline.

> [!TIP]
> 💡 **Analogia Didática da Aula:** O `@capacitor/preferences` é como o porta-luvas do carro: você guarda lá itens práticos de uso frequente (configurações do app, e-mail lembrado, preferências de tema) que continuam intactos mesmo quando o motor (aplicativo) é desligado.  
> 📌 **Dica Prática:** Utilize `JSON.stringify()` ao salvar objetos/estruturas complexas no storage e `JSON.parse()` ao realizar a leitura.

## 📁 Padrão de Caminhos e Organização
- Pasta base da turma: `projetos`
- Projeto Mobile: `projetos/ionic_projeto` (ou `projeto_mobile`)
- Projeto API: `projetos/mobile_api` (ou `agenda-mobile-api`)

> [!IMPORTANT]
> - Manter os 3 terminais ativos durante o desenvolvimento:
>   - **Terminal A:** Mobile (`cd projetos/ionic_projeto` -> `npm run start`)
>   - **Terminal B:** API (`cd projetos/mobile_api` -> `npm start`)
>   - **Terminal C:** CLI para instalação de plugins e criação de serviços
> - Instalar o pacote oficial do Capacitor Preferences no projeto mobile: `@capacitor/preferences`.

---

## ⏱️ Roteiro Completo de Atividades (4 Horas)

### Bloco 1 - Instalação do Plugin Capacitor Preferences

1. No **Terminal C (Git Bash)**, navegar para a pasta do projeto mobile:
```bash
cd projetos/ionic_projeto
```

2. **Instalar o pacote de armazenamento local do Capacitor:**
```bash
npm install @capacitor/preferences
```

3. **Executar a sincronização das pontes nativas do Capacitor:**
```bash
npx cap sync
```
> 💡 **O que faz o `npx cap sync`?**  
> O `npx cap sync` atualiza as plataformas nativas (Android e iOS) para registrar o novo plugin instalado no projeto web/Ionic.

4. Garantir que o **Terminal A (Mobile)** continua em execução:
```bash
npm run start
```

---

### Bloco 2 - Criação do Serviço de Armazenamento Local

1. No **Terminal C (Git Bash)**, gerar o serviço `storage` no projeto mobile:
```bash
cd projetos/ionic_projeto
ng g s services/storage
```

2. **Editar o arquivo `src/app/services/storage.service.ts` implementando métodos genéricos assíncronos (`async/await`):**

```typescript
import { Injectable } from '@angular/core';
// API do Capacitor que acessa o armazenamento local do dispositivo.
import { Preferences } from '@capacitor/preferences';

@Injectable({
  // Permite injetar este serviço em qualquer página sem cadastrá-lo manualmente.
  providedIn: 'root'
})
export class StorageService {

  constructor() { }

  // A chave identifica o valor salvo; use sempre o mesmo texto para recuperá-lo depois.
  // "any" permite salvar booleanos, textos, números, objetos e arrays neste exemplo.
  async salvar(chave: string, valor: any): Promise<void> {
    await Preferences.set({
      key: chave,
      // Preferences só armazena texto; JSON transforma outros tipos em texto.
      value: JSON.stringify(valor)
    });
  }

  // <T> é um tipo genérico: quem chama o método informa o tipo esperado na leitura.
  // Exemplo: obter<boolean>('modoEscuro') retorna Promise<boolean | null>.
  async obter<T>(chave: string): Promise<T | null> {
    // Desestruturação: pega apenas a propriedade "value" retornada pelo plugin.
    const { value } = await Preferences.get({ key: chave });
    // null significa que não existe nenhum valor salvo para esta chave.
    if (value === null) return null;

    try {
      // JSON.parse desfaz o JSON criado por JSON.stringify ao salvar o dado.
      // "as T" informa ao TypeScript qual tipo esperamos receber de volta.
      return JSON.parse(value) as T;
    } catch (erro) {
      // Um valor inválido no storage não pode ser convertido de JSON para o tipo esperado.
      console.error(`Não foi possível ler a preferência "${chave}".`, erro);
      return null;
    }
  }

  // Exclui apenas o dado associado à chave recebida.
  async remover(chave: string): Promise<void> {
    await Preferences.remove({ key: chave });
  }

  // Atenção: remove todas as preferências deste aplicativo, sem pedir confirmação.
  async limparTudo(): Promise<void> {
    await Preferences.clear();
  }
}
```
> 📌 **Entendendo a assincronia (`async/await`):**  
> As operações no dispositivo móvel leem e escrevem no disco. Como o disco é mais lento que a memória RAM, todas as funções retornam `Promises` que devem ser aguardadas com a palavra-chave `await`.

> 📌 **Entendendo o `T` em `obter<T>()`:**  
> `T` é um **tipo genérico** do TypeScript. Ele não cria nem converte dados sozinho; apenas informa ao editor qual tipo esperamos após o `JSON.parse()`. Por isso, ao ler uma chave que guarda `true` ou `false`, escrevemos `obter<boolean>('modoEscuro')`; ao ler um texto, escrevemos `obter<string>('emailLembrado')`. O retorno também pode ser `null`, pois a chave pode ainda não ter sido salva.

3. **Validar:** Salve o arquivo e confirme que o código compila sem erros.

---

### Bloco 3 - Criação da Tela de Configurações com Persistência

1. No **Terminal C (Git Bash)**, gerar a página `configuracoes`:
```bash
cd projetos/ionic_projeto
ng g c pages/configuracoes --type=page --standalone
```

2. **Registrar a rota em `src/app/app.routes.ts`:**
```typescript
{
  path: 'configuracoes',
  loadComponent: () => import('./pages/configuracoes/configuracoes.page').then(m => m.ConfiguracoesPage)
}
```
> 📌 Acrescente este objeto ao array `routes` existente, mantendo as rotas de `login`, `cadastro`, `detalhes`, `tabs` e `produtos` configuradas nas aulas anteriores.

3. **Editar o arquivo TypeScript (`src/app/pages/configuracoes/configuracoes.page.ts`):**

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
  IonToggle, 
  IonInput, 
  IonButton 
} from '@ionic/angular/standalone';
import { StorageService } from '../../services/storage.service';

@Component({
  selector: 'app-configuracoes',
  templateUrl: './configuracoes.page.html',
  styleUrls: ['./configuracoes.page.scss'],
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
    IonToggle, 
    IonInput, 
    IonButton
  ]
})
export class ConfiguracoesPage implements OnInit {
  // Variáveis ligadas aos campos HTML por meio do [(ngModel)].
  modoEscuro: boolean = false;
  emailSalvo: string = '';

  // O Angular entrega automaticamente a instância do StorageService no construtor.
  constructor(private storageService: StorageService) { }

  // ngOnInit é executado quando a página é criada.
  // await garante que os valores sejam lidos antes de atualizar os campos da tela.
  async ngOnInit() {
    // Se a chave ainda não existir, obter() devolve null e usamos false como padrão.
    this.modoEscuro = (await this.storageService.obter<boolean>('modoEscuro')) || false;
    // A mesma ideia: caso não exista e-mail salvo, o campo começa vazio.
    this.emailSalvo = (await this.storageService.obter<string>('emailLembrado')) || '';
  }

  // Salva cada preferência usando uma chave fixa, que será usada novamente na leitura.
  async salvarConfiguracoes() {
    await this.storageService.salvar('modoEscuro', this.modoEscuro);
    await this.storageService.salvar('emailLembrado', this.emailSalvo);
    // Por enquanto, a confirmação aparece no Console do navegador (F12).
    console.log('Preferências salvas com sucesso no dispositivo!');
  }
}
```

4. **Editar o HTML (`src/app/pages/configuracoes/configuracoes.page.html`):**

```html
<ion-header [translucent]="true">
  <ion-toolbar color="primary">
    <ion-title>Configurações do App</ion-title>
  </ion-toolbar>
</ion-header>

<ion-content class="ion-padding">
  <ion-list>
    <!-- [(ngModel)] faz a ligação em dois sentidos:
         o valor de modoEscuro atualiza o toggle e a interação atualiza a variável. -->
    <ion-item lines="full">
      <ion-toggle [(ngModel)]="modoEscuro">Modo Escuro (Noturno)</ion-toggle>
    </ion-item>

    <!-- O mesmo [(ngModel)] mantém o conteúdo do campo sincronizado com emailSalvo. -->
    <ion-item lines="full">
      <ion-input label="Lembrar E-mail" labelPlacement="stacked" type="email" [(ngModel)]="emailSalvo" placeholder="Digite seu e-mail"></ion-input>
    </ion-item>
  </ion-list>

  <!-- (click) chama o método TypeScript somente quando o usuário pressiona o botão. -->
  <ion-button expand="block" color="primary" class="ion-margin-top" (click)="salvarConfiguracoes()">
    Salvar Preferências
  </ion-button>
</ion-content>
```

5. **Validar no navegador:** Acesse `http://localhost:8100/configuracoes`.

---

### Bloco 4 - Validação da Persistência Após F5 e Reinicialização

1. No aplicativo, altere o estado do toggle, digite um e-mail de teste e clique em "Salvar Preferências".
2. Atualize a página do navegador (`F5`) ou feche o navegador e abra novamente em `http://localhost:8100/configuracoes`.
3. Verifique se os dados salvos reaparecem preenchidos automaticamente na tela.
4. Testar a saúde da API no Terminal B:
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

3. **Teste de Storage:**
   - Acessar `http://localhost:8100/configuracoes` e testar persistência após o recarregamento.

---

## ✅ Saída Esperada ao Final da Aula

- Plugin `@capacitor/preferences` instalado e sincronizado com `npx cap sync`.
- Serviço `StorageService` operando com os métodos `salvar()`, `obter()`, `remover()` e `limparTudo()`.
- Tela de configurações salvando preferências do usuário de forma assíncrona.
- Dados mantidos e restaurados automaticamente após atualizar ou fechar o aplicativo.

---

**De onde viemos:**  
Retomamos os aprendizados de 'Consumo de APIs REST e Tratamento de Erros - Parte 2', consolidando os fundamentos necessários para avançar com segurança.

**Para onde vamos:**  
A partir desta base, avançaremos para 'Persistência Local - Parte 2', ampliando complexidade, autonomia e capacidade de aplicação prática.
