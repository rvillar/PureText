# PureTextiOS

Estrutura reservada para o futuro app PureText em iOS e iPadOS.

## Primeira entrega funcional mínima

- Abrir arquivos de texto puro a partir do app Arquivos usando componentes nativos do iOS.
- Editar um documento por vez com comportamento estritamente texto puro.
- Salvar no mesmo arquivo após edição.
- Reaproveitar `PureTextCore` para tipo de arquivo, estado do documento e formatação suportada.

## Escopo inicial previsto

- Tipos de arquivo: os mesmos já reconhecidos por `PureTextCore`, evitando divergência funcional desnecessária entre macOS e iOS.
- Formatação: somente para tipos já suportados por `DocumentFormatter`, sem lógica específica de plataforma.
- Interface: foco em uma experiência simples de documento único, sem replicar nesta primeira entrega recursos hoje específicos do macOS, como múltiplas abas visuais, lista de recentes e integração com Dock.

## Fluxos nativos planejados

### Abertura de arquivo

- O app deve oferecer abertura pelo app Arquivos e por importação explícita dentro da própria interface.
- A seleção de arquivo deve filtrar `NoteFileType.supportedContentTypes`, mantendo alinhamento direto com o `PureTextCore`.
- O fluxo preferencial é usar componentes nativos de documento do iOS para receber a `URL`, abrir acesso ao arquivo e carregar o conteúdo em um `EditorDocument`.

### Edição

- A interface inicial deve editar um único `EditorDocument` por vez.
- O editor deve permanecer estritamente em texto puro, sem recursos de rich text, anexos ou substituições automáticas que alterem o conteúdo sem intenção do usuário.
- O estado de edição, nome exibido, tipo de arquivo e indicação de alterações pendentes devem derivar do próprio `EditorDocument`.
- A primeira versão do iOS não deve reproduzir a barra de abas do macOS; a troca entre documentos deve acontecer fora do editor principal, por meio de um fluxo simples de abertura e retomada de documento.

### Salvamento

- Quando o arquivo já tiver origem conhecida, o app deve salvar de volta na mesma `URL`.
- Quando a origem ainda não existir, o app deve acionar um fluxo nativo de exportação ou criação de documento compatível com os tipos suportados.
- Após gravação bem-sucedida, o estado persistido deve ser sincronizado com `markSaved` no `EditorDocument`.
- O iOS não deve forçar salvamento manual contínuo apenas por não usar abas; durante a sessão, o documento pode permanecer em memória como no macOS.
- Para reduzir risco de perda por suspensão ou encerramento do app, a implementação deve prever persistência local de rascunho da sessão quando o documento ainda não tiver sido salvo definitivamente ou quando houver alterações pendentes relevantes.

### Documento sem origem persistida

- Um documento novo deve nascer como documento em memória, sem `URL` definitiva e com comportamento equivalente a um untitled do macOS.
- O tipo inicial recomendado para esse documento é `txt`, com possibilidade de o usuário mudar a extensão no primeiro fluxo explícito de exportação ou salvamento definitivo.
- Enquanto o documento não tiver destino final, o app deve preservar o conteúdo por meio do `EditorDocument` em memória e por rascunho local de recuperação da sessão.
- Ao escolher salvar pela primeira vez, o app deve abrir um fluxo nativo de criação ou exportação para que o usuário escolha nome, destino e extensão final do arquivo.
- Se o usuário cancelar esse primeiro salvamento, o documento deve continuar aberto em memória e com rascunho recuperável, sem descarte automático.
- Depois do primeiro salvamento bem-sucedido, o documento passa a ter `URL` persistida e os próximos salvamentos devem voltar para o mesmo arquivo.

### Formatação

- A ação de formatar deve aparecer somente quando `document.fileType.isFormattingSupported` for verdadeiro.
- O conteúdo formatado deve ser gerado exclusivamente por `DocumentFormatter`, preservando a mesma regra funcional entre macOS e iOS.

### Tratamento de alterações não salvas

- Ao sair do documento, trocar de arquivo ou encerrar o app, o iOS deve respeitar o estado `isEdited` do `EditorDocument`.
- A primeira implementação deve priorizar um fluxo claro de confirmar, salvar ou cancelar antes de descartar alterações locais.
- Sempre que o app for para background ou entrar em ponto de risco do ciclo de vida do iOS, o estado editado deve poder ser recuperado a partir do rascunho local da sessão, sem alterar silenciosamente o arquivo definitivo do usuário.

## Decisões de implementação para a futura UI

- Evitar dependência de comportamentos específicos de AppKit.
- Preferir uma camada fina de UI que orquestre abertura, edição e salvamento, deixando regras de documento no `PureTextCore`.
- Não introduzir armazenamento paralelo, banco local ou cache proprietário nesta primeira entrega sem necessidade comprovada.

## Arquitetura técnica recomendada

### Base da interface

- Usar SwiftUI como base da app iOS e iPadOS para ciclo de vida, navegação, toolbar e composição das telas.
- Isolar integrações nativas mais sensíveis em pontes pequenas para UIKit apenas quando isso simplificar o comportamento de documento ou do editor.

### Editor de texto

- Preferir um `UITextView` encapsulado em `UIViewRepresentable` para a área de edição principal.
- Essa escolha preserva melhor o controle de texto puro, resposta de teclado, undo e futuras evoluções de seleção e formatação, sem acoplar o `PureTextCore` à camada visual.
- O `EditorDocument` deve continuar como fonte de verdade do conteúdo e do estado salvo, e a view deve apenas sincronizar alterações de ida e volta.

### Fluxo de documentos

- Usar SwiftUI para a estrutura principal da tela e acionar fluxos nativos de importação e exportação a partir dela.
- Quando o fluxo nativo de arquivo exigir mais controle, usar ponte pontual com APIs de documento do UIKit em vez de levar essa complexidade para o `PureTextCore`.
- Toda lógica de leitura, gravação, controle de acesso à `URL` e confirmação de descarte deve ficar na camada do app iOS.

### Modelo de sessão recomendado

- Tratar a primeira versão do iOS como experiência de documento único ativo por vez.
- Permitir edição em memória durante a sessão, sem obrigar salvamento definitivo a cada troca de contexto.
- Usar rascunho local de recuperação como proteção contra suspensão, encerramento inesperado e retomada de sessão.
- Reservar uma evolução futura para iPad com alternância entre documentos abertos por lista ou sidebar, e não por cópia direta da barra de abas do macOS.

### Camadas sugeridas

- `PureTextCore`: tipos de arquivo, estado de documento e formatação compartilhada.
- `PureTextiOS/App`: entrada da app, ciclo de vida e composição das cenas.
- `PureTextiOS/Features/Editor`: tela principal, toolbar e estado da sessão atual.
- `PureTextiOS/Infrastructure/Documents`: leitura, gravação, importação, exportação e integração com APIs nativas de documento.
- `PureTextiOS/UI`: componentes visuais reutilizáveis e ponte para UIKit quando necessário.

## Estrutura inicial recomendada do projeto

- Criar o app iOS em `Apps/PureTextiOS/` como projeto separado dentro do mesmo repositório.
- Manter o nome público do app como `PureText`.
- Usar um nome técnico interno como `PureTextiOS` para o diretório, target e organização dos arquivos.
- Adicionar um target de app iOS próprio, com dependência explícita do pacote local `Packages/PureTextCore`.
- Declarar no app iOS os mesmos tipos de documento já reconhecidos no macOS e no core, para manter coerência com o app Arquivos e com os fluxos de importação e exportação.

## Bundle e distribuição recomendados

- Reservar um bundle identifier próprio para iOS, separado do macOS, mantendo a mesma marca pública do produto.
- Nesta fase inicial, priorizar assinatura local e instalação direta no aparelho pessoal via Xcode.
- Adiar a criação de pipeline de distribuição externa até que o app iOS esteja funcional e pronto para uso além do ambiente pessoal.
- Preparar o app iOS para futura assinatura e distribuição por TestFlight sem alterar o fluxo atual de release do macOS.
- Manter valores locais de assinatura, team e bundle identifier de publicação em `Config/Local.xcconfig`, que não deve ser enviado ao GitHub.
- Manter qualquer futura credencial de App Store Connect, chave de automação ou configuração pessoal de distribuição fora dos arquivos versionados.

## Versionamento e publicação planejados

- O iOS deve compartilhar a mesma versão pública do produto `PureText` usada no macOS.
- O contador de build interno do iOS deve ser independente do contador de build interno do macOS.
- O código-fonte continua versionado por uma única tag Git por release pública do produto.
- Nesta etapa, a distribuição do iOS deve acontecer apenas por instalação local via Xcode no aparelho pessoal.
- TestFlight e App Store Connect ficam reservados para uma etapa futura de distribuição externa, sem alterar por enquanto o fluxo atual de publicação do macOS no GitHub Releases.

## Configuração local segura

- O repositório versiona `Config/Shared.xcconfig` e `Config/Local.example.xcconfig`.
- `Config/Shared.xcconfig` deve permanecer com valores genéricos seguros para o repositório.
- O arquivo real `Config/Local.xcconfig` fica apenas na máquina local e é ignorado pelo Git.
- Esse arquivo local deve concentrar `bundle identifier` pessoal, `development team` e outras escolhas de assinatura que não devam ser publicadas no GitHub.

## Fluxo atual recomendado

- Nesta etapa, o fluxo principal do iOS é instalação direta no iPhone pelo Xcode.
- Abra `Apps/PureTextiOS/PureTextiOS.xcodeproj`, selecione o aparelho e use `Product > Run`.
- `Config/Local.xcconfig` continua sendo o ponto central para assinatura local e uso pessoal.
- O uso de archive é opcional e mais útil para validação interna do que para o ciclo diário de testes no aparelho.

## Archive local opcional

- Para gerar um archive local sem colocar credenciais no repositório, use `./scripts/archive_ios_app.sh`.
- O archive é salvo em `.artifacts/ios/archives/`.

## Preparação futura para App Store

- O fluxo recomendado de publicação fica documentado em `docs/ios-app-store-release.md`.
- Um modelo simples de metadados para a ficha da App Store fica em `docs/ios-app-store-metadata-template.md`.
- Para executar o fluxo futuro de exportação orientado ao App Store Connect com um `ExportOptions.local.plist` mantido fora do Git, use `./scripts/export_ios_archive.sh`.
- O resultado da exportação é salvo em `.artifacts/ios/export/`, mas o comportamento depende do método configurado no arquivo local de exportação.
- Chaves `AuthKey_*.p8`, perfis `.mobileprovision` e arquivos locais de exportação devem permanecer fora do Git.

## Fora do escopo inicial

- Múltiplas abas abertas ao mesmo tempo com barra visual equivalente ao macOS.
- Menu completo equivalente ao macOS.
- Recursos de janela e fluxos dependentes de AppKit.
- Camadas de compatibilização ou tratamento legado sem decisão explícita.
