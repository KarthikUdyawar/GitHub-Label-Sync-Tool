# 🚀 GitHub Label Sync Tool

![GitHub Repo stars](https://img.shields.io/github/stars/KarthikUdyawar/GitHub-Label-Sync-Tool?style=social)
![License](https://img.shields.io/github/license/KarthikUdyawar/GitHub-Label-Sync-Tool)
![ShellCheck](https://img.shields.io/badge/shellcheck-passing-brightgreen?logo=gnu-bash&logoColor=white)
![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen)

A shell script to **sync GitHub issue labels** from a CSV file to a repository using the GitHub API.  
Easily validate, create, update, and optionally delete labels to keep your GitHub repositories clean and consistent.

---

## 📜 Table of Contents

- [🚀 GitHub Label Sync Tool](#-github-label-sync-tool)
  - [📜 Table of Contents](#-table-of-contents)
  - [🛠 Features](#-features)
  - [📦 Installation](#-installation)
  - [🚀 Usage](#-usage)
    - [Flags](#flags)
  - [🧪 CSV Format](#-csv-format)
    - [Constraints](#constraints)
  - [🔐 Authentication](#-authentication)
  - [📈 Output Summary](#-output-summary)
  - [🧑‍💻 Contributing](#-contributing)
    - [🧪 Before submitting a PR](#-before-submitting-a-pr)
  - [📄 License](#-license)

---

## 🛠 Features

- ✅ Validates label CSV structure and field formats
- 🔄 Creates or updates GitHub labels
- 🧹 Optionally deletes existing labels not in CSV
- 🔐 Uses GitHub Personal Access Token (PAT) for authentication
- 💬 Provides detailed feedback during syncing
- 💡 Simple, dependency-free Bash script

---

## 📦 Installation

```bash
git clone https://github.com/KarthikUdyawar/GitHub-Label-Sync-Tool.git
cd GitHub-Label-Sync-Tool
chmod +x github_label_sync.sh
```

---

## 🚀 Usage

```bash
./github_label_sync.sh -f labels.csv -r user/repo [-d]
```

### Flags

| Flag | Description |
|------|-------------|
| `-f` | Path to the CSV file (default: `labels.csv`) |
| `-r` | Target GitHub repository in format `user/repo` |
| `-d` | Delete existing labels not in CSV (optional) |
| `-h` | Show help message |

---

## 🧪 CSV Format

The input file must have a header and exactly 3 columns per row:

```csv
name,color,description
bug,f29513,Something isn't working
enhancement,84b6eb,New feature or request
```

### Constraints

- `name` must not be empty
- `color` must be a valid hex (e.g., `f29513`)
- `description` must not exceed 100 characters

---

## 🔐 Authentication

The script uses the `GITHUB_TOKEN` environment variable or prompts for it securely:

```bash
export GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

Ensure the token has **repo** scope.

---

## 📈 Output Summary

At the end of the script, you’ll see a summary like:

```
🎉 Sync complete!
  ✅ Created: 3
  🔄 Updated: 4
  ❌ Failed:  1
```

## 🧑‍💻 Contributing

Contributions are welcome! Whether it's a bug fix, feature suggestion, improvement, or documentation update—feel free to open an issue or submit a pull request.

To contribute:

```bash
# 1. Fork the repository
git clone https://github.com/KarthikUdyawar/GitHub-Label-Sync-Tool.git
cd GitHub-Label-Sync-Tool

# 2. Create a new branch for your feature or fix
git checkout -b my-feature-branch

# 3. Make your changes and commit
# (use clear and descriptive commit messages)
git add .
git commit -m "✨ Add new feature XYZ"

# 4. Push to your fork and open a pull request
git push origin my-feature-branch
```

### 🧪 Before submitting a PR

- ✅ Ensure your changes are tested and working.
- 🧹 Lint your shell script using [ShellCheck](https://www.shellcheck.net/):

  ```bash
  docker run --rm -v "$PWD:/mnt" koalaman/shellcheck:stable ./github_label_sync.sh
  ```

- 📜 Update the README or docs if your changes affect usage or behavior.
- 📌 Reference the issue number in your PR if it's related to an open issue.
- 🛠️ Use [Conventional Commits](https://www.conventionalcommits.org/) for commit messages.
- 🔍 Check [open issues](https://github.com/KarthikUdyawar/GitHub-Label-Sync-Tool/issues) for inspiration or existing tasks.

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

