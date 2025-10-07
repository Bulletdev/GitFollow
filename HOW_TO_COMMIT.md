# Como Fazer os Commits - GitFollow

Você tem 3 opções para fazer os commits organizados:

## 🚀 Opção 1: Script Automatizado (Recomendado)

Faz todos os 22 commits automaticamente de uma vez:

```bash
./commit-all.sh
```

Depois de rodar o script:
```bash
# Adicionar remote
git remote add origin git@github.com:bulletdev/gitfollow.git

# Push
git push -u origin main

# Criar tag
git tag -a v0.1.0 -m "GitFollow v0.1.0 - Initial release"
git push origin v0.1.0
```

## 📋 Opção 2: Copiar e Colar Manual

Abra o arquivo `COMMIT_COMMANDS.txt` e copie os comandos um por um no terminal.

**Vantagem:** Você pode pular alguns commits ou reorganizar a ordem.

```bash
# Abrir o arquivo para copiar
cat COMMIT_COMMANDS.txt

# Ou visualizar no editor
nano COMMIT_COMMANDS.txt
```

## 📖 Opção 3: Seguir o Guia Completo

Leia o `COMMIT_GUIDE.md` que tem explicações detalhadas sobre cada commit e customize conforme necessário.

```bash
# Ler o guia
cat COMMIT_GUIDE.md

# Ou abrir no editor
nano COMMIT_GUIDE.md
```

## 🔍 Verificar Status

Depois dos commits:

```bash
# Ver lista de commits
git log --oneline

# Ver total de commits
git log --oneline | wc -l

# Ver status
git status

# Ver último commit
git show
```

## 🎯 Estrutura dos Commits

Os 22 commits estão organizados assim:

1. **Setup** (1-2): Configuração inicial
2. **Core** (3-7): Funcionalidades principais (Client, Storage, Tracker, Notifier, CLI)
3. **Tests** (8-12): Testes RSpec completos
4. **CI/CD** (13-15): GitHub Actions workflows
5. **Config** (16): RuboCop
6. **Docs** (17-21): README, CONTRIBUTING, CHANGELOG, LICENSE, exemplos
7. **Final** (22): Preparação para release

## ⚠️ Importante

- Se você já tem um repositório Git iniciado, o script vai pular o `git init`
- Commits duplicados serão automaticamente ignorados
- Certifique-se de estar na pasta raiz do projeto
- Tenha certeza que todos os testes passam antes de commitar

## 🐛 Troubleshooting

### Erro: "nothing to commit"
```bash
# Verificar se os arquivos existem
ls -la

# Ver o que está para ser commitado
git status
```

### Erro: "remote origin already exists"
```bash
# Remover remote existente
git remote remove origin

# Adicionar novamente
git remote add origin git@github.com:bulletdev/gitfollow.git
```

### Ver diferenças antes de commitar
```bash
# Ver mudanças não commitadas
git diff

# Ver mudanças que serão commitadas
git diff --staged
```

### Desfazer último commit (se necessário)
```bash
# Manter as mudanças
git reset --soft HEAD~1

# Descartar as mudanças (CUIDADO!)
git reset --hard HEAD~1
```

## 📦 Após os Commits

1. **Criar repositório no GitHub** (se ainda não criou)
   - Acesse: https://github.com/new
   - Nome: `gitfollow`
   - Descrição: "Track GitHub followers and unfollows with ease"
   - Público ou Privado (sua escolha)
   - **NÃO** inicialize com README, .gitignore ou license

2. **Push para GitHub**
   ```bash
   git remote add origin git@github.com:bulletdev/gitfollow.git
   git push -u origin main
   ```

3. **Criar Release Tag**
   ```bash
   git tag -a v0.1.0 -m "GitFollow v0.1.0"
   git push origin v0.1.0
   ```

4. **Configurar GitHub Secrets** (para workflows)
   - Settings → Secrets and variables → Actions
   - Adicionar: `RUBYGEMS_API_KEY` (se quiser publicar automaticamente)

## 🎉 Pronto!

Depois disso seu projeto estará no GitHub com:
- ✅ Histórico organizado de commits
- ✅ Tag de release v0.1.0
- ✅ CI/CD configurado
- ✅ Documentação completa
- ✅ Pronto para ser usado e compartilhado!
