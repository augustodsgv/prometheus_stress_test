import http.server
import random
import socketserver
import os
import threading
import time
import itertools
"""
A metric has the following format:
metric_name{label1="value1", label2="value2"} value
It's composed by a name, labels (and it's values) and a value
"""

METRICS_BASE_NAME = ...
METRIC_COUNT = ...
LABELS_BASE_NAME = ...
LABEL_COUNT = ...
LABEL_VALUES_COUNT = ...
CUSTOM_LABELS = ...
PORT = ...
REFRESH_INTERVAL = ...
PAYLOAD = "Generating metrics..."

def gen_stress_test_metrics(
        metrics_count: int,
        labels_count: int,
        label_values_count: int,
        default_labels: dict[str, str] = {}
    ) -> str:
    """
    Generates metric_count metrics with random values
    """
    metric_name = METRICS_BASE_NAME
    metric_payload = []
    label_comb = gen_labels(labels_count, label_values_count)

    for label in label_comb:
        label.update(default_labels)            # Add default labels to the label combination

    for i in range(metrics_count):
        metric = gen_metric(
            metric_help=f"Stress test metric {i}",
            metric_type="gauge",
            metric_name=f'{metric_name}_{i}',
            label_combinations=label_comb
            )
        metric_payload.append(metric)

    return "".join(metric_payload)

def gen_metric(
        metric_help: str,
        metric_name: str = "metric",
        metric_type: str = "gauge",         # Default metric type is gauge
        label_combinations: list[dict[str, str]] = []
    ) -> str:
    """
    Builds a metric string with help, type, value and labels:

    # HELP metric_name metric_help
    # TYPE metric_name metric_type
    metric_name{label1="value1", label2="value1"} metric_value
    metric_name{label1="value1", label2="value2"} metric_value
    ...
    metric_name{label1="value1", label2="value_n"} metric_value
    metric_name{label1="value2", label2="value1"} metric_value
    ...
    metric_name{label1="value_n", label2="value_n"} metric_value
    """
    metric = []
    metric.append(f"# HELP {metric_name} {metric_help}\n")
    metric.append(f"# TYPE {metric_name} {metric_type}\n")
    if not label_combinations:
        ts_value = random.uniform(0, 100)
        metric.append(gen_metric_time_serie(metric_name, ts_value))
        metric.append("\n")

    for labels in label_combinations:
        ts_value = random.uniform(0, 100)
        metric.append(gen_metric_time_serie(metric_name, ts_value, labels))
        metric.append("\n")

    return "".join(metric)

def gen_metric_time_serie(
        metric_name: str,
        time_serie_value: str,
        labels: dict = {}
    ) -> str:
    """
    Builds a metric time serie string in the following format:
    metric_name{label1="value1", label2="value2"} metric_value
    """
    metric_ts = []
    metric_ts.append(f"{metric_name}")

    if not labels:
        metric_ts.append(" ")
        metric_ts.append(str(time_serie_value))
        return "".join(metric_ts)
    
    metric_ts.append("{")
    label_list = list(labels.items())
    for key, value in label_list[:-1]:          # last element doesn't have a comma
        metric_ts.append(f"{key}=\"{value}\",")
    last_label = label_list[-1]
    metric_ts.append(f"{last_label[0]}=\"{last_label[1]}\"")
    metric_ts.append("} ")
    metric_ts.append(str(time_serie_value))
    return "".join(metric_ts)

def gen_labels(
        labels_count: int,
        label_values_count: int,
        labels_base_name: str = "label",
        label_values_base_name: str = "value",
    ) -> list[dict[str,str]]:
    """
    Generates a list of all possible labels combinations
    label1=value1, label2=value2, label3=value3, ...
    """
    label_names = gen_label_names(labels_count, labels_base_name)
    values = gen_label_values(label_values_count, label_values_base_name)
    label_combinations = itertools.product(values, repeat=labels_count)         # Generates a list of label combinations. For example, if list has [A, B, C], generates [A, B], [A, C], [B, C] 
    label_dicts = []
    for combination in label_combinations:
        label_dict = dict(zip(label_names, combination))
        label_dicts.append(label_dict)

    return label_dicts



def gen_label_names(
        labels_count: int,
        labels_base_name: str = "label"
    ) -> list:
    """
    Generates various labels for a metric
    label_base_name_0, label_base_name_1, label_base_name_2, ...
    """
    names = list()
    for i in range(labels_count):
        names.append(f"{labels_base_name}_{i}")
    return names

def gen_label_values(
        labels_values_count: int,
        values_base_name: str = "value",
    ) -> list:
    """
    Generates various values for a label
    values_base_name_0, values_base_name_1, values_base_name_2, ...
    """
    values = list()
    for i in range(labels_values_count):
        values.append(f"{values_base_name}_{i}")
    return values

def update_payload():
    """
    Thread to update the PAYLOAD every 10 seconds
    """
    global PAYLOAD
    while True:
        PAYLOAD = gen_stress_test_metrics(
            metrics_count=METRIC_COUNT,
            labels_count=LABEL_COUNT,
            label_values_count=LABEL_VALUES_COUNT,
            default_labels=CUSTOM_LABELS
            )
        time.sleep(REFRESH_INTERVAL)

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        """
        Handles the GET request
        """
        if self.path == "/metrics":
            self.send_response(200)
            self.send_header("Content-type", "text/plain")
            self.end_headers()
            self.wfile.write(PAYLOAD.encode('utf-8'))
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"Not Found")


def main():
    # get environment variables
    global METRICS_BASE_NAME, METRIC_COUNT, LABELS_BASE_NAME, LABEL_COUNT, LABEL_VALUES_COUNT, CUSTOM_LABELS, PORT, REFRESH_INTERVAL

    METRICS_BASE_NAME = os.environ.get('METRICS_BASE_NAME', 'stress_test')
    METRIC_COUNT = int(os.environ.get('METRIC_COUNT', 1000))
    LABELS_BASE_NAME = os.environ.get('LABEL_BASE_NAME', 'label')
    LABEL_COUNT = int(os.environ.get('LABEL_COUNT', 0))
    LABEL_VALUES_COUNT = int(os.environ.get('LABEL_VALUES_COUNT', 1))

    print(f"Number of distinct time series: {METRIC_COUNT * LABEL_VALUES_COUNT ** LABEL_COUNT}")
    print(f"Number of different metrics: {METRIC_COUNT}")
    print(f"Number of different labels: {LABEL_COUNT}")
    print(f"Number of different labels values: {LABEL_VALUES_COUNT}")

    CUSTOM_LABELS = {}
    for key, value in os.environ.items():
        if key.startswith('SE_LABEL'):
            label_key = key.removeprefix('SE_LABEL_').lower()
            CUSTOM_LABELS[label_key] = value
    print(f"Custom labels: {CUSTOM_LABELS}")

    PORT = int(os.environ.get('PORT', 8000))
    REFRESH_INTERVAL = int(os.environ.get('REFRESH_INTERVAL', 10))
    # Setting a daemon thread to update the payload
    update_thread = threading.Thread(target=update_payload)
    update_thread.daemon = True
    update_thread.start()

    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print(f"Serving on port {PORT}")
        httpd.serve_forever()

if __name__ == "__main__":
    main()