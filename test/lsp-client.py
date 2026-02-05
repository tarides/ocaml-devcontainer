#!/usr/bin/env python3
"""
Minimal LSP client for testing ocaml-lsp-server.

Usage:
    python3 lsp-client.py <command> [args...]

Commands:
    initialize      Send initialize request
    hover <file> <line> <col>    Request hover info
    completion <file> <line> <col>    Request completions
    format <file>   Request formatting
    shutdown        Send shutdown request
"""

import json
import subprocess
import sys
from pathlib import Path


class LSPClient:
    def __init__(self):
        self.proc = subprocess.Popen(
            ["ocamllsp"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        self.request_id = 0

    def _send(self, message: dict) -> None:
        content = json.dumps(message)
        header = f"Content-Length: {len(content)}\r\n\r\n"
        self.proc.stdin.write(header.encode())
        self.proc.stdin.write(content.encode())
        self.proc.stdin.flush()

    def _receive(self) -> dict:
        # Read header
        headers = {}
        while True:
            line = self.proc.stdout.readline().decode().strip()
            if not line:
                break
            key, value = line.split(": ", 1)
            headers[key] = value

        # Read content
        content_length = int(headers["Content-Length"])
        content = self.proc.stdout.read(content_length).decode()
        return json.loads(content)

    def request(self, method: str, params: dict = None) -> dict:
        self.request_id += 1
        message = {
            "jsonrpc": "2.0",
            "id": self.request_id,
            "method": method,
        }
        if params:
            message["params"] = params
        self._send(message)
        return self._receive()

    def notify(self, method: str, params: dict = None) -> None:
        message = {
            "jsonrpc": "2.0",
            "method": method,
        }
        if params:
            message["params"] = params
        self._send(message)

    def initialize(self, root_path: str = ".") -> dict:
        root_uri = Path(root_path).absolute().as_uri()
        return self.request("initialize", {
            "processId": None,
            "rootUri": root_uri,
            "capabilities": {
                "textDocument": {
                    "hover": {"contentFormat": ["markdown", "plaintext"]},
                    "completion": {
                        "completionItem": {"snippetSupport": False}
                    },
                    "formatting": {},
                }
            },
        })

    def initialized(self) -> None:
        self.notify("initialized", {})

    def did_open(self, file_path: str, content: str = None) -> None:
        path = Path(file_path).absolute()
        if content is None:
            content = path.read_text()
        self.notify("textDocument/didOpen", {
            "textDocument": {
                "uri": path.as_uri(),
                "languageId": "ocaml",
                "version": 1,
                "text": content,
            }
        })

    def hover(self, file_path: str, line: int, col: int) -> dict:
        path = Path(file_path).absolute()
        return self.request("textDocument/hover", {
            "textDocument": {"uri": path.as_uri()},
            "position": {"line": line, "character": col},
        })

    def completion(self, file_path: str, line: int, col: int) -> dict:
        path = Path(file_path).absolute()
        return self.request("textDocument/completion", {
            "textDocument": {"uri": path.as_uri()},
            "position": {"line": line, "character": col},
        })

    def formatting(self, file_path: str) -> dict:
        path = Path(file_path).absolute()
        return self.request("textDocument/formatting", {
            "textDocument": {"uri": path.as_uri()},
            "options": {"tabSize": 2, "insertSpaces": True},
        })

    def shutdown(self) -> dict:
        return self.request("shutdown")

    def exit(self) -> None:
        self.notify("exit")
        self.proc.wait()


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    command = sys.argv[1]
    client = LSPClient()

    try:
        if command == "initialize":
            root = sys.argv[2] if len(sys.argv) > 2 else "."
            result = client.initialize(root)
            print(json.dumps(result, indent=2))
            client.initialized()

        elif command == "hover":
            if len(sys.argv) < 5:
                print("Usage: lsp-client.py hover <file> <line> <col>")
                sys.exit(1)
            client.initialize()
            client.initialized()
            file_path, line, col = sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
            client.did_open(file_path)
            result = client.hover(file_path, line, col)
            print(json.dumps(result, indent=2))

        elif command == "completion":
            if len(sys.argv) < 5:
                print("Usage: lsp-client.py completion <file> <line> <col>")
                sys.exit(1)
            client.initialize()
            client.initialized()
            file_path, line, col = sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
            client.did_open(file_path)
            result = client.completion(file_path, line, col)
            print(json.dumps(result, indent=2))

        elif command == "format":
            if len(sys.argv) < 3:
                print("Usage: lsp-client.py format <file>")
                sys.exit(1)
            client.initialize()
            client.initialized()
            file_path = sys.argv[2]
            client.did_open(file_path)
            result = client.formatting(file_path)
            print(json.dumps(result, indent=2))

        elif command == "shutdown":
            client.initialize()
            client.initialized()
            result = client.shutdown()
            print(json.dumps(result, indent=2))
            client.exit()

        else:
            print(f"Unknown command: {command}")
            print(__doc__)
            sys.exit(1)

    finally:
        if client.proc.poll() is None:
            client.proc.terminate()


if __name__ == "__main__":
    main()
