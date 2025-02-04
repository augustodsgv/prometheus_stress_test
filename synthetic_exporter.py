import http.server
import random
import socketserver
import os
METRICS_COUNT = int(os.environ.get('METRICS_COUNT', 100_000))
METRICS_NAME = os.environ.get('METRICS_NAME', 'stress_test')
PORT = int(os.environ.get('PORT', 8000))
LABELS = {}

def gen_metric(
        metric_name: str,
        metric_value: str,
        metric_type: str,
        metric_help: str,
        labels: dict = None
    ) -> str:
    """
    Builds a metric string with help, type, value and labels
    """
    metric = []
    metric.append(f"# HELP {metric_name} {metric_help}\n")
    metric.append(f"# TYPE {metric_name} {metric_type}\n")
    metric.append(f"{metric_name}")
    metric.append("{")
    if labels:
        for key, value in labels.items():
            metric.append(f"{key}=\"{value}\",")
        metric[-1] = metric[-1][:-1]
    metric.append("} ")
    metric.append(metric_value)
    metric.append("\n")

    return "".join(metric)


def stress_test_metrics(
        metrics_count: int,
        metric_name: str
    ) -> str:
    """
    Generates metric_count metrics with random values
    """
    metric_payload = []
    for i in range(metrics_count):
        metric_value = random.uniform(0, 100)
        metric_payload.append(gen_metric(f"{metric_name}_{i}", str(metric_value), "gauge", "Stress test metric", {"instance": i}))
    return "".join(metric_payload)

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        """
        Handles the GET request
        """
        if self.path == "/metrics":
            self.send_response(200)
            self.send_header("Content-type", "text/html")
            self.end_headers()
            next_file = stress_test_metrics(METRICS_COUNT, METRICS_NAME)
            self.wfile.write(next_file.encode('utf-8'))
        else:
            self.send_response(404)
            self.end_headers()

def main():

    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print(f"Serving on port {PORT}")
        httpd.serve_forever()

if __name__ == "__main__":
    main()