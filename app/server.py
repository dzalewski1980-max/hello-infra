from http.server import BaseHTTPRequestHandler, HTTPServer


class MyHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-Type", "text/html")
        self.end_headers()
        self.wfile.write(b"<h1>Hello Interview Task</h1>")

    def log_message(self, fmt, *args):
        pass


if __name__ == "__main__":
    port = 8080
    srv = HTTPServer(("0.0.0.0", port), MyHandler)
    print(f"runnig on http://localhost:{port}")
    srv.serve_forever()
