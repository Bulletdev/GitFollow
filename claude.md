# Prompt para Claude Code: GitFollow - Analisador de Followers/Unfollows do GitHub

Crie um projeto completo chamado **GitFollow** - uma ferramenta CLI para análise de followers e unfollows do GitHub com CI/CD automatizado.

## Especificações do Projeto

### Tecnologia
- **Linguagem**: Ruby (sem Rails - use Ruby puro com gems necessárias)
- **Motivo**: Simplicidade para CLI, excelente para scripts, facilita distribuição via RubyGems

### Funcionalidades Core

1. **Rastreamento de Followers**
    - Detectar novos followers
    - Detectar unfollows
    - Histórico de mudanças com timestamps
    - Armazenar dados localmente (JSON ou SQLite)

2. **Notificações**
    - Opção de notificar via GitHub Issues/Discussion
    - Output formatado no terminal (tabelas coloridas)
    - Relatórios em Markdown

3. **CLI Completo**
    - `gitfollow init` - configuração inicial
    - `gitfollow check` - verificar mudanças
    - `gitfollow report` - gerar relatório
    - `gitfollow stats` - estatísticas gerais

### Estrutura do Projeto

gitfollow/ ├── .github/ │ └── workflows/ │ ├── ci.yml (testes, rubocop, etc) │ ├── daily-check.yml (execução diária automática) │ └── release.yml (publicação automática) ├── lib/ │ ├── gitfollow/ │ │ ├── client.rb (interação com API GitHub) │ │ ├── tracker.rb (lógica de rastreamento) │ │ ├── storage.rb (persistência de dados) │ │ ├── notifier.rb (notificações) │ │ └── cli.rb (interface linha de comando) │ └── gitfollow.rb ├── spec/ (testes RSpec) ├── bin/ │ └── gitfollow (executável) ├── .rubocop.yml ├── Gemfile ├── gitfollow.gemspec └── README.md ### Gems a Utilizar

- octokit - cliente GitHub API

- thor - framework CLI

- tty-table - tabelas formatadas

- tty-spinner - indicadores de progresso

- colorize - output colorido

- dotenv - configuração

- RSpec para testes

### GitHub Actions

**CI/CD Completo:**

1. **ci.yml**

    - Rodar em push/PR

    - Testes (RSpec)

    - Linting (RuboCop)

    - Coverage (SimpleCov)

    - Múltiplas versões Ruby (3.0, 3.1, 3.2, 3.3)

2. **daily-check.yml**

    - Executar diariamente às 9h UTC

    - Rodar gitfollow check

    - Criar Issue automaticamente se houver mudanças

    - Usar GitHub Secrets para token

3. **release.yml**

    - Trigger em tags (v*)

    - Build da gem

    - Publicar no RubyGems automaticamente

    - Criar GitHub Release com changelog

### README.md Completo

Incluir:

- **Badges**:

    - CI Status

    - Ruby Version

    - Gem Version

    - License

    - Code Coverage

    - Downloads



- **Seções**:

    - Descrição visual com exemplo de output

    - Instalação (gem install + manual)

    - Configuração (GitHub Token)

    - Uso detalhado de cada comando

    - Como configurar CI/CD no próprio repo

    - Exemplos práticos

    - Screenshot/GIF do funcionamento

    - Contribuindo

    - Licença (MIT)

### Requisitos de Segurança

- Token GitHub via variável de ambiente

- Nunca commitar credenciais

- Rate limiting respeitoso à API

- Instruções claras sobre permissions necessárias

### Features Extras (Implementar)

- Flag --json para output em JSON

- Comparação de mutual followers

- Estatísticas: ratio following/followers

- Export de relatórios (CSV, Markdown)

- Config file .gitfollow.yml opcional

### Testes

- Cobertura mínima de 80%

- Testar todos os comandos CLI

- Mock da API GitHub

- Testes de integração

### Qualidade de Código

- RuboCop configurado

- Documentação inline (YARD)

- Versionamento semântico

- CHANGELOG.md atualizado

## Output Esperado

Execute passo a passo:

1. Estruture o projeto completo

2. Implemente toda funcionalidade

3. Configure todos os workflows

4. Crie README exemplar com badges funcionais

5. Escreva testes abrangentes

6. Configure gemspec para publicação

O projeto deve estar 100% funcional e pronto para:

- gem build gitfollow.gemspec

- gem push gitfollow-X.X.X.gem

- Fork e uso imediato por outros desenvolvedores

Capriche nos detalhes, código limpo e profissional!