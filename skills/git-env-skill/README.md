# git-env-skill

A reusable skill that automates setting up a new Git identity environment on macOS — including folder structure, per-identity gitconfig, SSH config, and optional key generation.

Designed for developers who work across multiple Git accounts (personal, multiple companies) and use folder-based identity isolation.

---

## What It Does

Given a new environment name (e.g. `acme`), it:

| Step | Action |
|------|--------|
| 1 | Creates `~/repos/acme-repos/` |
| 2 | Creates `~/.gitconfig-acme` with the provided name/email |
| 3 | Appends an `[includeIf]` block to `~/.gitconfig` |
| 4 | Appends a `Host` block to `~/.ssh/config` |
| 5 | Optionally generates an `ed25519` SSH key and adds it to the agent |
| 6 | Prints next steps: how to upload the key, test SSH, and clone repos |

All operations are **idempotent** — safe to re-run without duplicating or overwriting.

---

## Project Structure

```
git-env-skill/
├── skill.md       # Skill definition: triggers, inputs, flow, validation rules
├── add-env.sh     # Bash script — the actual implementation
└── README.md      # This file
```

---

## Prerequisites

- macOS (or Linux with standard bash)
- `ssh-keygen` available (standard on macOS)
- `~/.gitconfig` already exists (or the script will create it)
- Git installed

---

## Installation

1. Clone or copy this folder anywhere:

```bash
cp -r git-env-skill ~/tools/git-env-skill
```

2. Make the script executable:

```bash
chmod +x ~/tools/git-env-skill/add-env.sh
```

3. (Optional) Add an alias to your shell profile (`~/.zshrc` or `~/.bashrc`):

```bash
alias git-add-env="~/tools/git-env-skill/add-env.sh"
```

Then reload:

```bash
source ~/.zshrc
```

---

## Usage

### Interactive mode

Run without arguments — the script will prompt for each required value:

```bash
./add-env.sh
```

### With flags

```bash
./add-env.sh \
  --env acme \
  --email dev@acme.com \
  --provider github \
  --key id_ed25519_acme \
  --gen-key
```

### Flags

| Flag | Short | Required | Description |
|------|-------|----------|-------------|
| `--env` | `-e` | ✅ | Environment name (lowercase, no spaces) |
| `--email` | `-m` | ✅ | Git email for this identity |
| `--provider` | `-p` | ✅ | `github` or `azure` |
| `--key` | `-k` | ✅ | SSH key filename (e.g. `id_ed25519_acme`) |
| `--gen-key` | `-g` | ❌ | Generate the SSH key automatically |
| `--dry-run` | `-d` | ❌ | Preview all changes without applying them |
| `--help` | `-h` | ❌ | Show usage |

---

## Examples

### Add a GitHub identity for a new company

```bash
./add-env.sh \
  --env acme \
  --email silvana@acme.com \
  --provider github \
  --key id_ed25519_acme \
  --gen-key
```

**What gets created:**

```
~/repos/acme-repos/                  ← new repos go here

~/.gitconfig-acme                    ← new identity config
  [user]
    name = Acme
    email = silvana@acme.com
  [core]
    sshCommand = ssh -i ~/.ssh/id_ed25519_acme -F /dev/null

~/.gitconfig                         ← appended:
  [includeIf "gitdir:~/repos/acme-repos/"]
    path = ~/.gitconfig-acme

~/.ssh/config                        ← appended:
  Host github-acme
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_acme
    IdentitiesOnly yes

~/.ssh/id_ed25519_acme               ← generated SSH key
~/.ssh/id_ed25519_acme.pub
```

### Add an Azure DevOps identity

```bash
./add-env.sh \
  --env aldevron \
  --email silvana@aldevron.com \
  --provider azure \
  --key id_ed25519_aldevron \
  --gen-key
```

### Preview without applying (dry-run)

```bash
./add-env.sh \
  --env acme \
  --email silvana@acme.com \
  --provider github \
  --key id_ed25519_acme \
  --dry-run
```

---

## After Running the Script

### 1. Upload your public SSH key

```bash
cat ~/.ssh/id_ed25519_acme.pub
```

- **GitHub:** https://github.com/settings/ssh/new
- **Azure DevOps:** https://dev.azure.com/\<your-org\>/_usersSettings/keys

### 2. Test your SSH connection

```bash
# GitHub
ssh -T github-acme

# Azure DevOps
ssh -T azure-aldevron
```

Expected output for GitHub:
```
Hi <username>! You've successfully authenticated, but GitHub does not provide shell access.
```

### 3. Clone using the SSH alias

Always use the **alias**, never the raw domain:

```bash
# GitHub
git clone github-acme:<org>/<repo>.git ~/repos/acme-repos/<repo>

# Azure DevOps
git clone azure-aldevron:v3/<org>/<project>/<repo> ~/repos/aldevron-repos/<repo>
```

### 4. Verify the identity inside a repo

```bash
cd ~/repos/acme-repos/<repo>
git config user.email
# → silvana@acme.com
```

---

## How Existing Setup Looks

This skill is designed to complement an existing multi-identity layout:

```
~/.gitconfig
~/.gitconfig-personal
~/.gitconfig-sunny
~/.gitconfig-aldevron
~/.gitconfig-<new-env>       ← added by this skill

~/repos/
  ├── personal-repos/
  ├── sunny-repos/
  ├── aldevron-repos/
  └── <new-env>-repos/       ← added by this skill

~/.ssh/config
  Host github-personal        ← pre-existing
  Host github-sunny           ← pre-existing
  Host azure-aldevron         ← pre-existing
  Host <provider>-<new-env>   ← added by this skill
```

---

## Safety

- ❌ Will NOT overwrite `~/.gitconfig-<env>` if it already exists
- ❌ Will NOT duplicate `includeIf` blocks in `~/.gitconfig`
- ❌ Will NOT duplicate SSH `Host` blocks in `~/.ssh/config`
- ❌ Will NOT overwrite an existing SSH key
- ✅ Will create `~/.ssh/config` or `~/.gitconfig` if missing
- ✅ Fully idempotent — safe to run multiple times

---

## Skill Definition

See [`skill.md`](./skill.md) for the full skill specification including trigger conditions, input schema, step-by-step flow, and validation rules.
