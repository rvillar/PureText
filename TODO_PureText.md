# TODO PureText

## Resumo Executivo

### Fase A

|     | Item | Descrição |
| --- | ---- | --------- |
| C   | 1    | Levantar requisitos funcionais da app PureText |
| C   | 2    | Analisar a estrutura inicial do projeto e o ambiente Swift disponível |
| C   | 3    | Analisar a referência do app Notepad para suporte a abertura de arquivos |
| C   | 4    | Definir a abordagem técnica inicial da app |

### Fase B

|     | Item | Descrição |
| --- | ---- | --------- |
| C   | 1    | Criar a estrutura base do projeto macOS em Swift |
| C   | 2    | Configurar a app como editor de arquivos texto compatíveis |
| C   | 3    | Preparar a interface minimalista com abas por arquivo |
| C   | 4    | Preparar a interface para acompanhar Light Mode e Dark Mode do macOS |

### Fase C

|     | Item | Descrição |
| --- | ---- | --------- |
| C   | 1    | Implementar abertura de arquivos `.txt`, `.csv`, `.json`, `.ljson`, `.xml` e `.html` |
| C   | 2    | Implementar gerenciamento de abas para arquivos abertos |
| C   | 3    | Implementar edição de texto simples sem formatação |
| C   | 4    | Implementar formatação de conteúdo conforme o tipo de arquivo |
| C   | 5    | Implementar salvamento e persistência do conteúdo |
| C   | 6    | Implementar integração para abrir arquivos arrastados sobre o ícone no Dock |
| C   | 7    | Garantir adaptação visual automática ao tema ativo do macOS |

### Fase D

|     | Item | Descrição |
| --- | ---- | --------- |
|     | 1    | Validar criação, abertura, edição e salvamento de documentos |
|     | 2    | Validar fluxo de múltiplas abas e troca entre arquivos |
|     | 3    | Validar formatação de conteúdo por tipo de arquivo |
|     | 4    | Validar associação e abertura de arquivos pelos tipos suportados |
|     | 5    | Validar aparência da interface com Light Mode e Dark Mode |
|     | 6    | Revisar comportamento básico e acabamento da aplicação |

### Fase E

|     | Item | Descrição |
| --- | ---- | --------- |
| C   | 1    | Atualizar este documento com evidências finais da implementação |
|     | 2    | Revisar documentação complementar do projeto, se necessário |

## Objetivo da Implementação

### Descrição detalhada da funcionalidade

Criar uma aplicação macOS em Swift chamada `PureText`, voltada para edição de texto não formatado. A aplicação deverá permitir criar, abrir, editar, formatar e salvar arquivos de texto simples, com foco em uma experiência enxuta e minimalista. A interface deverá trabalhar com abas, em que cada aba representa um arquivo aberto. A aplicação também deverá aceitar a abertura direta de arquivos ao serem arrastados sobre o ícone da aplicação no Dock. A implementação foi estruturada como aplicação AppKit empacotada em bundle `.app` por script local.

### Escopo da implementação

Inclui:

- criação do projeto macOS em Swift para a aplicação `PureText`;
- interface nativa minimalista para edição de texto simples;
- navegação por abas, com uma aba por arquivo aberto;
- adaptação automática da interface ao tema do macOS, respeitando Light Mode e Dark Mode;
- criação de um ícone original minimalista para a aplicação;
- suporte a abertura e salvamento de arquivos `.txt`, `.csv`, `.json`, `.ljson`, `.xml` e `.html`;
- ação de formatação do conteúdo conforme o tipo do arquivo aberto;
- suporte a abertura de arquivos por associação do sistema e por arraste sobre o ícone da aplicação no Dock;
- validação manual básica do fluxo de uso principal.

Não inclui neste momento:

- edição com formatação rica;
- recursos avançados como busca e substituição, autosave sofisticado ou histórico de versões;
- transformação semântica complexa de conteúdo além da formatação estrutural básica por tipo de arquivo;
- compatibilizações com comportamento legado além da referência funcional observada.

### Premissas, dependências e restrições relevantes

- o projeto principal envolvido é este repositório `PureText`;
- a implementação poderá ser feita com AppKit, combinando suporte nativo de documentos com uma camada própria de interface em abas;
- o ambiente local possui `Xcode 26.3` e `Swift 6.2.4`;
- a pasta do projeto está vazia no momento e a estrutura da aplicação precisará ser criada do zero;
- a referência observada no `Notepad.app` indica uso de tipos de documento registrados no `Info.plist`, o que reforça a adoção da abordagem document-based;
- a exigência de múltiplos arquivos em abas pode pedir adaptação do modelo document-based padrão para centralizar a experiência em uma única janela principal;
- a interface deve acompanhar o tema configurado no macOS sem exigir alternância manual dentro da aplicação;
- a funcionalidade de formatação deverá respeitar a estrutura textual do tipo de arquivo sem introduzir recursos de edição rica;
- até o momento não foi identificado comportamento legado a ser compatibilizado ou contornado.

### Critérios de aceite da funcionalidade

- a aplicação se chama `PureText` e abre normalmente no macOS;
- a aplicação apresenta uma interface minimalista com abas;
- cada aba representa um arquivo aberto e permite alternância clara entre os arquivos;
- cada aba oferece um botão `x` para fechamento direto do arquivo correspondente;
- a aplicação permite criar um documento vazio em nova aba com nome incremental `UntitleN` e editar texto simples sem formatação;
- quando um arquivo real é aberto, a aba exibe o nome curto do arquivo;
- a aplicação permite abrir arquivos existentes dos tipos `.txt`, `.csv`, `.json`, `.ljson`, `.xml` e `.html`;
- a aplicação oferece uma ação de formatação para organizar o conteúdo conforme o tipo do arquivo aberto;
- a formatação de `json` e `ljson` organiza objetos e atributos com indentação legível;
- a formatação de `xml` e `html` organiza o conteúdo pela hierarquia de tags com indentação legível;
- a aplicação permite salvar alterações no arquivo aberto;
- ao arrastar um arquivo suportado sobre o ícone da aplicação no Dock, o arquivo é aberto corretamente;
- os fluxos principais de abertura, edição e salvamento ficam operacionais sem dependências externas.
- a aplicação possui um ícone original minimalista, distinto da identidade visual do `Notepad.app`.
- a interface acompanha automaticamente o Light Mode e o Dark Mode do macOS com contraste e legibilidade adequados nos dois cenários.

## Fases da Implementação

### Fase A

- [C] 1. Levantar requisitos funcionais da app PureText
- [C] 2. Analisar a estrutura inicial do projeto e o ambiente Swift disponível
- [C] 3. Analisar a referência do app Notepad para suporte a abertura de arquivos
- [C] 4. Definir a abordagem técnica inicial da app

#### Levantamento executado na fase A1

- A aplicação deverá ser um editor simples de texto não formatado com nome `PureText`.
- Os formatos explicitamente pedidos foram `.txt`, `.csv`, `.json`, `.ljson`, `.xml` e `.html`.
- O fluxo de abertura por arraste no Dock é requisito funcional central.
- A interface deverá ser minimalista e organizada em abas, com uma aba por arquivo.
- A aplicação deverá acompanhar automaticamente o modo claro ou escuro ativo no macOS.
- A aplicação deverá oferecer formatação do conteúdo conforme a estrutura de cada tipo de arquivo suportado, com foco explícito em `json`, `ljson`, `xml` e `html`.

#### Análise executada na fase A2

- A pasta do projeto está vazia, portanto será necessário criar toda a base da aplicação.
- O ambiente local possui Xcode e Swift em versões atuais, suficientes para criar uma app macOS nativa.

#### Análise executada na fase A3

- A referência observada no `Notepad.app` registra tipos de documento no `Info.plist`.
- Isso indica uma implementação aderente ao comportamento nativo do macOS para abertura de documentos e associação de arquivos.

#### Decisão registrada na fase A4

- A abordagem inicial proposta é criar uma app macOS nativa em Swift usando AppKit com suporte de documentos e uma interface própria em abas.
- Essa abordagem tende a simplificar abertura por Dock e associação de tipos de arquivo, ao mesmo tempo em que permite uma experiência multiarquivo em uma única janela principal.
- A identidade visual da app deverá usar um ícone original, minimalista, inspirado na ideia de texto simples sem reaproveitar o ícone do `Notepad.app`.
- A interface deverá preferir cores e componentes nativos do macOS para herdar o comportamento correto de Light Mode e Dark Mode.
- A formatação deverá ser orientada por parser ou estrutura compatível com cada tipo suportado quando houver opção segura, evitando reordenações arbitrárias do conteúdo.

### Fase B

- [C] 1. Criar a estrutura base do projeto macOS em Swift
- [C] 2. Configurar a app como editor de arquivos texto compatíveis
- [C] 3. Preparar a interface minimalista com abas por arquivo
- [C] 4. Preparar a interface para acompanhar Light Mode e Dark Mode do macOS

#### Planejamento executado na fase B1

- Criar um projeto macOS com estrutura mínima para build local e organização adequada dos arquivos de código e recursos.

#### Planejamento executado na fase B2

- Declarar os tipos de documento suportados e configurar a aplicação para atuar como editor de `.txt`, `.csv`, `.json`, `.ljson`, `.xml` e `.html`.

#### Planejamento executado na fase B3

- Definir a janela principal, a barra de abas e o componente de edição de texto simples com foco em usabilidade básica e visual contido.

#### Planejamento executado na fase B4

- Definir a interface com componentes e cores que respeitem automaticamente a aparência do sistema, evitando dependência de tema manual.

#### Execução registrada na fase B1

- Foi criada a estrutura do projeto com `Sources/PureText`, `App/Info.plist`, `scripts/build_app.sh` e `Assets/PureTextIcon.png`.
- O build local passou a ser feito por `swiftc`, com empacotamento manual em `.artifacts/PureText.app`.
- A fundação da janela principal foi refeita para um modelo direto com `NSWindow` e `contentView` explícita, reduzindo a complexidade do ciclo de apresentação.

#### Execução registrada na fase B2

- O `Info.plist` foi configurado com associação para `public.plain-text`, `public.comma-separated-values-text`, `public.json`, `public.xml`, `public.html` e `com.fnt.puretext.ljson`.
- Foi declarada a UTI customizada `com.fnt.puretext.ljson` para suportar extensão `.ljson`.

#### Execução registrada na fase B3

- A interface principal foi implementada com `NSTabViewController` em estilo segmentado no topo, uma aba por arquivo e toolbar minimalista para nova aba, abrir, salvar e formatar.
- A barra de abas foi evoluída para uma implementação própria com seleção por clique e botão `x` por aba para fechamento direto do arquivo.

#### Execução registrada na fase B4

- O editor usa `NSColor`, `NSTextView`, `NSScrollView` e demais componentes nativos, herdando automaticamente o tema claro ou escuro do sistema.

### Fase C

- [C] 1. Implementar abertura de arquivos `.txt`, `.csv`, `.json`, `.ljson`, `.xml` e `.html`
- [C] 2. Implementar gerenciamento de abas para arquivos abertos
- [C] 3. Implementar edição de texto simples sem formatação
- [C] 4. Implementar formatação de conteúdo conforme o tipo de arquivo
- [C] 5. Implementar salvamento e persistência do conteúdo
- [C] 6. Implementar integração para abrir arquivos arrastados sobre o ícone no Dock
- [C] 7. Garantir adaptação visual automática ao tema ativo do macOS

#### Estratégia executada na fase C1

- Modelar o documento como texto puro e carregar o conteúdo dos formatos suportados como texto bruto.

#### Estratégia executada na fase C2

- Representar cada arquivo aberto como uma aba independente, preservando estado de conteúdo, título e alteração pendente.

#### Estratégia executada na fase C3

- Utilizar um componente nativo de texto para edição sem recursos rich text.

#### Estratégia executada na fase C4

- Implementar uma ação de formatação por tipo de arquivo, com foco em indentação legível para `json`, `ljson`, `xml` e `html`, preservando `txt` e `csv` sem transformação estrutural automática por padrão.

#### Estratégia executada na fase C5

- Persistir o conteúdo com encoding apropriado para texto simples, respeitando o arquivo aberto.

#### Estratégia executada na fase C6

- Apoiar a abertura por Dock na infraestrutura de documentos do macOS e validar o fluxo com arquivos reais suportados.

#### Estratégia executada na fase C7

- Priorizar `NSColor`, materiais e componentes nativos para que o editor acompanhe a mudança de aparência do sistema com o menor acoplamento possível.

#### Execução registrada na fase C1

- A abertura de arquivos foi implementada via `NSOpenPanel`, leitura de conteúdo textual e detecção de tipo por extensão.
- Os formatos suportados no código são `.txt`, `.csv`, `.json`, `.ljson`, `.xml` e `.html`.

#### Execução registrada na fase C2

- Cada arquivo aberto passa a ser representado por uma instância de `EditorDocument` e uma aba correspondente em `EditorTabViewController`.
- A aplicação evita abrir o mesmo arquivo em abas duplicadas, selecionando a aba já existente quando necessário.
- Novas abas criadas sem arquivo recebem nome incremental `UntitleN`.
- Arquivos abertos por URL usam o nome curto do próprio arquivo na aba.

#### Execução registrada na fase C3

- O editor foi implementado com `NSTextView` em modo plain text, com fonte monoespaçada, undo, busca nativa e sem rich text.

#### Execução registrada na fase C4

- A formatação de `json` usa `JSONSerialization` com indentação e ordenação de chaves.
- A formatação de `ljson` suporta tanto um JSON único quanto objetos JSON por linha.
- A formatação de `xml` e `html` foi implementada por hierarquia de tags, com indentação estrutural e preservação de texto simples entre tags.

#### Execução registrada na fase C5

- O fluxo de salvar e salvar como foi implementado com `NSSavePanel`, preservando URL, tipo e estado de edição do documento.

#### Execução registrada na fase C6

- A aplicação responde a `application(_:openFiles:)`, o que prepara o fluxo de abertura por associação do sistema e por arraste sobre o ícone no Dock quando o bundle `.app` é usado.
- O script `scripts/build_app.sh` gera `.artifacts/PureText.app` com `Info.plist`, `Assets.car` e `AppIcon.icns`.

#### Execução registrada na fase C7

- O editor aplica `textBackgroundColor`, `textColor` e demais cores do sistema, permitindo adaptação automática entre Light Mode e Dark Mode.

### Fase D

- [ ] 1. Validar criação, abertura, edição e salvamento de documentos
- [ ] 2. Validar fluxo de múltiplas abas e troca entre arquivos
- [ ] 3. Validar formatação de conteúdo por tipo de arquivo
- [ ] 4. Validar associação e abertura de arquivos pelos tipos suportados
- [ ] 5. Validar aparência da interface com Light Mode e Dark Mode
- [ ] 6. Revisar comportamento básico e acabamento da aplicação

#### Planejamento executado na fase D1

- Executar testes manuais cobrindo novo documento, abrir arquivo existente, editar e salvar.

#### Planejamento executado na fase D2

- Verificar abertura simultânea de múltiplos arquivos, criação de novas abas e alternância entre conteúdos.

#### Planejamento executado na fase D3

- Verificar a formatação de `json`, `ljson`, `xml` e `html`, confirmando indentação coerente com objetos, atributos e hierarquia de tags.

#### Planejamento executado na fase D4

- Verificar a abertura da aplicação ao receber arquivos suportados, inclusive por arraste no ícone do Dock.

#### Planejamento executado na fase D5

- Verificar contraste, legibilidade e aparência geral da interface com o modo escuro ativado e desativado no macOS.

#### Planejamento executado na fase D6

- Revisar rótulos, comportamento inicial da janela e eventuais ajustes de estabilidade básica.

### Fase E

- [C] 1. Atualizar este documento com evidências finais da implementação
- [ ] 2. Revisar documentação complementar do projeto, se necessário

#### Manutenção planejada na fase E1

- Sincronizar o resumo executivo com o progresso real e registrar decisões relevantes ao longo da execução.

#### Evidência registrada na fase E1

- A compilação do executável foi validada com `swiftc Sources/PureText/*.swift -framework AppKit -framework UniformTypeIdentifiers -o .artifacts/PureText`.
- O empacotamento da aplicação foi validado com `./scripts/build_app.sh`, gerando `.artifacts/PureText.app`.
- O bundle resultante contém `Contents/MacOS/PureText`, `Contents/Info.plist`, `Contents/Resources/Assets.car` e `Contents/Resources/AppIcon.icns`.
- O fluxo inicial foi ajustado para abrir uma aba nova apenas quando a aplicação inicia sem arquivos recebidos do sistema.
- A validação interativa da interface, do fluxo de Dock e do comportamento visual em Light Mode e Dark Mode ainda depende de execução manual no macOS.

#### Manutenção planejada na fase E2

- Revisar se haverá arquivos adicionais de documentação a manter após a entrega.

## Manutenção do documento

Este arquivo deverá ser revisado e atualizado durante todo o ciclo de vida da implementação. Sempre que houver alteração de escopo, requisitos, critérios de aceite, priorização, estratégia de execução ou evolução das atividades, o conteúdo deverá ser ajustado para refletir a situação atual do projeto. O resumo executivo e as listas detalhadas das fases devem permanecer sincronizados em todas as atualizações.
