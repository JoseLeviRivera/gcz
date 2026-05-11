# GCZ — Git Conventional Commit CLI

## Descripción

A lightweight and interactive CLI for generating clean and standardized Conventional Commits directly from your terminal.

GCZ automatically intercepts git commit and replaces it with an interactive commit generator powered by Bash and fzf.

---

## ✨ Features
Conventional Commits support
Interactive terminal UI with fzf
Automatic git commit override
ANSI colors
Smart branch detection
Optional scope/body/footer
Preview generated commit
Lightweight alternative to Commitizen
Zero Node.js dependencies
Pure Bash implementation
---

# 📦 Installation

1. Clone the repository
```
   git clone <your-repository>
   cd gcz
```
---
2. Install dependencies
Ubuntu / Debian

```
sudo apt install git fzf
```
MacOS
```
brew install git fzf
```
---

3. Install GCZ globally
```
   chmod +x gcz.sh
   sudo cp gcz.sh /usr/local/bin/gcz
   sudo chmod +x /usr/local/bin/gcz
```
---
4. Configure shell integration
Run the installer:
```
  chmod +x install.sh
./install.sh
```
This will:
- Detect your shell (bash or zsh)
- Modify .bashrc or .zshrc
- Override git commit
- Automatically launch gcz
---
## ⚡ Usage
After installation:
```
git commit
```
will automatically open the interactive GCZ interface.
---

## 🧠 Smart Branch Detection

GCZ automatically suggests commit types based on your branch name.

Branch	Suggested Type
feature/payment	feat
fix/login	fix
docs/readme	docs
refactor/api	refactor

## 🖥 Interactive Commit Flow

GCZ provides:

Commit type selection
Scope suggestion
Description input
Optional body/footer
Commit preview
Confirmation before execution

## 🛠 Requirements
- Bash
- Git
- fzf

## 🔒 Safety

GCZ does NOT modify:
- git push
- git pull
- git status
- git add

Only git commit is intercepted.
Additionally:

```
git commit -m "message"
```
still works normally.

## 📄 License
MIT License

## ❤️ Why GCZ?

Most Conventional Commit tools require:
- Node.js
- npm
- large dependencies
- slow startup

GCZ is:

- fast
- minimal
- portable
- dependency-light
- terminal-native

Perfect for developers who want a clean workflow without bloated tooling.