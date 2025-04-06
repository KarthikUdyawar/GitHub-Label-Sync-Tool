# 🙌 Contributing to GitHub Label Sync Tool

Thank you for considering contributing to **GitHub Label Sync Tool**!  
Your help makes this project better for everyone.

---

## 🧾 Table of Contents

- [🙌 Contributing to GitHub Label Sync Tool](#-contributing-to-github-label-sync-tool)
  - [🧾 Table of Contents](#-table-of-contents)
  - [📋 Before You Start](#-before-you-start)
  - [🚀 Getting Started](#-getting-started)
  - [📦 Project Structure](#-project-structure)
  - [🔐 Environment Setup](#-environment-setup)
  - [🔧 How to Contribute](#-how-to-contribute)
  - [🧪 Running Lint](#-running-lint)
  - [📬 Commit Message Guidelines](#-commit-message-guidelines)
  - [📜 Code of Conduct](#-code-of-conduct)

---

## 📋 Before You Start

- Please **open an issue** to discuss major changes before submitting a PR.
- Check [existing issues](https://github.com/KarthikUdyawar/GitHub-Label-Sync-Tool/issues) before creating a new one.
- Read our [Code of Conduct](CODE_OF_CONDUCT.md).

---

## 🚀 Getting Started

```bash
git clone https://github.com/KarthikUdyawar/GitHub-Label-Sync-Tool.git
cd GitHub-Label-Sync-Tool
chmod +x github_label_sync.sh
```

---

## 📦 Project Structure

```
.
├── github_label_sync.sh     # Main script
├── labels.csv               # Default CSV with label definitions
├── .env.example             # Example env file
├── .gitignore
├── README.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
└── assets/
    └── logo.png             # Project logo
```

---

## 🔐 Environment Setup

1. Copy the `.env.example` to `.env`:

   ```bash
   cp .env.example .env
   ```

2. Open `.env` and add your GitHub Personal Access Token:

   ```
   GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXX
   ```

3. Make sure your token has `repo` scope.

---

## 🔧 How to Contribute

1. **Fork** the repository
2. Create a new **feature branch**:  
   `git checkout -b feat/add-awesome-feature`
3. Make your changes (be sure to test them!)
4. Run lint checks using ShellCheck (see below)
5. Commit changes with a [Conventional Commit](https://www.conventionalcommits.org/)
6. Push to your fork:  
   `git push origin feat/add-awesome-feature`
7. Create a **Pull Request**

---

## 🧪 Running Lint

We use [ShellCheck](https://www.shellcheck.net/) to lint shell scripts.

```bash
docker run --rm -v "$PWD:/mnt" koalaman/shellcheck:stable ./github_label_sync.sh
```

Fix any issues before submitting your pull request.

---

## 📬 Commit Message Guidelines

Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Formatting, missing semi colons, etc.
- `refactor:` - Code changes that neither fixes a bug nor adds a feature
- `test:` - Adding or fixing tests
- `chore:` - Maintenance tasks

**Example:**
```bash
git commit -m "feat: add delete flag to remove outdated labels"
```

---

## 📜 Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md) to foster a welcoming community.

---

We appreciate your interest in contributing! 🙏  
Let’s build something great together 🚀
