# 🚀 Listmonk: Deployment & Build Guide

This repository is optimized for a **"one-click" setup**. We have implemented a custom **Source-to-Image (S2I)** multi-stage build process, moving away from generic images to ensure the application is perfectly tailored for our specific environment and branding.

---

### 📋 Prerequisites

Before you begin, ensure you have the following installed on your machine:

1.  **Docker Desktop** (for Windows/Mac) or **Docker Engine** (for Linux).
    *   **Windows/Mac:** [Download Docker Desktop](https://www.docker.com/products/docker-desktop/)
    *   **Linux:** [Official Installation Guide](https://docs.docker.com/engine/install/)
2.  **Git** (to clone the repository).

---

### 📦 Quick Start Guide

Follow these steps to set up the project for the first time:

#### 1. Clone and Navigate
Open your terminal (PowerShell or Command Prompt on Windows) and run:
```bash
git clone <your-fork-repo-url>
cd <project-folder-name>
```

#### 2. Launch the Application
Run the following command. This will download the environments, compile the code, and initialize the database in one step:
```bash
docker compose up --build -d
```
*Note: The first run may take 3–7 minutes as it builds the entire production environment from scratch.*

#### 3. Verify the Status
Ensure both the app and database containers are healthy:
```bash
docker compose ps
```

#### 4. Access the Dashboard
Once the status shows "Up" or "Running", open your browser:
*   **URL:** [http://localhost:9000](http://localhost:9000)
*   **Username:** `admin`
*   **Password:** `admin`

---

## 🛠 Issues Encountered & Solutions

During the initial setup, several environmental and architectural issues were identified and resolved to ensure **Universal Compatibility** across all developer machines.

| Issue | Root Cause | Universal Solution |
| :--- | :--- | :--- |
| **Build Failure (Node/Go)** | Source requires Node 20+ and Go 1.24. | Pinned Docker builders to `node:22-alpine` and `golang:1.24-alpine`. |
| **Missing Build Tools** | Alpine base image lacked compilation tools (make, grep). | Integrated `apk add make git grep` into the multi-stage build process. |
| **"File Not Found" (UI)** | Backend looked for UI assets at `frontend/dist` inside the `static` folder. | Implemented a **Redundant Path Matrix** copying assets to both root and nested paths. |
| **SQL/Schema Logic** | Binary couldn't find DB instructions after container start. | Forced recursive copying of `*.sql` files and `queries/` folder to the application root. |
| **Runtime Crash (Config)** | App check failed due to missing `config.toml.sample`. | Preserved the sample config file to satisfy internal initialization checks. |
| **Logo Sync Error** | Windows permissions prevented local folder syncing. | Implemented **Logo Injection**, baking branding directly into the image at build-time. |

---

## ✨ Key Achievements of this Build
- **Zero Configuration:** The database, admin user, and UI assets are prepared automatically on the first run.
- **True Portability:** The build is fully isolated within Docker; it works regardless of the host OS or local language versions.
- **Optimized Performance:** Multi-stage builds result in a tiny, secure final production image by stripping away bulky build tools and source code.

---

### 💡 Pro-Tip for Windows Users
If you encounter issues starting Docker, ensure **WSL 2** is installed and enabled in your Docker Desktop settings. This ensures the best performance and directory-syncing compatibility for the build process.
```