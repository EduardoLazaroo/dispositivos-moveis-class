# Passo a Passo — Aula 01: Introducao ao Desenvolvimento Mobile

**Disciplina:** Desenvolvimento de Aplicativos Móveis  
**Tema:** Introducao ao Desenvolvimento Mobile  
---

> [!NOTE]
> **Objetivo Operacional:** Compreender o ecossistema de desenvolvimento de aplicativos moveis, identificar as diferencas entre abordagens nativas, hibridas e multiplataforma, explorar as ferramentas do stack da disciplina (Ionic, Angular, TypeScript e Node.js) e entender o ciclo de desenvolvimento da aplicacao.

> [!TIP]
> 💡 **Analogia Didática da Aula:** Desenvolver para celular é como construir veículos: um aplicativo nativo é um carro de corrida sob medida; um híbrido (Ionic) é um veículo modular versátil que roda em qualquer pista (Android e iOS) usando a mesma estrutura!
> 📌 **Dica Prática:** O Ionic nos permite usar linguagens da web (HTML, CSS, TypeScript/Angular) para criar apps de celular de altíssima qualidade.

## 📁 Padrão de Caminhos e Organização
- Pasta base da turma: projetos
- Projeto Mobile: projetos/ionic_projeto
- Projeto API: projetos/mobile_api

> [!IMPORTANT]
> - Nesta primeira aula o foco e o alinhamento de conceitos, analise de arquitetura mobile e compreensao das ferramentas.
> - Os ambientes de execucao e projetos praticos serao construidos do zero a partir da Aula 02.

## ⏱️ Roteiro Completo de Atividades (4 Horas)

### Bloco 1 (0h-1h) - Panorama do Mercado Mobile e Abordagens de Desenvolvimento

1. Discutir as diferencas entre os ecossistemas Android (Google/Kotlin/Java) e iOS (Apple/Swift).

2. Analisar as tres principais abordagens de desenvolvimento:
- Desenvolvimento Nativo: maior desempenho e acesso direto a hardware, porem exige equipes separadas e custos mais altos.
- Desenvolvimento Hibrido / Web-View: utilizacao de tecnologias web (HTML, CSS, JS) empacotadas para rodar no dispositivo.
- Desenvolvimento Multiplataforma / Compilado: codigo unico que gera componentes nativos (ex: Flutter, React Native, Ionic com Capacitor).

3. Avaliar trade-offs tecnicos e de mercado: tempo de entrega, custo de manutencao, experiencia do usuario e requisitos de hardware.

4. Validar o entendimento respondendo mentalmente ou em grupo:
- Qual abordagem escolher para um MVP com prazo curto e equipe web ja existente? (Resposta: Hibrida/Ionic).

### Bloco 2 (1h-2h) - O Stack da Disciplina (Ionic, Angular, TypeScript, Capacitor)

1. Apresentar os quatro pilares da tecnologia utilizada no curso:
- Ionic Framework: biblioteca de componentes visuais estilizados para simular a experiencia nativa de iOS e Android.
- Angular: framework para estruturar a aplicacao frontend com componentes, servicos, injecao de dependencia e rotas.
- TypeScript: superset do JavaScript que adiciona tipagem estatica, reduzindo erros em tempo de desenvolvimento.
- Capacitor: ponte nativa que permite ao JS/TS acessar recursos como Camera, GPS e Armazenamento Local.

2. Explorar o fluxo de compilacao e execucao:
- Codigo TS/HTML/CSS -> Build Angular/Ionic -> Renderizacao na WebView -> Plugins Capacitor comunicando com o OS.

3. Validar a presenca inicial do Node.js no sistema abrindo o terminal:
```bash
node -v
```

```bash
npm -v
```

4. Confirmar que os utilitarios estao respondendo com as versoes instaladas.

### Bloco 3 (2h-3h) - Estrutura e Ciclo de Vida de uma Aplicacao Mobile

1. Analisar a estrutura basica de pastas que sera gerada para o projeto mobile:
- src/app: contem as paginas, componentes e servicos.
- src/assets: imagens, icones e arquivos estaticos.
- src/theme: variaveis de estilo global e temas CSS.

2. Compreender o Ciclo de Vida de paginas no Ionic/Angular:
- ngOnInit / ionViewDidEnter: execucao quando a tela inicializa ou ganha foco.
- ionViewWillLeave / ngOnDestroy: execucao quando o usuario navega para outra tela ou a pagina e destruida.

3. Simular a estrutura do projeto criando manualmente uma pasta de estudos preliminar:
```bash
mkdir projetos
```

```bash
cd projetos
```

4. Validar a criacao da pasta base digitando:
```bash
cd projetos
```

### Bloco 4 (3h-4h) - Apresentacao da Trilha de 20 Semanas e Projeto Integrador

1. Apresentar o escopo completo da disciplina dividida em 20 aulas praticas:
- Aulas 01-05: Fundamentos, Ambiente e Interfaces Graficas.
- Aulas 06-08: Navegacao entre Telas e Arquitetura da Aplicacao.
- Aulas 09-10: Consumo de APIs REST (Node/Express).
- Aulas 11-14: Persistencia Local (Storage) e Autenticacao JWT.
- Aulas 15-16: Recursos Nativos do Dispositivo (Camera, Geolocalizacao).
- Aulas 17-20: Desenvolvimento e Apresentacao do Projeto Integrador.

2. Escrever um arquivo de anotacoes conceituais para consolidar o aprendizado da Aula 01.
- Criar arquivo projetos/anotacoes_aula01.txt com o conteudo:

DISCIPLINA: DESENVOLVIMENTO DE APLICACOES MOBILE
AULA 01 - INTRODUCAO E CONCEITOS

Stack Escolhido:
- Mobile: Ionic + Angular + TypeScript + Capacitor
- Backend: Node.js + Express + MySQL

Principais Vantagens:

1. Reaproveitamento de conhecimentos Web (HTML/CSS/TS).

2. Codigo unico para Web, Android e iOS.

3. Integracao simplificada com APIs REST.

3. Validar a criacao do arquivo exibindo seu conteudo no terminal:

```bash
- Get-Content projetos/anotacoes_aula01.txt
```

## 🔄 Fluxo Resumido de Execução Diária

1. Abrir terminal no sistema.

2. Navegar ate a pasta de trabalho:
```bash
cd projetos
```

3. Verificar a existencia do arquivo de anotacoes:

```javascript
- Get-Content anotacoes_aula01.txt
```

## ✅ Saída Esperada ao Final da Aula

- Entendimento claro das diferencas entre Nativo, Hibrido e Multiplataforma.
- Dominio dos conceitos do stack Ionic + Angular + TypeScript.
- Pasta base projetos criada.
- Aluno preparado para a instalacao e configuracao completa do ambiente na Aula 02.

---

## 📌 Condução Pedagógica & Diretrizes do Professor

### Objetivo da condução

Apresentar o ecossistema de desenvolvimento de aplicativos móveis e suas principais abordagens.

### Condução da aula

Inicie com uma conversa guiada sobre apps que os estudantes usam diariamente e, em seguida, diferencie abordagens nativa, híbrida e multiplataforma com foco em tomada de decisão técnica. Conecte essa visão ao stack da disciplina (Ionic + Angular + TypeScript + Capacitor), explicando por que ele acelera entregas e mantém acesso a recursos nativos. Feche a aula apresentando a trilha das 20 semanas e a lógica de construção incremental do projeto integrador.

Conteúdos da aula
- Diferenças entre aplicações nativas, híbridas e multiplataforma.
- Plataformas Android e iOS.
- Ferramentas utilizadas no desenvolvimento mobile.
- Ciclo de vida de um aplicativo.
- Panorama do mercado de aplicações móveis.

Atividade prática

Discussão de exemplos de aplicativos e identificação das abordagens de desenvolvimento mais adequadas.

Resultado esperado

Compreender o cenário do desenvolvimento mobile e suas principais possibilidades.

De onde viemos

Partimos do ponto zero da disciplina, alinhando conceitos-base e expectativas de aprendizagem.

Para onde vamos

A partir desta base, avançaremos para 'Configuração do Ambiente', ampliando complexidade, autonomia e capacidade de aplicação prática.

### Pontos de atenção do professor

Mantenha foco conceitual e de motivação; evite entrar em instalação e código neste primeiro encontro.

Justificativa técnica

Nivelar conceitos entre nativo, hibrido e multiplataforma cria criterio para escolha consciente de stack e evita decisoes por modismo.

Justificativa mercadológica

Entender cenarios e trade-offs de mobile aumenta a capacidade de dialogar com empresas que operam com diferentes estrategias de produto.
