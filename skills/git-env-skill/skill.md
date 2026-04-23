# Skill: Add Git Environment

**ID:** `git-env/add-env`  
**Version:** 1.0.0  
**Trigger:** When a user needs to add a new Git identity/account to their local multi-environment setup.  
**Script:** [`add-env.sh`](./add-env.sh)

---

## When to Use This Skill

Trigger this skill when the user says something like:

- "I need to add a new Git identity for `<company>`"
- "Set up a new work account for `<provider>`"
- "Add a Git environment for `<env-name>`"
- "Configure Git and SSH for a new client"
- "I'm starting to work with a new company and need to separate Git identities"

---

## Required Inputs

| Input        | Flag          | Description                                     | Validation                          |
|--------------|---------------|-------------------------------------------------|-------------------------------------|
| `env`        | `--env`       | Short environment name (e.g. `acme`)            | Lowercase, no spaces, `[a-z0-9_-]+` |
| `email`      | `--email`     | Git email address for this identity             | Valid email format                  |
| `provider`   | `--provider`  | Git hosting provider                            | Must be `github` or `azure`         |
| `key`        | `--key`       | SSH key filename (without path)                 | Non-empty string                    |

## Optional Inputs

| Input        | Flag          | Description                                     | Default |
|--------------|---------------|-------------------------------------------------|---------|
| `gen-key`    | `--gen-key`   | Auto-generate the SSH key using `ed25519`       | `false` |
| `dry-run`    | `--dry-run`   | Simulate all actions without applying them      | `false` |

---

## Flow

```
START
  │
  ├─ 1. Collect & validate inputs
  │       └─ ENV_NAME, GIT_EMAIL, PROVIDER, SSH_KEY
  │
  ├─ 2. Create repos directory
  │       └─ ~/repos/<env>-repos/
  │
  ├─ 3. Create gitconfig file
  │       └─ ~/.gitconfig-<env>
  │           [user] name, email
  │           [core] sshCommand using key path
  │
  ├─ 4. Update ~/.gitconfig
  │       └─ Append [includeIf "gitdir:~/repos/<env>-repos/"]
  │           → path = ~/.gitconfig-<env>
  │
  ├─ 5. Update ~/.ssh/config
  │       └─ Append Host <provider>-<env> block
  │           HostName, User git, IdentityFile, IdentitiesOnly yes
  │
  ├─ 6. (Optional) Generate SSH key
  │       └─ ssh-keygen -t ed25519 -C <email> -f ~/.ssh/<key>
  │           + ssh-add to agent
  │
  └─ 7. Print final summary + next steps
          └─ How to upload public key, test connection, clone repos
```

---

## Validation Rules

| Rule | Detail |
|------|--------|
| `ENV_NAME` must be lowercase | Reject if it contains uppercase, spaces, or special chars outside `[a-z0-9_-]` |
| `GIT_EMAIL` must be valid | Reject malformed emails |
| `PROVIDER` must be `github` or `azure` | Reject any other value |
| SSH key path must not already exist (when `--gen-key`) | Warn and skip generation, do not overwrite |
| `includeIf` block must not be duplicated | Check before appending to `~/.gitconfig` |
| SSH `Host` block must not be duplicated | Check before appending to `~/.ssh/config` |
| Repos directory duplication is safe | `mkdir -p` is used — warn and continue |

---

## Files Modified

| File | Action |
|------|--------|
| `~/repos/<env>-repos/` | Created (directory) |
| `~/.gitconfig-<env>` | Created (new file) |
| `~/.gitconfig` | Appended `includeIf` block |
| `~/.ssh/config` | Appended `Host` block |
| `~/.ssh/<key>` | Created (if `--gen-key`) |

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

## Example Invocation

```bash
# With all flags
./add-env.sh --env acme --email dev@acme.com --provider github --key id_ed25519_acme --gen-key

# Dry-run to preview changes
./add-env.sh --env acme --email dev@acme.com --provider github --key id_ed25519_acme --dry-run

# Interactive (prompts for each value)
./add-env.sh
```
