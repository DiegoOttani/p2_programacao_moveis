# O que ainda falta fazer — P2 Flutter

**Prazo de entrega:** 27/11/2026, às 23h59 (enviar na tarefa da disciplina).

O código do app já está pronto: `flutter analyze` não aponta problemas e os 23 testes
automatizados passam. O que falta é **executar no Android**, **registrar as evidências** e
**entregar**.

---

## 1. Preparar o ambiente Android

O PC onde o projeto foi feito **não tem o Android SDK**, então o app ainda não foi aberto
em nenhum emulador ou aparelho.

- [ ] Instalar o Android Studio (https://developer.android.com/studio) e, pelo SDK Manager,
      instalar o Android SDK, as Platform-Tools e uma imagem de emulador.
- [ ] Criar um emulador (Device Manager) **ou** ligar um celular com depuração USB ativada.
- [ ] Colocar o Flutter no PATH (ele está em `C:\Users\Diego\dev\flutter\bin`) ou usar o
      caminho completo nos comandos.
- [ ] Rodar `flutter doctor --android-licenses` e aceitar as licenças.
- [ ] Rodar `flutter doctor` e confirmar que **Android toolchain** aparece sem erro.
- [ ] Conferir a versão: o projeto exige **Flutter 3.50 ou mais novo** (usa `package:material_ui`).
      Quem for rodar o projeto (incluindo outros integrantes) precisa de uma versão igual ou mais nova.
- [ ] Na raiz do repositório:
      ```bash
      flutter pub get
      flutter devices          # copiar o ID do Android
      flutter run -d ID_DO_ANDROID
      ```

## 2. Prática guiada do Capítulo 10 (seções 1 a 9)

O README já descreve esses passos, mas eles **precisam ser feitos de verdade** e
comprovados com prints. O código de exemplo está em
`Informacoes/Cap10_Flutter_API_REST_Projetos.zip` → `Projeto_A_API_REST` (a pasta
`Informacoes/` só existe localmente, não vai para o GitHub).

- [ ] Abrir `https://dummyjson.com/products?limit=12` no navegador e localizar a lista
      `products` e os campos `id`, `title` e `price`.
- [ ] Criar um projeto separado (fora deste repositório) com o Projeto A, executar o
      catálogo e abrir a tela de detalhes de um produto.
- [ ] Trocar `limit=12` por `limit=5` em `produtos_api_service.dart`, atualizar e conferir
      que aparecem **5 produtos**. → **Print 1**
- [ ] Desligar a internet, pedir nova consulta e ver a mensagem de erro. → **Print 2**
- [ ] Religar a internet e testar o botão **Tentar novamente**.
- [ ] Salvar os prints com estes nomes exatos (o README já aponta para eles):
  - `docs/prints/pratica_cinco_produtos.png`
  - `docs/prints/pratica_erro_conexao.png`

## 3. Testes de aceitação T1 a T7 (no Android)

Executar **na ordem**, no app deste repositório, e preencher a tabela
"Testes de aceitação" do `README.md` (colunas **Resultado observado** e **Status**).

- [ ] Antes de começar, **anotar os preços** dos dois produtos que serão usados e preencher
      a linha "Preços anotados no catálogo" no README.
- [ ] **T1** — Com internet, abrir o catálogo e selecionar um produto → a lista carrega e os
      detalhes mostram o item escolhido.
- [ ] **T2** — Sem rede, tocar em Atualizar → aparece a mensagem de erro. Religar a rede e tocar
      em **Tentar novamente** → o catálogo volta.
- [ ] **T3** — Adicionar o mesmo produto duas vezes (a 2ª vez avisa "já está na lista") → em
      Minha lista há **uma linha** com quantidade 1.
- [ ] **T4** — Adicionar um 2º produto. Mudar o 1º para 3 unidades. Tocar em "Qtd" e tentar
      gravar **0** e depois **100** → ambos rejeitados, quantidade continua 3 e o subtotal = 3 × preço.
- [ ] **T5** — Marcar o 1º como comprado e ligar o filtro em Configurações → o 1º some, o total
      continua somando os dois. Desligar o filtro → o item volta marcado como comprado.
- [ ] **T6** — Ligar o tema escuro e o filtro. **Fechar o app de verdade** (tirar dos recentes, sem
      limpar dados) e abrir pelo ícone → tema e filtro voltam. Desligar o filtro → 1º item continua
      comprado com quantidade 3.
- [ ] **T7** — Sem rede, abrir Minha lista, editar um item, tocar em excluir e **Cancelar** (item
      fica), depois excluir e **Confirmar** (item sai e o total é atualizado).
- [ ] Conferir as contas: subtotal = preço × quantidade; total = soma de todos os itens.
- [ ] Se algum teste falhar, anotar o que aconteceu no README e corrigir antes da entrega.

## 4. Vídeo (até 5 minutos)

Mostrar, nesta ordem sugerida:

- [ ] Catálogo carregando e a tela de detalhes de um produto.
- [ ] Inclusão de um item na lista.
- [ ] Tentativa de adicionar o mesmo item de novo (aviso e **ausência de duplicata**).
- [ ] Edição do item (quantidade e marcar como comprado).
- [ ] Alteração do tema e do filtro em Configurações.
- [ ] Fechar e reabrir o app, mostrando tema, filtro e lista restaurados.
- [ ] Uso da lista **sem conexão** (modo avião), editando um item.
- [ ] Enviar o vídeo (YouTube não listado, Google Drive etc.), **testar o link em uma aba anônima**
      e colar o link na tabela "Identificação" do `README.md`.

## 5. Finalizar o README

- [ ] Link do vídeo preenchido.
- [ ] Os dois prints da prática guiada aparecendo corretamente no GitHub.
- [ ] Tabela T1–T7 com resultado observado e status de cada teste.
- [ ] Preços anotados preenchidos.
- [ ] Conferir o nome da disciplina na tabela de identificação.

## 6. Entrega

- [ ] Rodar `flutter analyze` e `flutter test` mais uma vez a partir do repositório.
- [ ] Fazer commit e push dos prints e do README atualizado.
- [ ] Garantir que o repositório no GitHub está **público** (ou que o professor tem acesso) e
      abrir o link em uma aba anônima para conferir.
- [ ] Conferir que o repositório tem `lib/`, `android/`, `pubspec.yaml`, `pubspec.lock` e
      `README.md`, e **não** tem `build/` nem `.dart_tool/` (o `.gitignore` já cuida disso).
- [ ] Se preferirem entregar um ZIP em vez do link: compactar a pasta do projeto **sem**
      `build/`, `.dart_tool/` e `Informacoes/`.
- [ ] Enviar na tarefa até **27/11/2026 às 23h59**: link do repositório (ou ZIP) + link do vídeo.
- [ ] Opcional: apagar esta pasta `pendencias/` antes da entrega final.
