$ErrorActionPreference = 'Stop'

$base = 'c:/Users/eduar/projetos/planejamento_docencia/dispositivos/DE_AP_MO'
$jsonPath = Join-Path $base 'aBASE/plano_ensino_aplicativos_moveis.json'
$plano = Get-Content -Raw -Path $jsonPath | ConvertFrom-Json

$singleGuide = Join-Path $base 'aBASE/PASSO_A_PASSO_20_SEMANAS.md'
if (Test-Path $singleGuide) {
  Remove-Item $singleGuide -Force
}

foreach ($a in $plano.disciplina.conteudos) {
  $n = [int]$a.aula
  $n2 = '{0:D2}' -f $n
  $folder = Join-Path $base ("aula$n2")
  $outFile = Join-Path $folder ("Passo a passo Aula $n.txt")

  $steps = @()
  $valid = @()
  $cmds = @()

  if ($n -eq 1) {
    $steps = @(
      'Apresente o objetivo final do semestre e mostre o fluxo completo: API + Mobile.',
      'Explique diferencas praticas entre nativo, hibrido e multiplataforma com exemplos reais.',
      'Mostre a estrutura alvo de pastas e como o projeto sera evoluido semana a semana.',
      'Defina os criterios de pronto: funcionalidade, validacao e justificativa tecnica.',
      'Finalize com checklist de preparacao para a semana 2 (ambiente).'
    )
    $valid = @(
      'Aluno consegue explicar o fluxo geral do projeto completo.',
      'Aluno entende o plano das 20 semanas.'
    )
    $cmds = @('Sem comandos obrigatorios nesta semana (foco conceitual).')
  }
  elseif ($n -eq 2) {
    $steps = @(
      'Instalar Node.js LTS e validar versoes no terminal.',
      'Instalar Ionic CLI e Angular CLI globalmente.',
      'Instalar Android Studio, SDK e criar emulador Android funcional.',
      'Inicializar backend agenda-mobile-api e instalar dependencias.',
      'Criar projeto Ionic projeto_mobile e instalar dependencias.',
      'Subir API e Mobile em paralelo e validar portas e rotas basicas.',
      'Registrar problemas de ambiente e solucao aplicada.'
    )
    $valid = @(
      'GET /health responde 200.',
      'Mobile abre em navegador sem erro de build.',
      'Emulador/dispositivo pronto para as proximas aulas.'
    )
    $cmds = @(
      'node -v',
      'npm -v',
      'npm install -g @ionic/cli @angular/cli',
      'ionic start projeto_mobile tabs --type=angular --no-interactive',
      'npm install'
    )
  }
  elseif ($n -ge 3 -and $n -le 5) {
    $steps = @(
      'Construir e refinar as telas com componentes Ionic e templates Angular.',
      'Aplicar formulários, validacoes e feedback visual para erros de entrada.',
      'Padronizar estilo visual para consistencia entre telas.',
      'Revisar responsividade em diferentes tamanhos de tela.',
      'Executar validacao funcional da interface ao final da aula.'
    )
    $valid = @(
      'Tela funcional e responsiva para o objetivo da semana.',
      'Validacoes de formulario funcionando.',
      'Padrao visual consistente com o restante do app.'
    )
    $cmds = @('Set-Location c:/Users/eduar/projetos/planejamento_docencia/dispositivos/projeto_mobile; npm run start')
  }
  elseif ($n -ge 6 -and $n -le 7) {
    $steps = @(
      'Configurar rotas principais e redirecionamentos do app.',
      'Implementar navegacao com tabs e menu lateral.',
      'Implementar passagem de parametro em rotas de detalhe.',
      'Testar navegacao por botoes e por URL direta.',
      'Corrigir rotas quebradas e loops de redirecionamento.'
    )
    $valid = @(
      'Navegacao entre telas funcionando sem conflito.',
      'Rota de detalhe com parametro funcionando.'
    )
    $cmds = @('Set-Location c:/Users/eduar/projetos/planejamento_docencia/dispositivos/projeto_mobile; npm run start')
  }
  elseif ($n -eq 8) {
    $steps = @(
      'Organizar o projeto em camadas: core e features.',
      'Separar services, guards, interceptors e models em modulo central.',
      'Remover acoplamento indevido entre UI e regra de negocio.',
      'Padronizar nomenclatura e importacoes para facilitar manutencao.',
      'Validar build apos reorganizacao.'
    )
    $valid = @(
      'Arquitetura em camadas clara e navegavel.',
      'Build sem erro apos reorganizacao.'
    )
    $cmds = @('Set-Location c:/Users/eduar/projetos/planejamento_docencia/dispositivos/projeto_mobile; npm run build')
  }
  elseif ($n -ge 9 -and $n -le 10) {
    $steps = @(
      'Implementar/ajustar API REST no backend e consumo no frontend.',
      'Mapear respostas JSON para modelo de dominio.',
      'Criar fluxo de importacao de dados externos para treino de integracao.',
      'Padronizar tratamento de erros com mensagens claras para usuario.',
      'Executar testes com API online/offline para validar resiliencia.'
    )
    $valid = @(
      'Frontend consome API e exibe dados corretamente.',
      'Erros de comunicacao tratados sem quebrar a interface.'
    )
    $cmds = @(
      'Set-Location c:/Users/eduar/projetos/planejamento_docencia/dispositivos/agenda-mobile-api; npm start',
      'Invoke-RestMethod http://localhost:3000/health',
      'Set-Location c:/Users/eduar/projetos/planejamento_docencia/dispositivos/projeto_mobile; npm run start'
    )
  }
  elseif ($n -ge 11 -and $n -le 12) {
    $steps = @(
      'Implementar persistencia de preferencias com Capacitor Preferences/localStorage.',
      'Implementar camada de persistencia local robusta com Ionic Storage.',
      'Salvar e recuperar dados locais para validar continuidade de uso.',
      'Documentar no codigo onde cada tipo de dado esta sendo persistido.',
      'Testar persistencia apos reiniciar o app.'
    )
    $valid = @(
      'Preferencias e dados locais recuperados apos reinicio.',
      'Fluxo de persistencia validado no frontend.'
    )
    $cmds = @('Set-Location c:/Users/eduar/projetos/planejamento_docencia/dispositivos/projeto_mobile; npm run start')
  }
  elseif ($n -ge 13 -and $n -le 14) {
    $steps = @(
      'Implementar login/cadastro no frontend com estado de sessao.',
      'Implementar JWT no backend com hash de senha e middleware auth.',
      'Proteger rotas privadas no frontend com guard.',
      'Configurar interceptor para anexar token Bearer automaticamente.',
      'Testar acesso autorizado e nao autorizado nas rotas de tarefas.'
    )
    $valid = @(
      'JWT funcionando ponta a ponta (API e Mobile).',
      'Rotas protegidas sem token e liberadas com token valido.'
    )
    $cmds = @(
      'Set-Location c:/Users/eduar/projetos/planejamento_docencia/dispositivos/agenda-mobile-api; npm start',
      'Set-Location c:/Users/eduar/projetos/planejamento_docencia/dispositivos/projeto_mobile; npm run start'
    )
  }
  elseif ($n -ge 15 -and $n -le 16) {
    $steps = @(
      'Integrar camera para captura de foto em tarefa.',
      'Integrar geolocalizacao para associar coordenadas.',
      'Integrar notificacao local para lembretes.',
      'Tratar cenarios de permissao negada com retorno seguro de UI.',
      'Validar em emulador/dispositivo com plugins sincronizados.'
    )
    $valid = @(
      'Foto, localizacao e lembrete funcionando no fluxo da tarefa.',
      'Sem crash quando permissao e negada.'
    )
    $cmds = @(
      'Set-Location c:/Users/eduar/projetos/planejamento_docencia/dispositivos/projeto_mobile; npx cap sync android',
      'Set-Location c:/Users/eduar/projetos/planejamento_docencia/dispositivos/projeto_mobile; npm run start'
    )
  }
  elseif ($n -ge 17 -and $n -le 18) {
    $steps = @(
      'Montar backlog final de pendencias e priorizar por impacto.',
      'Integrar ajustes finais entre API e Mobile.',
      'Executar ciclo rapido: implementar, testar, corrigir.',
      'Documentar alteracoes importantes e decisoes de arquitetura.',
      'Validar fluxo principal completo ao final da aula.'
    )
    $valid = @(
      'Fluxo integrado completo sem bloqueios criticos.',
      'Pendencias finais reduzidas para etapa de estabilizacao.'
    )
    $cmds = @(
      'Set-Location c:/Users/eduar/projetos/planejamento_docencia/dispositivos/agenda-mobile-api; npm start',
      'Set-Location c:/Users/eduar/projetos/planejamento_docencia/dispositivos/projeto_mobile; npm run start'
    )
  }
  elseif ($n -eq 19) {
    $steps = @(
      'Executar bateria de testes funcionais de ponta a ponta.',
      'Corrigir bugs criticos e ajustar mensagens de erro/usabilidade.',
      'Executar testes automatizados da API.',
      'Executar build do mobile para garantir empacotamento.',
      'Revisar codigo, comentarios didaticos e organizacao final.'
    )
    $valid = @(
      'Sem erro critico no fluxo principal.',
      'API testada e mobile com build concluido.'
    )
    $cmds = @(
      'Set-Location c:/Users/eduar/projetos/planejamento_docencia/dispositivos/agenda-mobile-api; npm test',
      'Set-Location c:/Users/eduar/projetos/planejamento_docencia/dispositivos/projeto_mobile; npm run build'
    )
  }
  else {
    $steps = @(
      'Preparar roteiro de apresentacao com sequencia tecnica clara.',
      'Demonstrar login, CRUD, integracao, seguranca e recursos nativos.',
      'Explicar as principais decisoes tecnicas do projeto.',
      'Registrar melhorias futuras e proximos passos de evolucao.'
    )
    $valid = @(
      'Demonstracao ponta a ponta concluida com sucesso.',
      'Equipe explica com clareza o que foi implementado e por que.'
    )
    $cmds = @(
      'Set-Location c:/Users/eduar/projetos/planejamento_docencia/dispositivos/agenda-mobile-api; npm start',
      'Set-Location c:/Users/eduar/projetos/planejamento_docencia/dispositivos/projeto_mobile; npm run start'
    )
  }

  $conteudos = ($a.conteudos | ForEach-Object { "- $_" }) -join "`r`n"
  $passos = ($steps | ForEach-Object { "- $_" }) -join "`r`n"
  $validacao = ($valid | ForEach-Object { "- $_" }) -join "`r`n"
  $comandos = ($cmds | ForEach-Object { "- $_" }) -join "`r`n"

  $texto = @"
PASSO A PASSO - AULA $n2
Tema da semana
$($a.titulo)

Objetivo operacional
$($a.objetivo)

Planejamento de tempo (4 horas)
- Bloco 1 (0h-1h): alinhamento e preparacao tecnica.
- Bloco 2 (1h-2h): implementacao guiada.
- Bloco 3 (2h-3h): implementacao assistida.
- Bloco 4 (3h-4h): testes, correcao e validacao.

Escopo tecnico da semana
$conteudos

Passo a passo detalhado
$passos

Onde atuar no projeto
- Backend: c:/Users/eduar/projetos/planejamento_docencia/dispositivos/agenda-mobile-api
- Frontend: c:/Users/eduar/projetos/planejamento_docencia/dispositivos/projeto_mobile

Comandos principais
$comandos

Validacao obrigatoria ao final
$validacao

Entregaveis do aluno
- Evidencia visual (print ou video curto) da funcionalidade da semana.
- Codigo atualizado no modulo trabalhado.
- Relato rapido: problema encontrado e como foi resolvido.

Checklist do professor
- Verificar se todos os alunos concluíram o bloco de validacao.
- Confirmar que ambiente de API e Mobile ficou funcional.
- Garantir aderencia ao objetivo da semana antes de avancar.

Conexao pedagogica
- De onde viemos: $($a.de_onde_viemos)
- Para onde vamos: $($a.para_onde_vamos)
"@

  Set-Content -Path $outFile -Value $texto -Encoding UTF8
}

Write-Output 'OK: arquivos semanais gerados com sucesso.'
