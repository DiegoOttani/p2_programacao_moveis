# O que ainda falta fazer — P2 Flutter

**Prazo de entrega:** 27/11/2026, às 23h59 (enviar na tarefa da disciplina).

O código do app já está pronto: `flutter analyze` não aponta problemas e os 23 testes
automatizados passam. O ambiente Android já está pronto e o app já roda no emulador
(seção 1). O que falta é **registrar as evidências** e **entregar**.

---

## 1. Preparar o ambiente Android ✅ (concluído em 26/11/2026)

O app já foi compilado e aberto no emulador Android: o catálogo carregou os produtos
da API normalmente.

- [x] Instalar o Android Studio (2026.2.2.10) e o Android SDK: Platform-Tools 37.0.3,
      Emulator 37.3.10, Android 36, Build-Tools 36.0.0, NDK 28.2.13676358 e a imagem
      `android-36 / google_apis / x86_64`. SDK em `C:\Users\Diego\AppData\Local\Android\Sdk`.
- [x] Criar um emulador: AVD **`Pixel_API_36`** (Pixel 7, Android 16 / API 36, aceleração WHPX).
- [x] Colocar o Flutter no PATH do usuário (`C:\Users\Diego\dev\flutter\bin`), junto com
      `platform-tools`, `emulator` e `cmdline-tools\latest\bin`. Também foi definido `ANDROID_HOME`.
      (Terminais/editores que já estavam abertos precisam ser reiniciados.)
- [x] Rodar `flutter doctor --android-licenses` e aceitar as licenças.
- [x] Rodar `flutter doctor`: **Android toolchain** aparece sem erro (Android SDK 36.0.0).
      Os avisos de Chrome e Visual Studio só afetam web/desktop e podem ser ignorados.
- [x] Conferir a versão: Flutter **3.50.0** (stable), que atende o mínimo de 3.50.
      Quem for rodar o projeto (incluindo outros integrantes) precisa de uma versão igual ou mais nova.
- [x] Na raiz do repositório: `flutter pub get`, `flutter devices` (ID `emulator-5554`) e
      `flutter run -d emulator-5554`. O app abriu e o catálogo carregou.

> **Observação:** o `sdkmanager` atual repassa os comandos para o novo "Android CLI", que
> **não aceita `;`** nos nomes de pacote (use `/`, por exemplo `ndk/28.2.13676358`). Por isso o
> Gradle não conseguiu baixar o NDK sozinho no primeiro build, e ele foi instalado manualmente.
> Se outro integrante tiver o erro "sdkmanager did not install NDK", rode:
> `sdkmanager "ndk/28.2.13676358"`.
>
> Para abrir o emulador depois: `emulator -avd Pixel_API_36` (ou pelo Device Manager do
> Android Studio).

## 2. Prática guiada do Capítulo 10 (seções 1 a 9)

O README já descreve esses passos, mas eles **precisam ser feitos de verdade** e
comprovados com prints. O código de exemplo está em
`Informacoes/Cap10_Flutter_API_REST_Projetos.zip` → `Projeto_A_API_REST` (a pasta
`Informacoes/` só existe localmente, não vai para o GitHub).

- [x] Abrir `https://dummyjson.com/products?limit=12` no navegador e localizar a lista
      `products` e os campos `id`, `title` e `price`.
- [x] Criar um projeto separado (fora deste repositório) com o Projeto A, executar o
      catálogo e abrir a tela de detalhes de um produto.
- [x] Trocar `limit=12` por `limit=5` em `produtos_api_service.dart`, atualizar e conferir
      que aparecem **5 produtos**. → **Print 1**
- [x] Desligar a internet, pedir nova consulta e ver a mensagem de erro. → **Print 2**
- [x] Religar a internet e testar o botão **Tentar novamente**.
- [x] Salvar os prints com estes nomes exatos (o README já aponta para eles):
  - `docs/prints/pratica_cinco_produtos.png`
  - `docs/prints/pratica_erro_conexao.png`

> **Feito em 26/11/2026.** O Projeto A está em `C:\Users\Diego\dev\cap10_projeto_a`, já com
> `limit=5` e a permissão de INTERNET no Android. Rodou na versão **Web (Edge)**, porque ainda
> não havia Android SDK. A falta de conexão foi simulada só no navegador (modo offline), sem
> derrubar a rede do PC. Se quiserem prints do Android, basta rodar esse projeto no emulador
> depois da seção 1 e substituir os dois arquivos.

## 3. Testes de aceitação T1 a T7 (no Android) ✅ (concluído em 26/11/2026)

Executar **na ordem**, no app deste repositório, e preencher a tabela
"Testes de aceitação" do `README.md` (colunas **Resultado observado** e **Status**).

- [x] Antes de começar, **anotar os preços** dos dois produtos que serão usados e preencher
      a linha "Preços anotados no catálogo" no README.
- [x] **T1** — Com internet, abrir o catálogo e selecionar um produto → a lista carrega e os
      detalhes mostram o item escolhido.
- [x] **T2** — Sem rede, tocar em Atualizar → aparece a mensagem de erro. Religar a rede e tocar
      em **Tentar novamente** → o catálogo volta.
- [x] **T3** — Adicionar o mesmo produto duas vezes (a 2ª vez avisa "já está na lista") → em
      Minha lista há **uma linha** com quantidade 1.
- [x] **T4** — Adicionar um 2º produto. Mudar o 1º para 3 unidades. Tocar em "Qtd" e tentar
      gravar **0** e depois **100** → ambos rejeitados, quantidade continua 3 e o subtotal = 3 × preço.
- [x] **T5** — Marcar o 1º como comprado e ligar o filtro em Configurações → o 1º some, o total
      continua somando os dois. Desligar o filtro → o item volta marcado como comprado.
- [x] **T6** — Ligar o tema escuro e o filtro. **Fechar o app de verdade** (tirar dos recentes, sem
      limpar dados) e abrir pelo ícone → tema e filtro voltam. Desligar o filtro → 1º item continua
      comprado com quantidade 3.
- [x] **T7** — Sem rede, abrir Minha lista, editar um item, tocar em excluir e **Cancelar** (item
      fica), depois excluir e **Confirmar** (item sai e o total é atualizado).
- [x] Conferir as contas: subtotal = preço × quantidade; total = soma de todos os itens.
- [x] Se algum teste falhar, anotar o que aconteceu no README e corrigir antes da entrega.

> Todos os 7 testes passaram no emulador `Pixel_API_36`, com o APK release e partindo de dados
> limpos. Os resultados estão na tabela do README. Para cortar a rede foram usados
> `adb shell svc wifi disable` e `adb shell svc data disable`.

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
