# Passo a Passo — Aula 16: Recursos Nativos do Dispositivo - Parte 2 (GPS & Monitoramento de Rede)

**Disciplina:** Desenvolvimento de Aplicativos Móveis  
**Tema:** Recursos Nativos do Dispositivo - Parte 2 (GPS & Monitoramento de Rede)  
---

> [!NOTE]
> **Objetivo Operacional:** Integrar a captura de geolocalização (GPS) e o monitoramento em tempo real do status de conexão à internet utilizando os plugins oficiais do Capacitor (`@capacitor/geolocation` e `@capacitor/network`), tratando permissões do SO e ouvintes de eventos assíncronos.

> [!TIP]
> 💡 **Analogia Didática da Aula:** O plugin de rede (`Network.addListener`) é como a luz de sinal no painel de um carro elétrico: ela acende em verde quando você está conectado à tomada (Online) e acende em vermelho instantaneamente no momento em que o cabo é desconectado (Offline).  
> 📌 **Dica Prática:** Peça permissão ao usuário antes de acionar o método `Geolocation.getCurrentPosition()`.

## 📁 Padrão de Caminhos e Organização
- Pasta base da turma: `projetos`
- Projeto Mobile: `projetos/ionic_projeto` (ou `projeto_mobile`)
- Projeto API: `projetos/mobile_api` (ou `agenda-mobile-api`)

> [!IMPORTANT]
> - Manter os 3 terminais ativos durante o desenvolvimento:
>   - **Terminal A:** Mobile (`cd projetos/ionic_projeto` -> `npm run start`)
>   - **Terminal B:** API (`cd projetos/mobile_api` -> `npm start`)
>   - **Terminal C:** CLI para instalação de plugins
> - Instalar os pacotes nativos oficiais `@capacitor/geolocation` e `@capacitor/network`.

---

## ⏱️ Roteiro Completo de Atividades (4 Horas)

### Bloco 1 - Instalação dos Plugins de Geolocalização e Network

1. No **Terminal C (Git Bash)**, navegar para a pasta do projeto mobile:
```bash
cd projetos/ionic_projeto
```

2. **Instalar os pacotes nativos de GPS e rede:**
```bash
npm install @capacitor/geolocation @capacitor/network
```

3. **Sincronizar as pontes do Capacitor:**
```bash
npx cap sync
```

4. Garantir a execução no **Terminal A (Mobile)**:
```bash
npm run start
```

---

### Bloco 2 - Criação do Serviço DispositivoService (GPS e Rede)

1. No **Terminal C (Git Bash)**, gerar o serviço `dispositivo` no projeto mobile:
```bash
cd projetos/ionic_projeto
ng g s services/dispositivo
```

2. **Editar o arquivo `src/app/services/dispositivo.service.ts`:**

```typescript
import { Injectable } from '@angular/core';
import { Geolocation, Position } from '@capacitor/geolocation';
import { Network, ConnectionStatus } from '@capacitor/network';
import { BehaviorSubject, Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class DispositivoService {
  // Estado reativo do status de rede (Online/Offline)
  private redeSubject = new BehaviorSubject<boolean>(true);
  public redeConectada$: Observable<boolean> = this.redeSubject.asObservable();

  constructor() {
    this.iniciarMonitoramentoRede();
  }

  // Captura as coordenadas atuais de latitude e longitude do dispositivo
  async obterCoordenadas(): Promise<{ latitude: number; longitude: number } | null> {
    try {
      const posicao: Position = await Geolocation.getCurrentPosition();
      return {
        latitude: posicao.coords.latitude,
        longitude: posicao.coords.longitude
      };
    } catch (erro) {
      console.warn('Erro ao obter posição de GPS:', erro);
      return null;
    }
  }

  // Monitora alterações de conexão de rede em tempo real com ouvintes (Listeners)
  private async iniciarMonitoramentoRede() {
    const status: ConnectionStatus = await Network.getStatus();
    this.redeSubject.next(status.connected);

    // Registra o ouvinte para disparar novidades sempre que o estado da rede alterar
    Network.addListener('networkStatusChange', (novoStatus) => {
      this.redeSubject.next(novoStatus.connected);
    });
  }
}
```
> 📌 **Como funciona o `Network.addListener()`?**  
> Diferente de chamadas pontuais, o `addListener` registra uma escuta contínua no sistema operacional. Se o dispositivo entrar em modo avião ou perder o sinal de Wi-Fi, o callback dispara imediatamente notificando a aplicação.

3. **Validar:** Salve o arquivo e confirme a compilação limpa no terminal.

---

### Bloco 3 - Interface Gráfica para Exibição do GPS e Status de Conexão

1. No **Terminal C (Git Bash)**, gerar a página `sensores`:
```bash
cd projetos/ionic_projeto
ng g c pages/sensores --type=page --standalone
```

2. **Adicionar a rota em `src/app/app.routes.ts`:**
```typescript
{
  path: 'sensores',
  loadComponent: () => import('./pages/sensores/sensores.page').then(m => m.SensoresPage),
  canActivate: [authGuard]
}
```
> 📌 Importe `authGuard` de `./guards/auth.guard` no início do arquivo de rotas e acrescente este objeto ao array `routes` existente.

3. **Editar o arquivo TypeScript (`src/app/pages/sensores/sensores.page.ts`):**

```typescript
import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { 
  IonContent, 
  IonHeader, 
  IonTitle, 
  IonToolbar, 
  IonCard, 
  IonCardHeader, 
  IonCardTitle, 
  IonCardContent, 
  IonButton, 
  IonBadge, 
  IonSpinner 
} from '@ionic/angular/standalone';
import { DispositivoService } from '../../services/dispositivo.service';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-sensores',
  templateUrl: './sensores.page.html',
  styleUrls: ['./sensores.page.scss'],
  standalone: true,
  imports: [
    CommonModule, 
    IonContent, 
    IonHeader, 
    IonTitle, 
    IonToolbar, 
    IonCard, 
    IonCardHeader, 
    IonCardTitle, 
    IonCardContent, 
    IonButton, 
    IonBadge, 
    IonSpinner
  ]
})
export class SensoresPage implements OnInit, OnDestroy {
  latitude: number | null = null;
  longitude: number | null = null;
  carregandoGps: boolean = false;
  redeOnline: boolean = true;
  private subRede: Subscription = new Subscription();

  constructor(private dispositivoService: DispositivoService) { }

  ngOnInit() {
    // Inscreve-se no Observable de status de rede
    this.subRede = this.dispositivoService.redeConectada$.subscribe(online => {
      this.redeOnline = online;
    });
  }

  // Dispara a busca por coordenadas de GPS
  async capturarGps() {
    this.carregandoGps = true;
    const coords = await this.dispositivoService.obterCoordenadas();
    this.carregandoGps = false;

    if (coords) {
      this.latitude = coords.latitude;
      this.longitude = coords.longitude;
    }
  }

  ngOnDestroy() {
    this.subRede.unsubscribe();
  }
}
```

4. **Editar o HTML (`src/app/pages/sensores/sensores.page.html`):**

```html
<ion-header [translucent]="true">
  <ion-toolbar color="primary">
    <ion-title>Recursos do Dispositivo</ion-title>
  </ion-toolbar>
</ion-header>

<ion-content class="ion-padding">
  <!-- Status de Conexão de Rede -->
  <ion-card>
    <ion-card-header>
      <ion-card-title>Status da Conexão de Rede</ion-card-title>
    </ion-card-header>
    <ion-card-content>
      <p>Estado Atual:
        <ion-badge [color]="redeOnline ? 'success' : 'danger'">
          {{ redeOnline ? 'ONLINE' : 'OFFLINE' }}
        </ion-badge>
      </p>
    </ion-card-content>
  </ion-card>

  <!-- Localização via GPS -->
  <ion-card class="ion-margin-top">
    <ion-card-header>
      <ion-card-title>Localização via GPS</ion-card-title>
    </ion-card-header>
    <ion-card-content>
      <div *ngIf="carregandoGps" class="ion-text-center">
        <ion-spinner name="crescent"></ion-spinner>
        <p>Buscando coordenadas...</p>
      </div>

      <div *ngIf="!carregandoGps && latitude !== null">
        <p>Latitude: <strong>{{ latitude }}</strong></p>
        <p>Longitude: <strong>{{ longitude }}</strong></p>
      </div>

      <ion-button expand="block" color="primary" class="ion-margin-top" (click)="capturarGps()">
        Obter Minhas Coordenadas
      </ion-button>
    </ion-card-content>
  </ion-card>
</ion-content>
```

5. **Validar no navegador:** Acesse `http://localhost:8100/sensores`.

---

### Bloco 4 - Testes Práticos de GPS e Simulação de Perda de Conexão

1. Clicar no botão "Obter Minhas Coordenadas" e aceitar a permissão de localização solicitada pelo navegador.
2. Confirmar a exibição da Latitude e Longitude na tela.
3. No **DevTools** (`F12` -> Network -> Throttling -> selecionar **Offline**), simule a queda da internet e observe o Badge mudar para **OFFLINE** em tempo real!
4. Restaure para Online no DevTools e veja a atualização dinâmica da interface.

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

3. **Teste de Sensores:**
   - Acessar `http://localhost:8100/sensores` e testar coordenadas de GPS e perda de conexão de rede.

---

## ✅ Saída Esperada ao Final da Aula

- Plugins `@capacitor/geolocation` e `@capacitor/network` instalados e operacionais.
- Serviço `DispositivoService` encapsulando lógica de coordenadas e escuta de rede.
- Interface reativa exibindo selos visuais ONLINE/OFFLINE e dados de GPS.
- Tratamento de permissões do navegador/SO funcional.

---

**De onde viemos:**  
Retomamos os aprendizados de 'Recursos Nativos do Dispositivo - Parte 1', consolidando os fundamentos necessários para avançar com segurança.

**Para onde vamos:**  
A partir desta base, avançaremos para 'Projeto Integrador - Parte 1', ampliando complexidade, autonomia e capacidade de aplicação prática.
