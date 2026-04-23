---
name: git-env-skill
description: Set up a new Git identity environment on macOS — creates the repos folder, per-identity gitconfig, SSH config Host alias, and optionally generates the SSH key. Use this skill whenever a user needs to add a new Git account, onboard a new client or company identity, configure a separate work or personal Git profile, set up SSH for a new GitHub or Azure DevOps account, or isolate Git identities by folder. Trigger even if the user only mentions "new git account", "work git setup", "separate SSH key for company", or "configure git for a new client".
allowed-tools: Bash
---

# Git Environment Setup Skill

**Audience:** Developers using multiple Git identities (personal + multiple companies/clients) on macOS, with folder-based identity isolation via `~/.gitconfig` `includeIf`.

**Goal:** Automate the full setup of a new Git environment — repos folder, identity gitconfig, SSH Host alias, and optional key generation — safely and idempotently.

**Script:** `scripts/add-env.sh`

---

## Inputs

### Required

| Flag | Description | Validation |
|------|-------------|------------|
| `--env` | Short environment name (e.g. `acme`) | Lowercase, `[a-z0-9_-]+`, no spaces |
| `--email` | Git email for this identity | Valid email format |
| `--provider` | Git hosting provider | `github` or `azure` only |
| `--key` | SSH key filename (e.g. `id_ed25519_acme`) | Non-empty |

### Optional

| Flag | Description | Default |
|------|-------------|---------|
| `--gen-key` | Generate an `ed25519` SSH key automatically | off |
| `--dry-run` | Print all actions without applying them | off |

If any required flag is omitted, the script prompts interactively.

---

## Steps

1. **Validate inputs** — reject invalid `ENV_NAME` (non-lowercase/spaces), malformed email, unknown provider.
2. **Create `~/repos/<env>-repos/`** — idempotent; warns if already exists.
3. **Create `~/.gitconfig-<env>`** — sets `[user] name` and `email`, `[core] sshCommand` pointing to the key. Skips if file already exists.
4. **Append `includeIf` to `~/.gitconfig`** — condition: `gitdir:~/repos/<env>-repos/`. Checks for duplicates before appending. Creates the file if missing.
5. **Append `Host` block to `~/.ssh/config`** — sets `HostName`, `User git`, `IdentityFile`, `IdentitiesOnly yes`. Checks for duplicates. Creates the file (`chmod 600`) if missing.
6. **Generate SSH key (if `--gen-key`)** — `ssh-keygen -t ed25519`, then `ssh-add`. Skips if key already exists.
7. **Print summary** — repos path, config path, SSH alias, and exact commands to upload public key, test SSH, and clone repos.

---

## Naming Conventions

| Entity | Pattern | Example |
|--------|---------|---------|
| Repos folder | `<env>-repos` | `acme-repos` |
| Git config | `.gitconfig-<env>` | `.gitconfig-acme` |
| SSH Host (GitHub) | `github-<env>` | `github-acme` |
| SSH Host (Azure) | `azure-<env>` | `azure-acme` |
| SSH Key | `id_ed25519_<env>` | `id_ed25519_acme` |

---

## Post-Steps (Remind User)

After the script completes, remind the user to:

1. **Copy the public key** to the provider dashboard:
   - GitHub → Settings → SSH Keys → New SSH Key
   - Azure DevOps → User Settings → SSH Public Keys

2. **Test the SSH connection:**
   ```bash
   ssh -T github-acme     # GitHub
   ssh -T azure-acme      # Azure
   ```

3. **Clone repos using the SSH alias**, never the raw domain:
   ```bash
   # GitHub
   git clone github-acme:<org>/<repo>.git ~/repos/acme-repos/<repo>

   # Azure DevOps
   git clone azure-acme:v3/<org>/<project>/<repo> ~/repos/acme-repos/<repo>
   ```

4. **Verify identity** inside a cloned repo:
   ```bash
   git config user.email
   ```

---

## Safety Contract

- ✅ Never overwrites existing `~/.gitconfig-<env>`
- ✅ Never duplicates `includeIf` in `~/.gitconfig`
- ✅ Never duplicates SSH `Host` block
- ✅ Never overwrites an existing SSH key (warns instead)
- ✅ Creates `~/.gitconfig` and `~/.ssh/config` if they don't exist
- ✅ Idempotent: safe to run multiple times

---

## Example Invocations

```bash
# Full setup with key generation
bash scripts/add-env.sh --env acme --email dev@acme.com --provider github --key id_ed25519_acme --gen-key

# Preview without applying
bash scripts/add-env.sh --env acme --email dev@acme.com --provider github --key id_ed25519_acme --dry-run

# Interactive mode
bash scripts/add-env.sh
```
