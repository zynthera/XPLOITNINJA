# 🥷 XploitNinja

Ultimate CTF Browser Extension + Native Backend Hacking Toolkit 🚀  
**Author:** xploitninja@hotmail.com  
**GitHub Repo:** [https://github.com/zynthera/XPLOITNINJA](https://github.com/zynthera/XPLOITNINJA)

---

## 🎯 Overview

**XploitNinja** is a multi-platform, multi-language toolkit designed specifically for educational purposes, Capture The Flag (CTF) challenges, and authorized security research.

This toolkit combines:  
- A **cross-browser extension** (Chrome, Firefox, Edge) to provide live vulnerability insights on any webpage.  
- A **Rust backend** that performs fast and efficient port scanning and XSS fuzzing.  
- A **Python native messaging bridge** to enable seamless communication between the browser extension and the native backend.  
- An optional **Flask API server** for exposing backend functionality over HTTP, enabling easy deployment on cloud platforms such as Render.com.  
- Support for **HTTP, HTTPS, and `.onion` (Tor) URLs**, with integrated Tor proxy support for privacy and dark web pentesting.

All data is handled locally with **no databases**, ensuring lightweight operation and privacy.

---

## ⚙️ Features & Capabilities

| Feature                       | Description                                                                                     |
|------------------------------|-------------------------------------------------------------------------------------------------|
| 🔍 **Port Scanner**            | Scans common TCP ports (22, 80, 443, 8080, and more) to find open services on the current host. |
| 🛡️ **XSS Fuzzer**              | Tests input injection points on the current webpage URL for reflected XSS vulnerabilities.      |
| 🔗 **Native Messaging Bridge** | Connects the browser extension and Rust backend securely and efficiently.                        |
| 🌐 **Flask REST API Server**   | Provides RESTful endpoints for port scanning and XSS fuzzing. Easily deployed to cloud platforms.|
| 🧅 **Tor `.onion` Support**     | Accesses `.onion` sites through Tor SOCKS5 proxy at `127.0.0.1:9050`.                            |
| 🧩 **Cross-browser Compatible**| Supports major browsers with Manifest V3.                                                      |
| 📡 **Real-time Results**       | Results from backend scans are pushed immediately to the extension UI.                          |
| 🧹 **No Persistent Storage**   | Data is ephemeral — stored locally only and cleared on reload to protect user privacy.          |

---

## 🏗️ Project Structure & Architecture

XploitNinja/ ├── backend/ │   ├── rust_core/          # Rust scanner and fuzzing tools │   │   ├── src/ │   │   └── Cargo.toml │   └── python_core/        # Python scripts for Tor requests and helpers ├── bridge/                 # Python native messaging bridge between extension & Rust binary │   ├── bridge_handler.py │   └── manifest_host.json ├── extension/              # Browser extension source code │   ├── manifest.json │   ├── background.js │   ├── content_script.js │   └── popup.html ├── server/                 # Flask server API for cloud deployment │   ├── app.py │   ├── requirements.txt │   └── utils.py ├── scripts/                # Helper scripts (e.g., install.sh, build.sh) ├── static/                 # Static assets (optional) ├── .render.yaml            # Render.com deployment config └── README.md               # This documentation

### How It Works

- The **browser extension** injects content scripts and UI for scanning and fuzzing.
- Upon user action, it communicates with the **native messaging bridge** (Python) running locally.
- The bridge calls the **Rust backend executable**, passing scan or fuzz commands.
- The Rust backend performs network operations and returns structured JSON results.
- Results are passed back to the extension and displayed in the UI.
- For `.onion` URLs or cloud usage, the Python bridge or Flask server routes requests via Tor.

---

## 🚀 Setup & Installation Guide

### Prerequisites

- Rust and Cargo installed ([https://rustup.rs](https://rustup.rs))  
- Python 3.8+ installed  
- Tor daemon installed and running for `.onion` support  
- Browsers supporting Manifest V3 extensions (Chrome 88+, Firefox 109+)

---

### 1️⃣ Clone Repository

```bash
git clone https://github.com/zynthera/XPLOITNINJA.git
cd XPLOITNINJA


---

2️⃣ Build Rust Backend

cd backend/rust_core
cargo build --release

This produces the backend binary at target/release/xploitninja_backend (or similar).


---

3️⃣ Setup Python Environment & Dependencies

cd ../../server
pip install -r requirements.txt
pip install requests pysocks  # For Tor support


---

4️⃣ Configure Native Messaging

Modify bridge/manifest_host.json:
Set the "path" field to the absolute path of your bridge_handler.py script.

Register the native messaging host:


Linux Firefox example:

mkdir -p ~/.mozilla/native-messaging-hosts
cp bridge/manifest_host.json ~/.mozilla/native-messaging-hosts/xploitninja.native.json

Windows and macOS have different native messaging paths — consult browser docs.


---

5️⃣ Load Browser Extension

Open browser extensions page:

Chrome: chrome://extensions/

Firefox: about:debugging#/runtime/this-firefox


Enable developer mode.

Load unpacked extension folder extension/.



---

6️⃣ Running Flask API Server (Optional)

python app.py

The server listens at http://localhost:8080/, exposing REST endpoints for scanning.


---

7️⃣ Start Tor Service (For .onion URLs)

Make sure Tor is installed and running on your system:

sudo service tor start


---

🛠️ Usage Guide

Browser Extension

Click the XploitNinja icon in your browser toolbar.

Select Scan Ports to perform a quick scan on common ports of the current site’s host.

Select Scan XSS to fuzz input parameters on the current URL for reflected XSS.

View alerts/popups showing live results.


Flask API Endpoints

Endpoint	Method	Payload	Description

/ports	POST	{ "host": "example.com" }	Scan common ports on the host.
/xss	POST	{ "url": "http://target/" }	Fuzz URL for XSS vulnerabilities.



---

⚠️ Legal & Ethical Notice

XploitNinja is strictly for educational use, CTF challenges, and authorized penetration testing only.
Unauthorized scanning or hacking is illegal and unethical.
Always obtain proper permission before testing any network or website.


---

💡 Developer Notes

The Rust backend uses async networking for performance.

Native messaging bridge uses JSON for IPC between extension and backend.

Python scripts support Tor and act as glue layers.

Extension UI is minimal for maximum compatibility but extensible.

Future plans include additional scanners, vulnerability checks, and richer UI.



---

🌐 Deployment on Render.com

Included .render.yaml automates deployment of the Flask API server:

Installs all Python dependencies

Runs app.py as the web service

Enables public HTTPS access with free tier support



---

🤝 Contributing

Contributions, bug reports, and feature requests are welcome!

Fork the repo

Create feature branches

Submit pull requests with detailed descriptions


Please respect code style and add tests where applicable.


---

📧 Contact & Support

Email: xploitninja@hotmail.com
GitHub: https://github.com/zynthera/XPLOITNINJA


---

📄 License

This project is licensed under the MIT License.


---

🎉 Enjoy hacking the right way with XploitNinja! 🥷✨

