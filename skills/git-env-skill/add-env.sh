#!/usr/bin/env bash
# =============================================================================
# add-env.sh — Add a new Git environment (identity + folder + SSH + gitconfig)
# =============================================================================
set -euo pipefail

# ─── Logging ─────────────────────────────────────────────────────────────────
log_ok()   { echo "✅  $*"; }
log_warn() { echo "⚠️   $*"; }
log_err()  { echo "❌  $*" >&2; }
log_info() { echo "ℹ️   $*"; }
log_step() { echo; echo "──────────────────────────────────────────"; echo "▶  $*"; echo "──────────────────────────────────────────"; }

# ─── Defaults ────────────────────────────────────────────────────────────────
DRY_RUN=false
GENERATE_KEY=false
REPOS_BASE="$HOME/repos"
GITCONFIG="$HOME/.gitconfig"
SSH_CONFIG="$HOME/.ssh/config"

# ─── Usage ───────────────────────────────────────────────────────────────────
usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -e, --env       Environment name (e.g. acme)         [required]
  -m, --email     Git email for this identity           [required]
  -p, --provider  Git provider: github | azure          [required]
  -k, --key       SSH key filename (e.g. id_ed25519_acme) [required]
  -g, --gen-key   Generate SSH key automatically        [optional]
  -d, --dry-run   Print actions without applying them   [optional]
  -h, --help      Show this help message

Example:
  $(basename "$0") -e acme -m dev@acme.com -p github -k id_ed25519_acme --gen-key
EOF
  exit 0
}

# ─── Argument Parsing ────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    -e|--env)       ENV_NAME="$2";    shift 2 ;;
    -m|--email)     GIT_EMAIL="$2";   shift 2 ;;
    -p|--provider)  PROVIDER="$2";    shift 2 ;;
    -k|--key)       SSH_KEY="$2";     shift 2 ;;
    -g|--gen-key)   GENERATE_KEY=true; shift ;;
    -d|--dry-run)   DRY_RUN=true;     shift ;;
    -h|--help)      usage ;;
    *) log_err "Unknown option: $1"; usage ;;
  esac
done

# ─── Interactive Prompts (if args not provided) ───────────────────────────────
prompt_if_missing() {
  local var_name="$1"
  local prompt_text="$2"
  local current_val="${!var_name:-}"
  if [[ -z "$current_val" ]]; then
    read -rp "  ${prompt_text}: " input
    printf -v "$var_name" '%s' "$input"
  fi
}

echo
log_step "Git Environment Setup"

prompt_if_missing ENV_NAME  "Environment name (e.g. acme, lowercase, no spaces)"
prompt_if_missing GIT_EMAIL "Git email for this identity"
prompt_if_missing PROVIDER  "Provider (github | azure)"
prompt_if_missing SSH_KEY   "SSH key filename (e.g. id_ed25519_acme)"

# ─── Validation ──────────────────────────────────────────────────────────────
log_step "Validating Inputs"

if [[ -z "${ENV_NAME:-}" || -z "${GIT_EMAIL:-}" || -z "${PROVIDER:-}" || -z "${SSH_KEY:-}" ]]; then
  log_err "All of --env, --email, --provider and --key are required."
  exit 1
fi

if [[ ! "$ENV_NAME" =~ ^[a-z0-9_-]+$ ]]; then
  log_err "Environment name must be lowercase, no spaces. Allowed: a-z, 0-9, - _"
  exit 1
fi

if [[ ! "$GIT_EMAIL" =~ ^[^@]+@[^@]+\.[^@]+$ ]]; then
  log_err "Invalid email address: $GIT_EMAIL"
  exit 1
fi

PROVIDER="${PROVIDER,,}"  # lowercase
if [[ "$PROVIDER" != "github" && "$PROVIDER" != "azure" ]]; then
  log_err "Provider must be 'github' or 'azure'. Got: $PROVIDER"
  exit 1
fi

log_ok "ENV_NAME  = $ENV_NAME"
log_ok "GIT_EMAIL = $GIT_EMAIL"
log_ok "PROVIDER  = $PROVIDER"
log_ok "SSH_KEY   = $SSH_KEY"
log_ok "DRY_RUN   = $DRY_RUN"

# ─── Dry-run helper ──────────────────────────────────────────────────────────
run() {
  if [[ "$DRY_RUN" == true ]]; then
    log_info "[DRY-RUN] $*"
  else
    eval "$@"
  fi
}

# ─── Derived Variables ───────────────────────────────────────────────────────
REPOS_DIR="$REPOS_BASE/${ENV_NAME}-repos"
GITCONFIG_ENV="$HOME/.gitconfig-${ENV_NAME}"
SSH_KEY_PATH="$HOME/.ssh/${SSH_KEY}"

case "$PROVIDER" in
  github) SSH_HOST="github-${ENV_NAME}" ;;
  azure)  SSH_HOST="azure-${ENV_NAME}"  ;;
esac

# ─── Step 1: Create repos folder ─────────────────────────────────────────────
log_step "Step 1 — Creating repos folder"

if [[ -d "$REPOS_DIR" ]]; then
  log_warn "Directory already exists: $REPOS_DIR (skipping)"
else
  run "mkdir -p \"$REPOS_DIR\""
  log_ok "Created: $REPOS_DIR"
fi

# ─── Step 2: Create ~/.gitconfig-<env> ───────────────────────────────────────
log_step "Step 2 — Creating $GITCONFIG_ENV"

if [[ -f "$GITCONFIG_ENV" ]]; then
  log_warn "Already exists: $GITCONFIG_ENV (skipping)"
else
  if [[ "$DRY_RUN" == true ]]; then
    log_info "[DRY-RUN] Would create $GITCONFIG_ENV with email=$GIT_EMAIL"
  else
    cat > "$GITCONFIG_ENV" <<EOF
[user]
	name = ${ENV_NAME^}
	email = $GIT_EMAIL

[core]
	sshCommand = ssh -i $SSH_KEY_PATH -F /dev/null
EOF
    log_ok "Created: $GITCONFIG_ENV"
  fi
fi

# ─── Step 3: Update ~/.gitconfig with includeIf ───────────────────────────────
log_step "Step 3 — Updating $GITCONFIG with includeIf"

INCLUDE_BLOCK="[includeIf \"gitdir:${REPOS_DIR}/\"]
	path = ${GITCONFIG_ENV}"

if [[ ! -f "$GITCONFIG" ]]; then
  log_warn "$GITCONFIG not found — creating it"
  run "touch \"$GITCONFIG\""
fi

if grep -qF "gitdir:${REPOS_DIR}/" "$GITCONFIG" 2>/dev/null; then
  log_warn "includeIf entry already exists in $GITCONFIG (skipping)"
else
  if [[ "$DRY_RUN" == true ]]; then
    log_info "[DRY-RUN] Would append includeIf block to $GITCONFIG:"
    echo "$INCLUDE_BLOCK"
  else
    printf '\n%s\n' "$INCLUDE_BLOCK" >> "$GITCONFIG"
    log_ok "Added includeIf to $GITCONFIG"
  fi
fi

# ─── Step 4: Update ~/.ssh/config ────────────────────────────────────────────
log_step "Step 4 — Updating $SSH_CONFIG"

if [[ ! -f "$SSH_CONFIG" ]]; then
  log_warn "$SSH_CONFIG not found — creating it"
  run "mkdir -p \"$HOME/.ssh\" && touch \"$SSH_CONFIG\" && chmod 600 \"$SSH_CONFIG\""
fi

if grep -qF "Host ${SSH_HOST}" "$SSH_CONFIG" 2>/dev/null; then
  log_warn "SSH Host '${SSH_HOST}' already exists in $SSH_CONFIG (skipping)"
else
  case "$PROVIDER" in
    github)
      SSH_BLOCK="
Host ${SSH_HOST}
    HostName github.com
    User git
    IdentityFile ${SSH_KEY_PATH}
    IdentitiesOnly yes"
      ;;
    azure)
      SSH_BLOCK="
Host ${SSH_HOST}
    HostName ssh.dev.azure.com
    User git
    IdentityFile ${SSH_KEY_PATH}
    IdentitiesOnly yes"
      ;;
  esac

  if [[ "$DRY_RUN" == true ]]; then
    log_info "[DRY-RUN] Would append to $SSH_CONFIG:"
    echo "$SSH_BLOCK"
  else
    printf '%s\n' "$SSH_BLOCK" >> "$SSH_CONFIG"
    chmod 600 "$SSH_CONFIG"
    log_ok "Added Host '${SSH_HOST}' to $SSH_CONFIG"
  fi
fi

# ─── Step 5: (Optional) Generate SSH Key ─────────────────────────────────────
log_step "Step 5 — SSH Key"

if [[ "$GENERATE_KEY" == true ]]; then
  if [[ -f "$SSH_KEY_PATH" ]]; then
    log_warn "SSH key already exists at $SSH_KEY_PATH (skipping generation)"
  else
    if [[ "$DRY_RUN" == true ]]; then
      log_info "[DRY-RUN] Would run: ssh-keygen -t ed25519 -C \"$GIT_EMAIL\" -f \"$SSH_KEY_PATH\" -N \"\""
    else
      ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY_PATH" -N ""
      log_ok "SSH key generated: ${SSH_KEY_PATH}"
      log_ok "Public key:        ${SSH_KEY_PATH}.pub"
    fi
  fi
else
  log_info "Key generation skipped. Use --gen-key to generate automatically."
  if [[ ! -f "$SSH_KEY_PATH" ]]; then
    log_warn "Key file not found at $SSH_KEY_PATH — make sure it exists before using this env."
  else
    log_ok "Key found at $SSH_KEY_PATH"
  fi
fi

# ─── Step 6: Add key to ssh-agent ────────────────────────────────────────────
if [[ "$GENERATE_KEY" == true && "$DRY_RUN" == false && -f "$SSH_KEY_PATH" ]]; then
  log_step "Step 6 — Adding key to ssh-agent"
  eval "$(ssh-agent -s)" > /dev/null 2>&1 || true
  ssh-add "$SSH_KEY_PATH" 2>/dev/null && log_ok "Key added to ssh-agent" || log_warn "Could not add key to ssh-agent automatically. Run: ssh-add $SSH_KEY_PATH"
fi

# ─── Final Summary ───────────────────────────────────────────────────────────
echo
echo "════════════════════════════════════════════════════════════"
echo "  ✅  Environment '${ENV_NAME}' setup complete!"
echo "════════════════════════════════════════════════════════════"
echo
echo "  📁  Repos folder   : $REPOS_DIR"
echo "  🔧  Git config     : $GITCONFIG_ENV"
echo "  🔑  SSH Host alias : $SSH_HOST"
echo "  🔑  SSH Key        : $SSH_KEY_PATH"
echo
echo "  📋  Next steps:"
echo
echo "  1. Upload your public SSH key to ${PROVIDER^}:"
if [[ "$GENERATE_KEY" == true ]]; then
  echo "     cat ${SSH_KEY_PATH}.pub"
fi
case "$PROVIDER" in
  github) echo "     → https://github.com/settings/ssh/new" ;;
  azure)  echo "     → https://dev.azure.com/<your-org>/_usersSettings/keys" ;;
esac
echo
echo "  2. Test your SSH connection:"
case "$PROVIDER" in
  github) echo "     ssh -T ${SSH_HOST}" ;;
  azure)  echo "     ssh -T ${SSH_HOST}" ;;
esac
echo
echo "  3. Clone a repo using the SSH alias:"
case "$PROVIDER" in
  github) echo "     git clone ${SSH_HOST}:<org>/<repo>.git \$HOME/repos/${ENV_NAME}-repos/<repo>" ;;
  azure)  echo "     git clone ${SSH_HOST}:v3/<org>/<project>/<repo> \$HOME/repos/${ENV_NAME}-repos/<repo>" ;;
esac
echo
echo "════════════════════════════════════════════════════════════"
