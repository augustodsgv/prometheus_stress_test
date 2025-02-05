# Prometheus Stress Test
This program generates a Prometheus exporter capable of generating tons os metrics.
This has support to create load via: 
1. Creating a lot of metrics
2. Creating a lot o labels
3. Creating a lot of label combinations
Use it wisely, as things grow really fast

## Deploying
To deploy it, you can either run the python directly or use the container.

### Configuration 
All configuration is done via environment variables, so it allow it to scale without any config file.
The possible configuration are listed bellow:
* __PORT__: Port that the exporter will bind to expose it's server.
* __REFRESH_INTERVAL__: Time that the exporter will generate new metrics
* __METRICS_BASE_NAME__: Base name of the metrics.
New metrics will be generated agregating their indexes to the end of the base name. For example, if `METRICS_BASE_NAME=super_metric`, metric will be named `super_metric_0{}`, `super_metric_1{}`, ... and so on 
* __METRIC_COUNT__:  Number o metrics that will be generated
* __LABELS_BASE_NAME__: Base name to create labels
Each metric may have many different labels. These labels are compose by the base name, just like METRICS_BASE_NAME. For example `LABELS_BASE_NAME=monster_label` will generate labels `metric{monster_label_1='foo', monster_label_2='bar', ...}`
* __LABEL_COUNT__: Number of labels to create 
* __LABEL_VALUES_COUNT__: Number of values to create to each label.
A label can assume various values. This indicates the amount of values each label can assume. For example, if `LABEL_VALUES_COUNT==3`, a label could assume the following values
`metric{label_1='value_1'`, `metric{label_1='value_2'`, `metric{label_1='value3'`.
By default, at lease one value is created, if label_count is > 0.

In adition to that, this exporter also accepts custom labels, that will be applied to all time metrics.
They can be added by setting environment variables starting with `SE_LABEL_`.
For example, if you set `SE_LABEL_FRUIT=jabuticaba`, all metrics will have the label: `metric{..., fruit='jabuticaba'}`

An environmet set is followed:
```
PORT=18000
METRICS_BASE_NAME="synthetic_metric"
METRIC_COUNT="1000"
REFRESH_INTERVAL="10"
LABEL_COUNT="4"
LABEL_VALUES_COUNT="4"
SE_LABEL_FOO="foo"
SE_LABEL_BAR="bar"
```
### Deoployment using Python
This project does not demand any lib, so you can run it in vanila python
```sh
export PORT=18000
export METRICS_BASE_NAME="synthetic_metric"
...
python3 synthetic_exporter.py
```

### Deployment using Docker
A docker image is provided in this repo, and make it easier to plan multi-target stress tests. To run so:
```
docker build -t synthetic-exporter .
docker run -d --name synthetic-exporter \
    -p 18000:18000 \
    -e PORT=18000 \
    -e METRICS_BASE_NAME="synthetic_metric" \
    -e METRIC_COUNT="1000" \
    -e REFRESH_INTERVAL="10" \
    -e LABEL_COUNT="4" \
    -e LABEL_VALUES_COUNT="4" \
    -e SE_LABEL_FOO="foo" \
    -e SE_LABEL_BAR="bar" \
    synthetic-exporter
```

## Notes on metrics generation
* This exporter is capable of generation a lot metrics per exporter, what can be kind of costy. Consider using multiple exporters to achieve other magnitude of metrics scale.
* The number of independent time series generated is given by __METRIC_COUNT__ * (__LABEL_VALUES_COUNT__) ^ (__LABEL_COUNT__). So increase the number of labels wisely
