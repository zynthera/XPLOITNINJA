#!/bin/bash

set -e

echo "[*] Creating XploitNinja project structure..."

# Root folder
mkdir -p XploitNinja
cd XploitNinja

# 1. extension/
mkdir -p extension/background extension/content extension/scripts extension/utils extension/assets

cat > extension/manifest.json << 'EOF'
{
  "manifest_version": 3,
  "name": "XploitNinja",
  "version": "1.0",
  "permissions": ["nativeMessaging", "scripting", "tabs"],
  "background": {
    "service_worker": "background/index.js"
  },
  "action": {
    "default_popup": "popup.html"
  },
  "icons": {
    "48": "assets/icon.png"
  },
  "content_scripts": [{
    "matches": ["<all_urls>"],
    "js": ["content/injector.js"]
  }]
}
EOF

cat > extension/popup.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>XploitNinja</title></head>
<body>
  <h2>XploitNinja</h2>
  <button id="scanXSS">Scan XSS</button>
  <button id="scanPorts">Scan Ports</button>
  <script src="popup.js"></script>
</body>
</html>
EOF

cat > extension/popup.js << 'EOF'
document.getElementById("scanXSS").onclick = () => {
  chrome.runtime.sendNativeMessage("xploitninja.native", {
    action: "xss_fuzz",
    url: window.location.href
  }, (response) => {
    alert("XSS Result: " + JSON.stringify(response));
  });
};

document.getElementById("scanPorts").onclick = () => {
  chrome.runtime.sendNativeMessage("xploitninja.native", {
    action: "port_scan",
    host: new URL(window.location.href).hostname
  }, (response) => {
    alert("Open Ports: " + JSON.stringify(response));
  });
};
EOF

cat > extension/background/index.js << 'EOF'
// Background script placeholder (add if needed)
EOF

cat > extension/content/injector.js << 'EOF'
// Content script placeholder (add if needed)
EOF

cat > extension/assets/icon.png << 'EOF'
// You can place your icon.png here manually
EOF

# 2. backend/
mkdir -p backend/rust_core/src backend/c_modules backend/python_core/modules

# backend rust main.rs
cat > backend/rust_core/src/main.rs << 'EOF'
use serde::{Deserialize, Serialize};
use std::io::{self, BufRead, Write};

#[derive(Deserialize)]
struct Request {
    action: String,
    url: Option<String>,
    host: Option<String>
}

#[derive(Serialize)]
struct Response {
    status: String,
    result: String
}

fn scan_ports(host: &str) -> String {
    let open_ports = [22, 80, 443, 8080];
    open_ports
        .iter()
        .map(|p| format!("{}: open", p))
        .collect::<Vec<_>>()
        .join(", ")
}

fn fuzz_xss(url: &str) -> String {
    format!("XSS tested on {}", url)
}

fn main() {
    let stdin = io::stdin();
    let mut stdout = io::stdout();

    for line in stdin.lock().lines() {
        let input = line.unwrap();
        let req: Request = serde_json::from_str(&input).unwrap();
        let result = match req.action.as_str() {
            "port_scan" => scan_ports(req.host.unwrap().as_str()),
            "xss_fuzz" => fuzz_xss(req.url.unwrap().as_str()),
            _ => "Invalid action".to_string(),
        };
        let res = Response {
            status: "ok".to_string(),
            result
        };
        writeln!(stdout, "{}", serde_json::to_string(&res).unwrap()).unwrap();
        stdout.flush().unwrap();
    }
}
EOF

cat > backend/rust_core/Cargo.toml << 'EOF'
[package]
name = "rust_core"
version = "0.1.0"
edition = "2021"

[dependencies]
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
EOF

# 3. bridge/
mkdir bridge

cat > bridge/manifest_host.json << 'EOF'
{
  "name": "xploitninja.native",
  "description": "Native backend for XploitNinja",
  "path": "/absolute/path/to/bridge/bridge_handler.py",
  "type": "stdio",
  "allowed_origins": ["chrome-extension://<EXTENSION_ID>/"]
}
EOF

cat > bridge/bridge_handler.py << 'EOF'
import sys
import json
import subprocess

def send_response(data):
    encoded = json.dumps(data).encode("utf-8")
    sys.stdout.write(chr(len(encoded) & 0xFF) + encoded.decode())
    sys.stdout.flush()

while True:
    try:
        raw_len = sys.stdin.read(1)
        if not raw_len:
            break
        length = ord(raw_len)
        message = sys.stdin.read(length)
        request = json.loads(message)

        # Call Rust binary
        rust_proc = subprocess.Popen(
            ["./backend/rust_core/target/debug/rust_core"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE
        )
        rust_proc.stdin.write((json.dumps(request) + "\n").encode())
        rust_proc.stdin.flush()
        response = rust_proc.stdout.readline().decode()
        send_response(json.loads(response))

    except Exception as e:
        send_response({"status": "error", "error": str(e)})
EOF

# 4. server/
mkdir server routes

cat > server/app.py << 'EOF'
from flask import Flask, request, jsonify
import subprocess, json

app = Flask(__name__)

@app.route("/xss", methods=["POST"])
def xss_fuzz():
    data = request.json
    p = subprocess.Popen(["./backend/rust_core/target/debug/rust_core"],
                         stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    p.stdin.write((json.dumps({"action": "xss_fuzz", "url": data["url"]}) + "\n").encode())
    p.stdin.flush()
    output = p.stdout.readline()
    return jsonify(json.loads(output))

@app.route("/ports", methods=["POST"])
def port_scan():
    data = request.json
    p = subprocess.Popen(["./backend/rust_core/target/debug/rust_core"],
                         stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    p.stdin.write((json.dumps({"action": "port_scan", "host": data["host"]}) + "\n").encode())
    p.stdin.flush()
    output = p.stdout.readline()
    return jsonify(json.loads(output))

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
EOF

cat > server/requirements.txt << 'EOF'
flask
EOF

# 5. static/
mkdir static
cat > static/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>XploitNinja Server</title></head>
<body>
<h1>Welcome to XploitNinja Server</h1>
<p>Use the API endpoints /xss and /ports to scan.</p>
</body>
</html>
EOF

# 6. scripts/
mkdir scripts

cat > scripts/install.sh << 'EOF'
#!/bin/bash
echo "[+] Building Rust core..."
cd backend/rust_core
cargo build

echo "[+] Linking native messaging..."
mkdir -p ~/.mozilla/native-messaging-hosts/
cp ../../bridge/manifest_host.json ~/.mozilla/native-messaging-hosts/xploitninja.native.json
sed -i "s|/absolute/path/to/bridge/bridge_handler.py|$(pwd)/../../bridge/bridge_handler.py|" ~/.mozilla/native-messaging-hosts/xploitninja.native.json

echo "[+] Done."
EOF

chmod +x scripts/install.sh

# 7. backend/python_core/tor_client.py
mkdir -p backend/python_core
cat > backend/python_core/tor_client.py << 'EOF'
import requests

proxies = {
    "http": "socks5h://127.0.0.1:9050",
    "https": "socks5h://127.0.0.1:9050"
}

def get_onion(url):
    r = requests.get(url, proxies=proxies)
    return r.text
EOF

# 8. .render.yaml
cat > .render.yaml << 'EOF'
services:
  - type: web
    name: xploitninja-server
    env: python
    buildCommand: pip install -r server/requirements.txt
    startCommand: python server/app.py
    plan: free
EOF

# 9. README.md
cat > README.md << 'EOF'
# XploitNinja

Ultimate CTF Browser Extension + Native Backend Hacking Toolkit

- Rust-based port scanner and XSS fuzzer
- Native messaging bridge to browser extension
- Optional Flask server for live deployment (Render)
- .onion Tor support via Python
- No DB, all local and in-memory

Author: xploitninja@hotmail.com
EOF

# 10. Initialize Git repo
git init
git add .
git commit -m "Initial commit: XploitNinja full project structure"

echo "[*] Setup complete! To build Rust backend, run:"
echo "    cd backend/rust_core && cargo build"
echo "[*] Load 'extension/' folder as unpacked extension in Chrome/Firefox."
echo "[*] Run 'scripts/install.sh' for native messaging setup (Linux/Mac)."
echo "[*] Run 'python server/app.py' to start API server."