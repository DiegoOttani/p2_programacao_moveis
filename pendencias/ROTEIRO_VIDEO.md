# Roteiro do vídeo — P2 Flutter (até 5 minutos)

**Meta: cerca de 4 minutos**, para sobrar folga. Gravar no emulador ou no celular Android.

## Antes de gravar

- [ ] App instalado no Android (`flutter run -d ID_DO_ANDROID`) e funcionando.
- [ ] **Começar com a lista vazia e o tema claro**: desinstalar e reinstalar o app, ou
      *Configurações do Android → Apps → Minha Lista de Compras → Armazenamento → Limpar dados*.
- [ ] Filtro "Mostrar somente pendentes" **desligado**.
- [ ] Internet **ligada**.
- [ ] Gravador de tela pronto: no emulador, use o botão de gravação dos *Extended controls* (⋯);
      no celular, use o gravador de tela do sistema. O OBS no PC também serve.
- [ ] Saber como ligar o **modo avião** rápido (painel de notificações).
- [ ] Ensaiar uma vez sem gravar.

Produtos usados no exemplo (os dois primeiros do catálogo): **Produto 1 = Essence Mascara
Lash Princess (US$ 9.99)** e **Produto 2 = Eyeshadow Palette with Mirror (US$ 19.99)**.
Confira os preços na tela; se forem outros, ajuste as contas abaixo.

---

## Cena 1 — Abertura (0:00–0:15)

**Tela:** app aberto na aba **Catálogo**.

> "Este é o app Minha Lista de Compras, da P2 de Flutter. Ele consulta um catálogo pela
> API REST da DummyJSON, salva a lista no SQLite e guarda as preferências no
> SharedPreferences."

## Cena 2 — Catálogo e detalhes (0:15–0:45)

1. Mostrar o catálogo carregado (rolar um pouco a lista).
2. Tocar no **Produto 1** → tela **Detalhes** (imagem, título, código, preço, descrição).

> "O catálogo vem da API. Ao tocar num produto, abrimos os detalhes com os dados
> recebidos no JSON."

## Cena 3 — Incluir item (0:45–1:05)

1. Em Detalhes, tocar em **Adicionar à lista** → aviso *"… foi adicionado à lista."*

> "O produto foi gravado no banco local."

## Cena 4 — Ausência de duplicata (1:05–1:35)

1. Tocar **de novo** em **Adicionar à lista** → aviso *"… já está na lista. O item existente
   foi mantido."*
2. Voltar, abrir o **Produto 2** e adicionar (para a lista ter dois itens).
3. Abrir a aba **Minha lista**: o Produto 1 aparece **uma única vez**, com **Qtd: 1**.

> "Mesmo tocando duas vezes, não há duplicata: existe uma linha só, com quantidade 1."

## Cena 5 — Editar o item (1:35–2:20)

1. No Produto 1, tocar em **+** duas vezes → **Qtd: 3**.
2. Mostrar o subtotal: **3 × 9.99 = US$ 29.97**.
3. *(Opcional, se der tempo)* tocar em **Qtd**, digitar **0** → rejeitado; **Cancelar**.
4. Marcar o **checkbox** do Produto 1 → título riscado e etiqueta **Comprado**.
5. Mostrar o **Total estimado**: 29.97 + 19.99 = **US$ 49.96**.

> "Altero a quantidade, o subtotal é recalculado e marco o item como comprado. O total
> soma todos os itens."

## Cena 6 — Tema e filtro (2:20–2:50)

1. Aba **Configurações** → ligar **Tema escuro** (o app inteiro muda).
2. Ligar **Mostrar somente pendentes**.
3. Voltar para **Minha lista**: só o Produto 2 aparece, com o aviso *"Filtro ativo: mostrando
   somente pendentes"*. O total **continua US$ 49.96**.

> "O filtro esconde os comprados, mas o total continua considerando todos os itens."

## Cena 7 — Fechar e reabrir (2:50–3:25)

1. Abrir a tela de **apps recentes** do Android e **arrastar o app para fora** (fechar de
   verdade, sem limpar dados).
2. Abrir de novo pelo **ícone**.
3. Mostrar: **tema escuro** mantido, **filtro** ligado e a lista com o Produto 2.
4. Em Configurações, **desligar o filtro** → o Produto 1 volta: **Comprado**, **Qtd: 3**.

> "Fechei o app de verdade e, ao reabrir, o tema, o filtro e a lista foram restaurados."

## Cena 8 — Uso sem conexão (3:25–4:05)

1. Ligar o **modo avião** (mostrar o ícone na barra de status).
2. Aba **Minha lista**: a lista continua lá.
3. Editar um item (ex.: **+** no Produto 2 → Qtd: 2; o total vira 29.97 + 39.98 = **US$ 69.95**).
4. *(Opcional)* Tocar na lixeira → **Cancelar** (item fica) → lixeira → **Excluir** (item sai,
   total atualiza).
5. *(Opcional)* Ir ao **Catálogo** e tocar em **Atualizar** → mensagem de erro; desligar o modo
   avião → **Tentar novamente** → catálogo volta.

> "Sem internet, a lista continua disponível e editável, porque está salva no aparelho."

## Cena 9 — Encerramento (4:05–4:15)

> "Esse é o app Minha Lista de Compras. Obrigado."

---

## Depois de gravar

- [ ] Conferir se o vídeo tem **menos de 5 minutos** e se dá para ler o texto na tela.
- [ ] Subir como **YouTube não listado** ou no **Google Drive** com *"Qualquer pessoa com o
      link pode ver"*.
- [ ] **Abrir o link numa aba anônima** para conferir o acesso.
- [ ] Colar o link na tabela "Identificação" do `README.md`.
