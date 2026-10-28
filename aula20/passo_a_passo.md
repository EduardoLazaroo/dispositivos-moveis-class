# Passo a Passo — Aula 20: Apresentação e Encerramento (Projeto Integrador)

**Disciplina:** Desenvolvimento de Aplicativos Móveis  
**Tema:** Apresentação e Encerramento (Projeto Integrador)  
---

> [!NOTE]
> **Objetivo Operacional:** Executar a apresentação final e demonstração prática do aplicativo do Projeto Integrador, validando a integração completa do ecossistema mobile (Ionic + Angular + Capacitor + API Node/Express + JWT + Persistência) e consolidando a avaliação da disciplina.

> [!TIP]
> 💡 **Analogia Didática da Aula:** A Apresentação do Projeto Integrador é a grande inauguração do seu produto no mercado: você demonstra a integração perfeita entre o painel visual (Mobile), o motor (API Backend) e os sensores físicos (Capacitor) para a banca examinadora.  
> 📌 **Dica Prática:** Monte um roteiro de apresentação em tempo real: 1) Login com JWT, 2) Navegação por Abas/Menu, 3) CRUD de dados na API, 4) Recursos Nativo (Câmera/GPS) e 5) Resiliência Offline.

## 📁 Padrão de Caminhos e Organização
- Pasta base da turma: `projetos`
- Projeto Mobile: `projetos/ionic_projeto` (ou `projeto_mobile`)
- Projeto API: `projetos/mobile_api` (ou `agenda-mobile-api`)

> [!IMPORTANT]
> - Abrir os 2 terminais obrigatórios antes de iniciar a bancada de apresentação:
>   - **Terminal A:** Mobile (`cd projetos/ionic_projeto` -> `npm run start`)
>   - **Terminal B:** API (`cd projetos/mobile_api` -> `npm start`)
> - Seguir o roteiro de demonstração sequencial para evidenciar todas as competências desenvolvidas ao longo das 20 semanas.

---

## ⏱️ Roteiro Completo de Atividades (4 Horas)

### Bloco 1 - Preparação do Ambiente de Demonstração

1. No **Terminal A (Mobile)**, iniciar o servidor de desenvolvimento:
```bash
cd projetos/ionic_projeto
npm run start
```

2. No **Terminal B (API)**, iniciar o servidor backend Express:
```bash
cd projetos/mobile_api
npm start
```

3. **Validar a inicialização de ambos os serviços:**
   - Frontend Mobile: `http://localhost:8100`
   - Backend API: `http://localhost:3000`

4. **Executar teste rápido de integração no terminal:**
   - **No Git Bash:**
     ```bash
     curl http://localhost:3000/health
     ```
   - **No PowerShell:**
     ```powershell
     Invoke-RestMethod http://localhost:3000/health
     ```

5. Deixar o navegador aberto na inspeção de dispositivo móvel (`F12` -> `Ctrl + Shift + M`).

---

### Bloco 2 - Roteiro de Demonstração - Parte 1: Autenticação e Interfaces

1. Abrir o aplicativo no navegador em `http://localhost:8100`.
2. **Demonstrar a tela de Login:**
   - Tentar login com senha inválida para exibir a mensagem de erro (Toast vermelho).
   - Preencher credenciais corretas e efetuar o login.
   - Evidenciar a emissão e o armazenamento seguro do Token JWT no storage local.
3. **Demonstrar o layout e a navegação:**
   - Mostrar a alternância entre abas inferiores (`<ion-tabs>`).
   - Deslizar o Menu Lateral (`<ion-menu>`) e navegar pelos módulos.

---

### Bloco 3 - Roteiro de Demonstração - Parte 2: CRUD, Sensores e Resiliência Offline

1. **Demonstrar as funcionalidades do Projeto Integrador:**
   - Criar um novo chamado/registro através do formulário.
   - Pesquisar o item criado com a barra de busca dinâmica (`<ion-searchbar>`).
   - Alterar o status do chamado e excluir com confirmação modal (`<ion-alert>`).
2. **Demonstrar o uso de Recursos Nativos:**
   - Capturar foto via plugin `@capacitor/camera`.
   - Exibir a Latitude e Longitude capturadas via `@capacitor/geolocation`.
3. **Demonstrar o Modo Offline:**
   - Com a API ativa, abra primeiro o Catálogo de Produtos para gravar a lista em cache.
   - Desligar a API no Terminal B (`Ctrl+C`) e recarregar a página de Produtos para provar que o catálogo continua sendo exibido via cache local (`@capacitor/preferences`).
   - Religar a API e atualizar o Catálogo de Produtos com `<ion-refresher>` (Pull-to-refresh).
   - Explicar que o cache desta trilha foi implementado para produtos; os chamados dependem da API enquanto não houver uma estratégia de cache específica para eles.

---

### Bloco 4 - Encerramento, Avaliação e Emissão do Relatório Final

1. Apresentar a arquitetura limpa do código (separação de Páginas, Componentes e Serviços no Angular).
2. Responder às dúvidas técnicas da banca/professor sobre as decisões arquiteturais.
3. **Gerar o arquivo de relatório final de conclusão da disciplina:**

```bash
echo "PROJETO INTEGRADOR - DESENVOLVIMENTO DE APLICAÇÕES MOBILE" > projetos/relatorio_final.txt
echo "STATUS: HOMOLOGADO E CONCLUÍDO COM SUCESSO" >> projetos/relatorio_final.txt
```

4. **Validar a gravação no terminal:**
   - **No Git Bash:**
     ```bash
     cat projetos/relatorio_final.txt
     ```
   - **No PowerShell:**
     ```powershell
     Get-Content projetos/relatorio_final.txt
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

3. **Encerramento:**
   - Demonstração concluída com sucesso e relatório final gravado.

---

## ✅ Saída Esperada ao Final da Aula

- Aplicativo mobile do Projeto Integrador apresentado e validado com sucesso.
- Todos os fluxos funcionais (Login, CRUD, Sensores, Cache, Menu) testados na prática.
- Integração ponta a ponta entre Ionic e API Node/Express homologada.
- Relatório de conclusão emitido e disciplina finalizada com êxito!

---

**De onde viemos:**  
Retomamos os aprendizados de 'Projeto Integrador - Parte 3', consolidando os fundamentos necessários para avançar com segurança.

**Para onde vamos:**  
Encerramos a trilha formativa integrando os conhecimentos construídos ao longo de toda a disciplina e preparando a continuidade em projetos corporativos e avançados.
