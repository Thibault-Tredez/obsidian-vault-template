#!/usr/bin/env bash
# ==============================================================================
# Installation automatique : Claude Code + vault Obsidian synchronisé
# Automatic setup: Claude Code + synced Obsidian vault
#
# Usage / Utilisation :
#   curl -fsSL https://raw.githubusercontent.com/<compte>/obsidian-vault-template/main/setup.sh | bash
# ==============================================================================
set -euo pipefail

# ---------- 0. Language / Langue ----------
echo ""
echo "=================================================="
echo "  1) Francais"
echo "  2) English"
echo "=================================================="
read -rp "Choisissez / Choose [1/2]: " LANG_CHOICE
if [ "$LANG_CHOICE" = "2" ]; then
  LC="en"
else
  LC="fr"
fi

msg() {
  if [ "$LC" = "fr" ]; then echo "$1"; else echo "$2"; fi
}

step() {
  echo ""
  echo "------------------------------------------------------------"
  msg "$1" "$2"
  echo "------------------------------------------------------------"
}

# ---------- 1. System update ----------
step "Etape 1/7 : mise a jour du systeme..." "Step 1/7: updating the system..."
sudo apt-get update -y -qq
sudo apt-get upgrade -y -qq

# ---------- 2. Base tools ----------
step "Etape 2/7 : installation de Git et des outils de base..." "Step 2/7: installing Git and base tools..."
sudo apt-get install -y -qq git curl build-essential

# ---------- 3. Node.js ----------
step "Etape 3/7 : installation de Node.js..." "Step 3/7: installing Node.js..."
if ! command -v node >/dev/null 2>&1; then
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - >/dev/null
  sudo apt-get install -y -qq nodejs
fi
msg "Node.js installe : $(node -v)" "Node.js installed: $(node -v)"

# ---------- 4. Claude Code ----------
step "Etape 4/7 : installation de Claude Code..." "Step 4/7: installing Claude Code..."
sudo npm install -g @anthropic-ai/claude-code --silent
msg "Claude Code installe." "Claude Code installed."

# ---------- 5. GitHub identity + token ----------
step "Etape 5/7 : connexion a votre compte GitHub" "Step 5/7: connecting your GitHub account"
msg "Ces informations viennent de l'etape GitHub du guide." \
    "This information comes from the GitHub step of the guide."
read -rp "$(msg 'Nom affiche pour vos notes (ex: Jean Dupont) : ' 'Display name for your notes (e.g. John Smith): ')" GIT_NAME
read -rp "$(msg 'Votre email (le meme que sur GitHub) : ' 'Your email (same as on GitHub): ')" GIT_EMAIL
read -rp "$(msg "URL du repository GitHub a cloner (bouton vert 'Code' > HTTPS) : " "GitHub repository URL to clone (green 'Code' button > HTTPS): ")" REPO_URL
read -rp "$(msg 'Votre nom d utilisateur GitHub : ' 'Your GitHub username: ')" GH_USERNAME
echo ""
msg "Collez votre token GitHub (il ne s'affichera pas, c'est normal) :" \
    "Paste your GitHub token (it will not appear on screen, this is normal):"
read -rsp "> " GH_TOKEN
echo ""

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global credential.helper store
echo "https://${GH_USERNAME}:${GH_TOKEN}@github.com" > ~/.git-credentials
chmod 600 ~/.git-credentials

git clone "$REPO_URL" ~/obsidian-vault
msg "Vault clone dans ~/obsidian-vault" "Vault cloned into ~/obsidian-vault"

# ---------- 6. Anthropic API key ----------
step "Etape 6/7 : connexion a votre compte Anthropic (Claude)" "Step 6/7: connecting your Anthropic (Claude) account"
echo ""
msg "Collez votre cle API Anthropic (elle ne s'affichera pas, c'est normal) :" \
    "Paste your Anthropic API key (it will not appear on screen, this is normal):"
read -rsp "> " ANTHROPIC_KEY
echo ""
echo "export ANTHROPIC_API_KEY=\"$ANTHROPIC_KEY\"" >> ~/.bashrc
export ANTHROPIC_API_KEY="$ANTHROPIC_KEY"
msg "Cle enregistree." "Key saved."

# ---------- 7. Done ----------
step "Etape 7/7 : verification" "Step 7/7: verification"
echo ""
msg "Installation terminee !" "Setup complete!"
msg "Votre vault se trouve dans : ~/obsidian-vault" "Your vault is located at: ~/obsidian-vault"
msg "Pour lancer Claude Code, tapez : claude" "To start Claude Code, type: claude"
echo ""
msg "Prochaine etape : installez Obsidian sur votre ordinateur et votre telephone (voir le guide)." \
    "Next step: install Obsidian on your computer and phone (see the guide)."
