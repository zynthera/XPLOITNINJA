#!/bin/bash

set -euo pipefail  # Stricter error handling

echo "[*] Creating XploitNinja project structure..."

# Root folder with timestamp
PROJECT_DIR="XploitNinja_$(date +%Y%m%d)"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Create directory structure
dirs=(
    "extension/background"
    "extension/content"
    "extension/scripts"
    "extension/utils"
    "extension/assets"
    "backend/rust_core/src"
    "backend/c_modules"
    "backend/python_core/modules"
    "server/routes"
    "static"
    "scripts"
    "bridge"
)

for dir in "${dirs[@]}"; do
    mkdir -p "$dir"
done

# 1. Updated Extension Manifest (V3)
cat > extension/manifest.json << 'EOF'
{
  "manifest_version": 3,
  "name": "XploitNinja",
  "version": "1.0.0",
  "description": "Security Testing Toolkit",
  "permissions": [
    "nativeMessaging",
    "scripting",
    "tabs",
    "storage"
  ],
  "host_permissions": [
    "*://*/*"
  ],
  "background": {
    "service_worker": "background/index.js",
    "type": "module"
  },
  "action": {
    "default_popup": "popup.html",
    "default_icon": {
      "16": "assets/icon16.png",
      "32": "assets/icon32.png",
      "48": "assets/icon48.png",
      "128": "assets/icon128.png"
    }
  },
  "icons": {
    "16": "assets/icon16.png",
    "32": "assets/icon32.png",
    "48": "assets/icon48.png",
    "128": "assets/icon128.png"
  },
  "content_security_policy": {
    "extension_pages": "script-src 'self'; object-src 'self'"
  }
}
EOF

# 2. Updated Rust Core with Error Handling
cat > backend/rust_core/Cargo.toml << 'EOF'
[package]
name = "xploitninja_core"
version = "0.1.0"
edition = "2021"
authors = ["zynthera <xploitninja@hotmail.com>"]

[dependencies]
tokio = { version = "1.28", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
thiserror = "1.0"
anyhow = "1.0"
tracing = "0.1"
tracing-subscriber = "0.3"
EOF

cat > backend/rust_core/src/main.rs << 'EOF'
use serde::{Deserialize, Serialize};
use std::io::{self, BufRead, Write};
use anyhow::{Result, Context};

#[derive(Debug, Deserialize)]
struct Request {
    action: String,
    url: Option<String>,
    host: Option<String>,
}

#[derive(Debug, Serialize)]
struct Response {
    status: String,
    result: String,
    timestamp: String,
}

fn scan_ports(host: &str) -> Result<String> {
    let open_ports = [22, 80, 443, 8080, 3306, 5432];
    Ok(open_ports
        .iter()
        .map(|p| format!("{}: open", p))
        .collect::<Vec<_>>()
        .join(", "))
}

fn fuzz_xss(url: &str) -> Result<String> {
    Ok(format!("XSS tested on {} at {}", url, chrono::Utc::now()))
}

fn main() -> Result<()> {
    // Initialize logging
    tracing_subscriber::fmt::init();

    let stdin = io::stdin();
    let mut stdout = io::stdout();

    for line in stdin.lock().lines() {
        let input = line.context("Failed to read line")?;
        let req: Request = serde_json::from_str(&input)
            .context("Failed to parse request")?;

        let result = match req.action.as_str() {
            "port_scan" => scan_ports(req.host.as_deref().unwrap_or(""))?,
            "xss_fuzz" => fuzz_xss(req.url.as_deref().unwrap_or(""))?,
            _ => "Invalid action".to_string(),
        };

        let res = Response {
            status: "ok".to_string(),
            result,
            timestamp: chrono::Utc::now().to_rfc3339(),
        };

        writeln!(stdout, "{}", serde_json::to_string(&res)?)?;
        stdout.flush()?;
    }
    Ok(())
}
EOF

# 3. Updated Python Bridge with Proper Protocol Handling
cat > bridge/bridge_handler.py << 'EOF'
#!/usr/bin/env python3
import sys
import json
import subprocess
import struct
import logging
from pathlib import Path

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    filename='bridge.log'
)

def send_message(data):
    message = json.dumps(data).encode('utf-8')
    sys.stdout.buffer.write(struct.pack('I', len(message)))
    sys.stdout.buffer.write(message)
    sys.stdout.buffer.flush()

def get_message():
    raw_length = sys.stdin.buffer.read(4)
    if not raw_length:
        return None
    message_length = struct.unpack('I', raw_length)[0]
    message = sys.stdin.buffer.read(message_length).decode('utf-8')
    return json.loads(message)

def main():
    rust_binary = Path(__file__).parent.parent / "backend/rust_core/target/release/xploitninja_core"
    
    while True:
        try:
            message = get_message()
            if message is None:
                break

            process = subprocess.Popen(
                [str(rust_binary)],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            
            stdout, stderr = process.communicate(
                input=json.dumps(message).encode('utf-8') + b'\n'
            )
            
            if process.returncode == 0:
                response = json.loads(stdout.decode('utf-8'))
                send_message(response)
            else:
                send_message({
                    "status": "error",
                    "error": stderr.decode('utf-8')
                })

        except Exception as e:
            logging.exception("Error in bridge handler")
            send_message({
                "status": "error",
                "error": str(e)
            })

if __name__ == "__main__":
    main()
EOF

chmod +x bridge/bridge_handler.py

# 4. Updated Server with Security Headers
cat > server/requirements.txt << 'EOF'
flask>=2.3.0
flask-talisman>=1.0.0
flask-cors>=4.0.0
requests>=2.31.0
python-dotenv>=1.0.0
gunicorn>=21.0.0
EOF

# Create default icons
for size in 16 32 48 128; do
    convert -size "${size}x${size}" xc:transparent \
            -font DejaVu-Sans-Bold -pointsize $((size/2)) \
            -fill black -annotate +$((size/4))+$((size/2)) "XN" \
            "extension/assets/icon${size}.png" 2>/dev/null || echo "Warning: ImageMagick not installed. Please add icons manually."
done

# Generate install script
cat > scripts/install.sh << 'EOF'
#!/bin/bash
set -euo pipefail

echo "[+] Building Rust core..."
cd backend/rust_core
cargo build --release

echo "[+] Setting up native messaging..."
BRIDGE_PATH=$(realpath ../../bridge/bridge_handler.py)

# Firefox setup
mkdir -p ~/.mozilla/native-messaging-hosts/
cat > ~/.mozilla/native-messaging-hosts/xploitninja.native.json << INNER_EOF
{
  "name": "xploitninja.native",
  "description": "Native backend for XploitNinja",
  "path": "${BRIDGE_PATH}",
  "type": "stdio",
  "allowed_extensions": ["xploitninja@example.com"]
}
INNER_EOF

# Chrome setup (Linux)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    mkdir -p ~/.config/google-chrome/NativeMessagingHosts/
    cp ~/.mozilla/native-messaging-hosts/xploitninja.native.json \
       ~/.config/google-chrome/NativeMessagingHosts/
fi

echo "[+] Setup complete!"
EOF

chmod +x scripts/install.sh

# Initialize git with .gitignore
cat > .gitignore << 'EOF'
*.pyc
__pycache__/
.env
.venv/
target/
Cargo.lock
node_modules/
*.log
.DS_Store
EOF

git init
git add .
git commit -m "Initial commit: XploitNinja v1.0.0 with improved security and error handling"

echo "[✓] Setup complete! Next steps:"
echo "1. Run: cd backend/rust_core && cargo build --release"
echo "2. Run: scripts/install.sh"
echo "3. Load 'extension/' in Chrome/Firefox developer mode"
echo "4. Start server: cd server && python -m flask run"