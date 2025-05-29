# XploitNinja

Ultimate CTF Browser Extension + Native Backend Hacking Toolkit  
**Author:** xploitninja@hotmail.com

---

## Overview

**XploitNinja** is a powerful, multi-language hacking toolkit designed for educational and Capture The Flag (CTF) challenges.  
It includes:

- A browser extension for Chrome/Firefox  
- A Rust backend for port scanning and XSS fuzzing  
- A Python native messaging bridge  
- Optional Flask server for live deployment  
- Support for HTTP, HTTPS, and `.onion` URLs via Tor proxy  
- All data is local and ephemeral — no database involved

---

## Features

- **Port scanner** with common ports testing (22, 80, 443, 8080)  
- **XSS fuzzer** that tests injection points on the current page  
- **Native messaging** integration for low-level backend communication  
- **Live Flask API server** (deployable on Render or similar)  
- **Tor `.onion` site support** via SOCKS5 proxy in Python  
- Cross-browser extension support using Manifest V3  

---

## Project Structure

XploitNinja/ ├── backend/ │   ├── rust_core/            # Rust backend scanner/fuzzer │   │   ├── src/ │   │   └── Cargo.toml │   └── python_core/          # Python scripts for Tor etc. ├── bridge/                  # Native messaging bridge Python script ├── extension/               # Browser extension (JS, HTML, manifest) ├── server/                  # Flask server for live API ├── scripts/                 # Helper scripts (e.g. install.sh) ├── static/                  # Static HTML files (optional) ├── .render.yaml             # Deployment config for Render.com └── README.md                # This file

---

## Setup Instructions

### 1. Clone or create project

If you ran the `setup.sh` script, your project folder is ready.

If not, clone your Git repo or create files manually based on structure above.

---

### 2. Build Rust Backend

```bash
cd backend/rust_core
cargo build --release

This compiles the Rust binary used for scanning/fuzzing.


---

3. Install Python dependencies

pip install -r ../server/requirements.txt

Also, ensure you have requests installed for Tor proxy support:

pip install requests


---

4. Setup Native Messaging

Update the absolute path in bridge/manifest_host.json to point to your bridge_handler.py script.

Copy this manifest to the native messaging hosts folder for your browser:


Linux Firefox example:

cp bridge/manifest_host.json ~/.mozilla/native-messaging-hosts/xploitninja.native.json

Replace /absolute/path/to/bridge/bridge_handler.py inside the manifest with the real full path.


---

5. Load Browser Extension

Go to your browser extensions page:

Chrome: chrome://extensions/

Firefox: about:debugging#/runtime/this-firefox


Enable developer mode and load the unpacked extension from the extension/ folder.



---

6. Running the Flask API Server (optional)

python server/app.py

Server runs on http://localhost:8080/ and exposes:

POST /xss with JSON { "url": "<url>" }

POST /ports with JSON { "host": "<hostname>" }



---

7. Tor Support for .onion URLs

Make sure Tor daemon is installed and running:

sudo service tor start

Python module uses SOCKS5 proxy at 127.0.0.1:9050 for .onion access.


---

Usage

Open any website and click the extension icon.

Use "Scan Ports" to scan common ports on the current host.

Use "Scan XSS" to fuzz the current URL for XSS vulnerabilities.

View alerts with results returned from the Rust backend via native messaging.



---

Development Notes

Rust backend handles the heavy lifting of scans/fuzzing.

Native messaging bridge connects JS extension and Rust binary.

Python is used for server mode and .onion site requests.

No database; all scan data lives in memory or browser cache.

Extension manifest uses Manifest V3 for future-proofing.



---

Deployment on Render.com

Use the included .render.yaml for easy deployment:

Automatically installs dependencies.

Runs Flask server.

Free plan supported.



---

Security and Ethics

XploitNinja is designed for educational use only and authorized penetration testing.
Unauthorized scanning or exploitation of systems is illegal and unethical. Use responsibly.


---

Contact

For questions, suggestions, or support:
Email: xploitninja@hotmail.com


---

License

MIT License - See LICENSE file (if you add one)


---

Enjoy hacking the right way with XploitNinja! 🥷🚀


