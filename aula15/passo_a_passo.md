# Passo a Passo — Aula 15: Recursos Nativos do Dispositivo - Parte 1 (Câmera & Galeria)

**Disciplina:** Desenvolvimento de Aplicativos Móveis  
**Tema:** Recursos Nativos do Dispositivo - Parte 1 (Câmera & Galeria)  
---

> [!NOTE]
> **Objetivo Operacional:** Integrar recursos nativos do dispositivo móvel utilizando o plugin oficial `@capacitor/camera`, permitindo a captura de fotos em tempo real pela câmera física/webcam ou seleção de imagens da galeria do aparelho, tratando permissões e exibindo a imagem na interface Ionic.

> [!TIP]
> 💡 **Analogia Didática da Aula:** Os plugins do Capacitor são pontes metálicas que conectam seu código JavaScript/TypeScript aos chips e sensores do celular: chamar o método `Camera.getPhoto()` envia um comando pela ponte para acionar a lente da câmera do aparelho.  
> 📌 **Dica Prática:** No navegador web, instale o `@ionic/pwa-elements` e registre a função `defineCustomElements(window)` no `src/main.ts` para emular a câmera visualmente durante os testes de desenvolvimento.

## 📁 Padrão de Caminhos e Organização
- Pasta base da turma: `projetos`
- Projeto Mobile: `projetos/ionic_projeto` (ou `projeto_mobile`)
- Projeto API: `projetos/mobile_api` (ou `agenda-mobile-api`)

> [!IMPORTANT]
> - Manter os 3 terminais ativos durante o desenvolvimento:
>   - **Terminal A:** Mobile (`cd projetos/ionic_projeto` -> `npm run start`)
>   - **Terminal B:** API (`cd projetos/mobile_api` -> `npm start`)
>   - **Terminal C:** CLI para instalação de pacotes nativos
> - Instalar os pacotes oficiais `@capacitor/camera` e `@ionic/pwa-elements` no projeto mobile.

---

## ⏱️ Roteiro Completo de Atividades (4 Horas)

### Bloco 1 - Instalação e Configuração do Plugin Capacitor Camera

1. No **Terminal C (Git Bash)**, acessar a pasta do projeto mobile:
```bash
cd projetos/ionic_projeto
```

2. **Instalar o pacote nativo de câmera:**
```bash
npm install @capacitor/camera
```

3. **Sincronizar as pontes nativas do Capacitor:**
```bash
npx cap sync
```

4. **Instalar o utilitário PWA Elements para habilitar a câmera no navegador de testes:**
```bash
npm install @ionic/pwa-elements
```

5. **Editar o arquivo `src/main.ts` para inicializar os elementos visuais da câmera no navegador:**

```typescript
import { defineCustomElements } from '@ionic/pwa-elements/loader';

// Inicializa a interface de câmera para navegadores web
defineCustomElements(window);
```

6. Garantir que o **Terminal A (Mobile)** está em execução:
```bash
npm run start
```

---

### Bloco 2 - Criação do Serviço FotoService

1. No **Terminal C (Git Bash)**, gerar o serviço `foto` no projeto mobile:
```bash
cd projetos/ionic_projeto
ng g s services/foto
```

2. **Editar o arquivo `src/app/services/foto.service.ts` implementando métodos de captura e seleção de galeria:**

```typescript
import { Injectable } from '@angular/core';
import { Camera, CameraResultType, CameraSource } from '@capacitor/camera';

@Injectable({
  providedIn: 'root'
})
export class FotoService {

  constructor() { }

  // Captura uma foto utilizando a câmera física ou webcam
  async tirarFoto(): Promise<string | undefined> {
    try {
      const imagemCapturada = await Camera.getPhoto({
        resultType: CameraResultType.Uri, // Retorna uma URL acessível pela WebView
        source: CameraSource.Camera, // Aciona a câmera
        quality: 90 // Qualidade da imagem (0 a 100)
      });

      return imagemCapturada.webPath;
    } catch (erro) {
      console.warn('Captura de foto cancelada ou não suportada:', erro);
      return undefined;
    }
  }

  // Seleciona uma imagem existente da galeria de fotos do dispositivo
  async selecionarDaGaleria(): Promise<string | undefined> {
    try {
      const imagemSelecionada = await Camera.getPhoto({
        resultType: CameraResultType.Uri,
        source: CameraSource.Photos, // Abre a galeria de fotos
        quality: 90
      });

      return imagemSelecionada.webPath;
    } catch (erro) {
      console.warn('Seleção de galeria cancelada:', erro);
      return undefined;
    }
  }
}
```
> 📌 **Entendendo os parâmetros do `Camera.getPhoto()`:**
> - `resultType: CameraResultType.Uri`: Retorna o caminho de mídia seguro que pode ser diretamente passado para a propriedade `src` de uma tag `<ion-img>`.
> - `source: CameraSource.Camera` vs `CameraSource.Photos`: Alterna entre abrir a lente da câmera ou a galeria de imagens.

3. **Validar:** Salve o arquivo e certifique-se de que não existem erros no código.

---

### Bloco 3 - Interface Visual para Captura e Exibição da Foto

1. No **Terminal C (Git Bash)**, gerar a página `fotos`:
```bash
cd projetos/ionic_projeto
ng g c pages/fotos --type=page --standalone
```

2. **Adicionar a rota em `src/app/app.routes.ts`:**
```typescript
{
  path: 'fotos',
  loadComponent: () => import('./pages/fotos/fotos.page').then(m => m.FotosPage),
  canActivate: [authGuard]
}
```
> 📌 Importe `authGuard` de `./guards/auth.guard` no início do arquivo de rotas e acrescente este objeto ao array `routes` existente.

3. **Editar o arquivo TypeScript (`src/app/pages/fotos/fotos.page.ts`):**

```typescript
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { 
  IonContent, 
  IonHeader, 
  IonTitle, 
  IonToolbar, 
  IonButton, 
  IonIcon, 
  IonCard, 
  IonImg 
} from '@ionic/angular/standalone';
import { FotoService } from '../../services/foto.service';

@Component({
  selector: 'app-fotos',
  templateUrl: './fotos.page.html',
  styleUrls: ['./fotos.page.scss'],
  standalone: true,
  imports: [
    CommonModule, 
    IonContent, 
    IonHeader, 
    IonTitle, 
    IonToolbar, 
    IonButton, 
    IonIcon, 
    IonCard, 
    IonImg
  ]
})
export class FotosPage implements OnInit {
  fotoUrl: string | undefined = '';

  constructor(private fotoService: FotoService) { }

  ngOnInit() { }

  async tirarFoto() {
    const url = await this.fotoService.tirarFoto();
    if (url) {
      this.fotoUrl = url;
    }
  }

  async abrirGaleria() {
    const url = await this.fotoService.selecionarDaGaleria();
    if (url) {
      this.fotoUrl = url;
    }
  }
}
```

4. **Editar o HTML (`src/app/pages/fotos/fotos.page.html`):**

```html
<ion-header [translucent]="true">
  <ion-toolbar color="primary">
    <ion-title>Captura de Fotos</ion-title>
  </ion-toolbar>
</ion-header>

<ion-content class="ion-padding ion-text-center">
  <div class="botoes-container">
    <ion-button expand="block" color="primary" (click)="tirarFoto()">
      Tirar Foto com Câmera
    </ion-button>

    <ion-button expand="block" fill="outline" color="secondary" class="ion-margin-top" (click)="abrirGaleria()">
      Escolher da Galeria
    </ion-button>
  </div>

  <!-- Exibição da Foto Capturada -->
  <ion-card class="ion-margin-top" *ngIf="fotoUrl">
    <ion-img [src]="fotoUrl" alt="Foto capturada"></ion-img>
  </ion-card>
</ion-content>
```

5. **Validar no navegador:** Acesse `http://localhost:8100/fotos`.

---

### Bloco 4 - Testes de Permissão e Fallback de Web/Mobile

1. No navegador, clique em "Tirar Foto com Câmera" e permita o acesso à webcam no prompt do navegador.
2. Tire uma foto de teste e verifique a renderização da imagem dentro do `<ion-card>`.
3. Teste o botão "Escolher da Galeria" e selecione um arquivo de imagem do seu computador.
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

3. **Teste do Plugin de Câmera:**
   - Acessar `http://localhost:8100/fotos` e testar a captura de imagem.

---

## ✅ Saída Esperada ao Final da Aula

- Pacotes `@capacitor/camera` e `@ionic/pwa-elements` instalados e configurados.
- Serviço `FotoService` encapsulando as chamadas nativas de câmera e galeria.
- Interface visual exibindo botões de ação e renderizando imagens com `<ion-img>`.
- Suporte híbrido validado na Web e em dispositivos móveis.

---

**De onde viemos:**  
Retomamos os aprendizados de 'Autenticação e Proteção de Rotas - Parte 2', consolidando os fundamentos necessários para avançar com segurança.

**Para onde vamos:**  
A partir desta base, avançaremos para 'Recursos Nativos do Dispositivo - Parte 2', ampliando complexidade, autonomia e capacidade de aplicação prática.
