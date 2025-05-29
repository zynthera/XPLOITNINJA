

# 🥷 XploitNinja

[![GitHub issues](https://img.shields.io/github/issues/zynthera/XPLOITNINJA?style=for-the-badge)](https://github.com/zynthera/XPLOITNINJA/issues)
[![GitHub forks](https://img.shields.io/github/forks/zynthera/XPLOITNINJA?style=for-the-badge)](https://github.com/zynthera/XPLOITNINJA/network)
[![GitHub stars](https://img.shields.io/github/stars/zynthera/XPLOITNINJA?style=for-the-badge)](https://github.com/zynthera/XPLOITNINJA/stargazers)
[![GitHub license](https://img.shields.io/github/license/zynthera/XPLOITNINJA?style=for-the-badge)](https://github.com/zynthera/XPLOITNINJA/blob/main/LICENSE)

---

## 🎯 What is XploitNinja?

XploitNinja is a **powerful, multi-platform hacking toolkit** designed for **educational purposes, Capture The Flag (CTF) challenges, and authorized penetration testing**.  

It seamlessly combines a **cross-browser extension** and a **native backend** built in Rust, Python, and C/C++ for high-performance network scanning, XSS fuzzing, and vulnerability detection.

**Key Highlights:**

- 🔥 Real-time vulnerability insights in the browser  
- 🚀 Fast Rust-powered port scanning and fuzzing  
- 🧅 Full support for `.onion` Tor hidden services  
- 🌐 Works with HTTP, HTTPS, and onion protocols  
- ⚡ No external databases, fully local and ephemeral data  
- 🧩 Cross-browser compatibility (Chrome, Firefox, Edge) with Manifest V3  
- ☁️ Optional Flask API server for cloud deployment (Render.com compatible)  
- 🛡️ Native messaging bridge for seamless browser-backend communication  

---

## ⚙️ Features

| Feature                         | Description                                                                                   |
|--------------------------------|-----------------------------------------------------------------------------------------------|
| 🔍 **Port Scanner**              | Scan the most common TCP ports (22, 80, 443, 8080, etc.) on the target host in seconds.      |
| 🛡️ **XSS Fuzzer**                | Test URL parameters for reflected XSS vulnerabilities with automated payload injection.       |
| 🧅 **Tor & Onion Services**       | Route requests via Tor SOCKS5 proxy to access `.onion` sites safely and anonymously.          |
| 🔗 **Native Messaging Bridge**    | Python bridge connects browser extension to backend binaries for fast and secure IPC.         |
| 🌐 **Flask REST API**             | Expose backend scanning and fuzzing as RESTful endpoints for easy cloud deployment.           |
| 🧹 **No Database Required**       | All scan results are transient, stored in memory or browser cache only for privacy.            |
| 🧩 **Multi-Browser Support**      | Designed for Chrome, Firefox, and Edge with Manifest V3 and WebExtension APIs.                 |
| 📡 **Real-Time Results**          | Push scan and fuzz results instantly from backend to extension UI for interactive experience.|
| 🔧 **Modular Architecture**       | Easily extend with new scanning modules or integrate with other security tools.               |

---

## 🏗️ Project Architecture & Directory Structure

XploitNinja/ ├── backend/ │   ├── rust_core/          # Rust scanner & fuzzing core │   ├── python_core/        # Python helpers & Tor support ├── bridge/                 # Python native messaging bridge ├── extension/              # Browser extension source (Manifest V3) ├── server/                 # Flask API server (optional) ├── scripts/                # Setup, build, and deploy scripts ├── static/                 # Static files for extension UI or server ├── .render.yaml            # Render.com deployment config ├── README.md               # Project documentation ├── LICENSE                 # MIT License ├── CONTRIBUTING.md         # Contribution guidelines ├── SECURITY.md             # Security policy └── CODE_OF_CONDUCT.md      # Code of conduct

---

## 🚀 Getting Started: Installation & Setup

### Prerequisites

- **Rust**: Install via [rustup](https://rustup.rs)  
- **Python 3.8+** with dependencies (see `requirements.txt`)  
- **Tor daemon** running locally (`127.0.0.1:9050`) for `.onion` support  
- Modern browsers supporting Manifest V3 (Chrome 88+, Firefox 109+, Edge latest)

---

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/zynthera/XPLOITNINJA.git
cd XPLOITNINJA


---

2️⃣ Build Rust Backend

cd backend/rust_core
cargo build --release

The binary will be here:
backend/rust_core/target/release/xploitninja_backend


---

3️⃣ Install Python Dependencies

pip install -r requirements.txt


---

4️⃣ Configure Native Messaging

Edit bridge/manifest_host.json to set the absolute path to bridge_handler.py

Register native messaging host according to your OS/browser (see browser docs)

Example for Firefox on Linux:


mkdir -p ~/.mozilla/native-messaging-hosts
cp bridge/manifest_host.json ~/.mozilla/native-messaging-hosts/xploitninja.native.json


---

5️⃣ Load Browser Extension

Open browser extension page (chrome://extensions/ or about:debugging#/runtime/this-firefox)

Enable developer mode

Load unpacked extension from extension/ folder



---

6️⃣ Start Flask API Server (Optional)

cd server
python app.py

API available at http://localhost:8080


---

7️⃣ Start Tor Service

sudo service tor start

Ensure Tor listens on 127.0.0.1:9050


---

🛠️ Usage Guide

Browser Extension

Click the extension icon

Use Scan Ports or Scan XSS tabs

Enter target domain or URL

View real-time scan/fuzzing results


Flask REST API

Endpoint	Method	Payload	Description

/ports	POST	{ "host": "example.com" }	Scan common TCP ports
/xss	POST	{ "url": "http://target" }	Run XSS parameter fuzzing


Supports .onion URLs via Tor.


---

⚠️ Legal Notice

XploitNinja is intended only for educational use and authorized testing.
Unauthorized access or scanning is illegal and unethical.
Always obtain explicit permission before testing any system.


---

🤝 Contributing

Please read CONTRIBUTING.md for guidelines on how to contribute.
All contributors agree to our Code of Conduct.


---

🛡️ Security

Report security issues privately to:
xploitninja@hotmail.com
See SECURITY.md for details.


---

📧 Contact

Email: xploitninja@hotmail.com

GitHub: https://github.com/zynthera/XPLOITNINJA



---

📄 License

MIT License — see LICENSE


---

🎉 Happy ethical hacking! 🥷✨