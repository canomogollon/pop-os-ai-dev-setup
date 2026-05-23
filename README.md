# Pop!_OS 24.04 LTS — Setup Guide for AI-Assisted Software Engineers

> A 2026 evolution of [erik1066/pop-os-setup](https://github.com/erik1066/pop-os-setup),
> updated for Pop!_OS 24.04 LTS with COSMIC Desktop.
> Focused on AI-assisted software engineering workflows.
> 
> Created with human-AI collaboration — see [Credits](#credits).

## Who is this for?

Software engineers who want a professional, productive, AI-first development
environment on Pop!_OS 24.04 LTS. Not a beginner guide — assumes clean install.

## What's new vs the original guide?

- Pop!_OS 24.04 LTS with COSMIC Desktop (Wayland, Rust-based)
- AI tools as first-class citizens: OpenCode, Claude CLI, Gemini CLI
- Modern toolchain: Node 20 LTS + PNPM 9, Biome, uv (Python)
- Cursor IDE alongside VS Code
- Optional: local AI models via Ollama (hardware-gated)

## ⚠️ Hardware Note: NVIDIA Pascal (GTX 10xx)

COSMIC uses Wayland exclusively. NVIDIA Pascal-generation GPUs (GTX 10xx)
have **known issues** with Wayland compositing in 24.04.
If you have a GTX 10xx card, verify compatibility before upgrading:
https://github.com/pop-os/pop/issues

---

## 1. Update the OS

**current as of 2026-05**

Primer paso post-instalación. Pop!_OS 24.04 usa `apt` como gestor base
igual que versiones anteriores. El comando `full-upgrade` es preferido
sobre `upgrade` para manejar correctamente dependencias.

```bash
sudo apt update && sudo apt full-upgrade -y
sudo apt install -y   build-essential   curl   wget   git   zip unzip   htop   gnupg   ca-certificates   lsb-release   apt-transport-https   software-properties-common
```

Run `lsb_release -a` and look for `Description: Pop!_OS 24.04 LTS` to verify.

---

## 2. Increase the inotify watch count

**current as of 2026-05** | Crítico para dev con Node/Vite/esbuild

Vite, esbuild, TypeScript compiler y OpenCode CLI usan file watchers
intensivamente. El límite por defecto de Linux (8192) genera errores
ENOSPC durante el desarrollo.

```bash
echo fs.inotify.max_user_watches=524288 | sudo tee /etc/sysctl.d/40-inotify.conf
sudo sysctl -p --system
```

Run `cat /proc/sys/fs/inotify/max_user_watches` and look for `524288`.

---

## 3. Shell: ZSH + Starship Prompt

**current as of 2026-05** | Reemplaza el setup ZSH + tema del original

ZSH como shell principal. Starship reemplaza los temas de Oh-My-ZSH:
es más rápido, escrito en Rust, y muestra contexto de Node, Git, y
directorio activo sin configuración extra. Ideal para flujos AI-dev.

```bash
# Instalar ZSH
sudo apt install -y zsh

# Establecer como shell por defecto
chsh -s $(which zsh)

# Instalar Oh-My-ZSH (gestión de plugins)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Instalar Starship prompt
curl -sS https://starship.rs/install.sh | sh

# Añadir Starship al final de ~/.zshrc
echo 'eval "$(starship init zsh)"' >> ~/.zshrc

# Instalar plugins útiles
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

Editar `~/.zshrc` y actualizar la línea de plugins:

```
plugins=(git zsh-autosuggestions zsh-syntax-highlighting node)
```

Run `starship --version` and look for `starship 1.x.x` to verify.
Reiniciar terminal y verificar prompt con colores y contexto Git activo.

---

## 4. Terminal: Kitty (alternativa GPU-accelerated)

**current as of 2026-05**

COSMIC Terminal viene preinstalado en 24.04 y es la opción por defecto.
Kitty es una alternativa GPU-accelerated recomendada para outputs largos
de herramientas AI (streams de Claude/Gemini en CLI).

```bash
sudo apt install -y kitty
```

Para establecer Kitty como terminal por defecto:

```bash
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator $(which kitty) 50
sudo update-alternatives --config x-terminal-emulator
```

Run `kitty --version` and look for `kitty 0.3x.x` to verify.

> Nota: COSMIC Terminal es excelente para uso diario. Kitty es opcional
> pero superior para scrollback de outputs largos de modelos AI.

---

## 5. Nerd Fonts

**current as of 2026-05** | Requerido para Starship + íconos en editores AI

JetBrains Mono Nerd Font es el estándar para IDEs con integración AI
en 2026. Requerido para que Starship y VS Code/Cursor muestren íconos
correctamente.

```bash
# Crear directorio de fuentes local
mkdir -p ~/.local/share/fonts

# Descargar JetBrains Mono Nerd Font
wget -O /tmp/JetBrainsMono.zip   https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip

# Instalar
unzip /tmp/JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono
fc-cache -fv
```

Run `fc-list | grep "JetBrains"` and look for at least one entry with `JetBrainsMono` to verify.

---

## 6. COSMIC Desktop: Apariencia y Configuración Profesional

**current as of 2026-05** | [NUEVO] Reemplaza sección GNOME Tweaks + Extensions

COSMIC Desktop (Pop!_OS 24.04) es Wayland-only con tiling de ventanas
nativo (`Super + G`). No requiere extensiones de GNOME. La personalización
se hace desde **COSMIC Settings → Desktop → Appearance**.

### Tiling nativo (reemplaza Pop Shell)

- `Super + G` — activar/desactivar tiling en ventana actual
- `Super + Dirección` — mover foco entre ventanas
- `Super + Shift + Dirección` — mover ventana
- `Super + Enter` — nueva ventana en split

### Instalar tema Catppuccin (GTK)

> Verificar release actual en: https://github.com/catppuccin/gtk/releases

```bash
# Crear directorios de temas
mkdir -p ~/.local/share/themes
mkdir -p ~/.local/share/icons

# Descargar la versión más reciente disponible:
CATPPUCCIN_VERSION=$(curl -s https://api.github.com/repos/catppuccin/gtk/releases/latest | grep tag_name | cut -d'"' -f4)
wget -O /tmp/catppuccin-gtk.zip \
  "https://github.com/catppuccin/gtk/releases/download/${CATPPUCCIN_VERSION}/catppuccin-mocha-mauve-standard+default.zip"
unzip /tmp/catppuccin-gtk.zip -d ~/.local/share/themes/
```

### Instalar íconos Papirus

> Verificar disponibilidad del PPA en Ubuntu 24.04:
> https://launchpad.net/~papirus/+archive/ubuntu/papirus
> Si el PPA no está disponible, usar: sudo snap install papirus-icon-theme

```bash
sudo add-apt-repository -y ppa:papirus/papirus
sudo apt update
sudo apt install -y papirus-icon-theme
```

Aplicar desde: **COSMIC Settings → Desktop → Appearance → Icons**

> Nota: Gnome Tweaks NO existe en COSMIC. Toda la personalización es
> desde COSMIC Settings o copiando archivos a ~/.local/share/themes.

---

## 7. Visual Studio Code

**current as of 2026-05**

Instalar desde el repositorio oficial de Microsoft para recibir
actualizaciones automáticas.

```bash
wget -qO- https://packages.microsoft.com/keys/microsoft.asc |   gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

echo "deb [arch=amd64] https://packages.microsoft.com/repos/code stable main" |   sudo tee /etc/apt/sources.list.d/vscode.list

sudo apt update && sudo apt install -y code
```

### Extensiones AI obligatorias (instalar vía CLI)

```bash
code --install-extension GitHub.copilot
code --install-extension GitHub.copilot-chat
code --install-extension Continue.continue
code --install-extension biomejs.biome
code --install-extension usernamehw.errorlens
code --install-extension eamodio.gitlens
code --install-extension humao.rest-client
```

### Settings mínimos recomendados (~/.config/Code/User/settings.json)

```json
{
  "editor.fontFamily": "'JetBrainsMono Nerd Font', monospace",
  "editor.fontSize": 14,
  "editor.fontLigatures": true,
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "biomejs.biome",
  "terminal.integrated.fontFamily": "'JetBrainsMono Nerd Font Mono'",
  "editor.inlineSuggest.enabled": true,
  "github.copilot.enable": { "*": true }
}
```

Run `code --version` and look for `1.9x.x` (or newer) to verify.

---

## 8. Cursor IDE

**current as of 2026-05** | [NUEVO] IDE AI-first, fork de VS Code

Cursor es el IDE con IA más completo en 2026: IA nativa integrada
al editor, no como extensión. Permite chat con el codebase completo,
edición multi-archivo guiada por IA, y soporte de MCPs.

```bash
# Descargar AppImage oficial
mkdir -p ~/Applications
wget -O ~/Applications/cursor.AppImage \
  "https://downloader.cursor.sh/linux/appImage/x64"
chmod +x ~/Applications/cursor.AppImage

# Crear launcher .desktop para COSMIC/aplicaciones
cat > ~/.local/share/applications/cursor.desktop << 'EOF'
[Desktop Entry]
Name=Cursor
Exec=/home/$USER/Applications/cursor.AppImage --no-sandbox
Icon=cursor
Type=Application
Categories=Development;TextEditor;
EOF

update-desktop-database ~/.local/share/applications/
```

> Cursor no tiene paquete .deb oficial. El AppImage es el método
> de instalación en Linux. El launcher .desktop lo integra al COSMIC Launcher.

Run `~/Applications/cursor.AppImage --version` and look for a version string to verify.

---

## 9. OpenCode CLI

**current as of 2026-05** | [NUEVO] Agente de código AI en terminal

OpenCode es un agente de codificación que corre en terminal, similar
a Claude Code o Gemini CLI pero configurable con múltiples providers
y MCPs (Model Context Protocol). Esencial para flujos AI-first.

```bash
# Verificar nombre correcto del paquete antes de instalar:
npm info opencode

# Instalación (usar el nombre confirmado por npm info):
npm install -g opencode
```

> El nombre del paquete puede variar. Verificar en https://opencode.ai/docs
> la instrucción de instalación más reciente.

### Configuración base de providers

Crear `~/.config/opencode/config.json`:

```json
{
  "providers": {
    "anthropic": {
      "apiKey": "${ANTHROPIC_API_KEY}"
    },
    "google": {
      "apiKey": "${GOOGLE_AI_API_KEY}"
    }
  },
  "model": "claude-sonnet-4-5",
  "fallback": "gemini-2.0-flash"
}
```

### Gestión segura de API keys

```bash
# Crear directorio seguro para keys (fuera de cualquier repo)
mkdir -p ~/.config/ai-keys
chmod 700 ~/.config/ai-keys

# Crear archivo de variables
cat > ~/.config/ai-keys/exports.sh << 'EOF'
export ANTHROPIC_API_KEY="sk-ant-..."
export GOOGLE_AI_API_KEY="AIza..."
export OPENAI_API_KEY="sk-..."
EOF

chmod 600 ~/.config/ai-keys/exports.sh

# Cargar automáticamente en cada sesión
echo 'source ~/.config/ai-keys/exports.sh' >> ~/.zshrc
```

### AGENTS.md base para nuevos proyectos

En la raíz de cada proyecto nuevo, crear `AGENTS.md`:

```markdown
# AGENTS

## Stack
[Describir stack del proyecto]

## Reglas de código
- TypeScript strict, sin `any`
- [Reglas específicas del proyecto]

## Comandos frecuentes
[Comandos de build, test, dev]
```

Run `opencode --version` and look for a version number to verify.

---

## 10. Node.js 20 LTS + PNPM 9

**current as of 2026-05** | Versiones validadas en producción

Node 20 LTS vía NVM para poder manejar múltiples versiones. PNPM 9
como package manager: más rápido que npm, mejor manejo de monorepos,
y estándar creciente en proyectos TypeScript modernos.

```bash
# Instalar NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

# Cargar NVM en la sesión actual sin reiniciar terminal
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Instalar Node 20 LTS
nvm install 20
nvm use 20
nvm alias default 20

# Instalar PNPM 9
npm install -g pnpm@9
```

Run `node --version` and look for `v20.x.x` to verify.
Run `pnpm --version` and look for `9.x.x` to verify.

---

## 11. Git Configuration

**current as of 2026-05**

Configuración global de Git con firma GPG y SSH keys. La firma de
commits es especialmente importante en proyectos con colaboración
humano-IA para mantener trazabilidad de autoría.

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"
git config --global core.editor "code --wait"
git config --global init.defaultBranch main
git config --global pull.rebase false

# Generar SSH key (Ed25519 — algoritmo recomendado 2026)
ssh-keygen -t ed25519 -C "tu@email.com"

# Iniciar ssh-agent y agregar key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copiar clave pública para agregar a GitHub
cat ~/.ssh/id_ed25519.pub
```

Run `git config --list` and look for `user.name` and `user.email` to verify.

---

## 12. GitHub CLI

**current as of 2026-05**

`gh` CLI para gestión de repos, PRs, y acceso a modelos AI desde terminal.
`gh copilot` permite hacer preguntas y sugerencias de comandos directamente.

```bash
# Agregar repositorio oficial de GitHub CLI
(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y))   && sudo mkdir -p -m 755 /etc/apt/keyrings   && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg   && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null   && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg   && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main"   | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null   && sudo apt update   && sudo apt install gh -y

# Autenticar
gh auth login

# Instalar extensión Copilot CLI
gh extension install github/gh-copilot
```

Comandos útiles:

```bash
gh copilot suggest "cómo listar puertos en uso"   # sugerencia de comando
gh copilot explain "sudo ss -tulnp"                # explicar un comando
```

Run `gh --version` and look for `gh version 2.x.x` to verify.

---

## 13. AI Cloud CLI Tools

**current as of 2026-05** | [NUEVO] Herramientas AI cloud obligatorias

En 2026, estos tres CLIs son parte del toolkit estándar de un
ingeniero AI-assisted. Se complementan: Claude para código complejo,
Gemini para contextos largos, GitHub Copilot para flujo en terminal.

```bash
# Claude CLI (Anthropic)
npm install -g @anthropic-ai/claude-code

# Gemini CLI (Google)
npm install -g @google/gemini-cli

# Verificar API keys cargadas (configuradas en sección OpenCode)
echo "ANTHROPIC: ${ANTHROPIC_API_KEY:0:10}..."
echo "GOOGLE: ${GOOGLE_AI_API_KEY:0:10}..."
```

Run `claude --version` and look for a version number to verify.
Run `gemini --version` and look for a version number to verify.

---

## 14. Biome — Linter y Formatter Unificado

**current as of 2026-05** | [NUEVO] Reemplaza ESLint + Prettier

Biome es el linter/formatter todo-en-uno del ecosistema TypeScript 2026.
10-20x más rápido que ESLint+Prettier, escrito en Rust. Un solo archivo
de configuración para todo el proyecto.

```bash
# Instalar globalmente
npm install -g @biomejs/biome

# Verificar
biome --version
```

### Configuración base (biome.json en raíz del proyecto)

```json
{
  "$schema": "https://biomejs.dev/schemas/1.9.4/schema.json",
  "organizeImports": { "enabled": true },
  "linter": {
    "enabled": true,
    "rules": { "recommended": true }
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "indentWidth": 2
  }
}
```

Run `biome --version` and look for `Version: 1.x.x` to verify.

---

## 15. Docker

**current as of 2026-05**

Docker para contenedores de desarrollo y bases de datos locales.
Instalación desde el repositorio oficial de Docker (no el paquete
`docker.io` de apt que viene desactualizado).

```bash
# Remover versiones anteriores si existen
sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

# Agregar repositorio oficial Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg |   sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg

echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu   $(lsb_release -cs) stable" |   sudo tee /etc/apt/sources.list.d/docker.list

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Agregar usuario al grupo docker (sin sudo)
sudo usermod -aG docker $USER
newgrp docker
```

Run `docker --version` and look for `Docker version 27.x` or newer.
Run `docker compose version` and look for `Docker Compose version v2.x` to verify.

---

## 16. Databases in Docker (PostgreSQL + Redis)

**current as of 2026-05**

Bases de datos vía Docker Compose para desarrollo local. Este patrón
evita instalar PostgreSQL directamente en el sistema y permite múltiples
versiones por proyecto.

Crear `~/dev/docker-compose.dev.yml`:

```yaml
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: devuser
      POSTGRES_PASSWORD: devpassword
      POSTGRES_DB: devdb
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

```bash
# Levantar servicios de desarrollo
docker compose -f ~/dev/docker-compose.dev.yml up -d

# Verificar
docker compose -f ~/dev/docker-compose.dev.yml ps
```

Run `docker compose -f ~/dev/docker-compose.dev.yml ps` and look for both services in `running` state to verify.

---

## 17. Python 3 + uv

**current as of 2026-05** | [NUEVO] uv reemplaza pip/venv

Python es necesario para herramientas AI: LangChain, FastAPI, scripts
de automatización. `uv` es el nuevo package manager de Python — escrito
en Rust, reemplaza pip + venv + pyenv con un solo comando.

```bash
# Python 3 (viene preinstalado en Ubuntu 24.04, verificar versión)
python3 --version

# Instalar uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Recargar PATH
source ~/.zshrc
```

```bash
# Uso básico de uv (reemplaza python -m venv + pip)
uv venv                          # crear entorno virtual
uv pip install fastapi uvicorn   # instalar dependencias
uv run python script.py          # ejecutar sin activar venv
```

Run `uv --version` and look for `uv 0.x.x` to verify.

---

## 18. Ollama — Modelos AI Locales (OPTIONAL)

**current as of 2026-05** | [NUEVO] Opcional — requiere hardware específico

⚠️ **REQUISITOS MÍNIMOS RECOMENDADOS antes de continuar:**

- RAM: 16 GB+ (32 GB recomendado para modelos 13B+)
- GPU: NVIDIA con 8 GB VRAM+ para aceleración (o CPU-only, más lento)
- Almacenamiento: 50 GB+ libre para modelos

Si tu hardware no cumple esto, **omite esta sección completamente**.
Las herramientas cloud de las secciones 9 y 13 son suficientes.

```bash
# Instalar Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Habilitar y verificar que el servicio esté corriendo
sudo systemctl enable --now ollama
systemctl status ollama

# Descargar modelos según hardware disponible
ollama pull qwen2.5-coder:7b   # 4.7GB — excelente para código
ollama pull phi4-mini           # 2.5GB — rápido, para hardware limitado
ollama pull llama3.2:3b         # 2.0GB — propósito general, liviano
```

### Integración con OpenCode

En `~/.config/opencode/config.json`, agregar provider local:

```json
{
  "providers": {
    "ollama": {
      "baseUrl": "http://localhost:11434"
    }
  }
}
```

### Integración con Continue.dev (VS Code)

En la extensión Continue, agregar en `~/.continue/config.json`:

```json
{
  "models": [{
    "title": "Qwen2.5 Coder (Local)",
    "provider": "ollama",
    "model": "qwen2.5-coder:7b"
  }]
}
```

Run `ollama list` and look for your downloaded models to verify.

---

## 19. Security Essentials

**current as of 2026-05**

UFW como firewall básico y Bitwarden CLI para gestión de contraseñas
desde terminal — útil para automatizaciones y scripts de desarrollo.

```bash
# Habilitar firewall UFW
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw status verbose

# Bitwarden CLI
npm install -g @bitwarden/cli

# Verificar
bw --version
```

Run `sudo ufw status` and look for `Status: active` to verify.

---

## 20. Other Apps to Consider

**current as of 2026-05**

Aplicaciones adicionales recomendadas para un entorno de desarrollo
completo. Instalar según necesidad del proyecto.

```bash
# Comunicación
sudo apt install -y slack-desktop   # o via snap: sudo snap install slack

# Cliente API open source (reemplaza Postman)
sudo snap install bruno

# Gestión de notas (excelente para documentar contexto AI)
sudo snap install obsidian --classic

# Multimedia
sudo apt install -y vlc

# Monitoreo del sistema
sudo apt install -y htop nvtop   # nvtop para monitorear GPU (útil con Ollama)
```

---

## 21. Optional Runtimes

**current as of 2026-05** | Solo instalar si el proyecto lo requiere

```bash
# Go 1.22+
sudo add-apt-repository -y ppa:longsleep/golang-backports
sudo apt update
sudo apt install -y golang-go
go version

# Rust (via rustup — método oficial)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
rustc --version

# Bun (runtime JS alternativo a Node, ultrarrápido)
curl -fsSL https://bun.sh/install | bash
bun --version
```

---

## Credits

Este repositorio es una evolución de
[Pop!_OS Setup Guide for Software Engineers](https://github.com/erik1066/pop-os-setup)
por [@erik1066](https://github.com/erik1066).

### Colaboración humano-IA

La versión 2026 fue creada con el siguiente flujo colaborativo:

- **Diseño, revisión y curaduría**: Elkin Cano Mogollón (humano)
- **Generación de contenido técnico**: (Qwen3.5 Plus  + Sonnet 4.6) via [OpenCode](https://opencode.ai)
- **Contexto base**: Experiencia acumulada en proyectos de software 2025-2026
- **Validación de comandos**: Pop!_OS 24.04 LTS — COSMIC Desktop

> Los comandos han sido revisados para compatibilidad con Pop!_OS 24.04 LTS
> (base Ubuntu 24.04, COSMIC Desktop, Wayland). Se recomienda verificar
> la documentación oficial para versiones más recientes de cada herramienta.

---

*Contributions welcome. If a command is outdated, please open a PR.*
