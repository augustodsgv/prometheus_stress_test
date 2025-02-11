package main

import (
	"fmt"
	"math/rand"
	"net/http"
	"os"
	"strconv"
	"strings"
	"sync"
	"time"

)

var (
	payload string
	mu 	sync.Mutex
)

func main() {
	// Treating env vars
	metricsBaseName := os.Getenv("METRICS_BASE_NAME")
	if metricsBaseName == "" {
		metricsBaseName = "stress_test"
	}

	metricCountStr := os.Getenv("METRIC_COUNT")
	metricCount := 1000
	if metricCountStr != "" {
		var err error
		metricCount, err = strconv.Atoi(metricCountStr)
		if err != nil {
			fmt.Println("Error: parsing METRIC_COUNT integer:", err)
			os.Exit(1)
		}
	}

	labelsBaseName := os.Getenv("LABEL_BASE_NAME")
	if labelsBaseName == "" {
		labelsBaseName = "label"
	}

	labelCountStr := os.Getenv("LABEL_COUNT")
	labelCount := 0
	if labelCountStr != "" {
		var err error
		labelCount, err = strconv.Atoi(labelCountStr)
		if err != nil {
			fmt.Println("Error: parsing LABEL_COUNT:", err)
			os.Exit(1)
		}
	}

	labelValuesCountStr := os.Getenv("LABEL_VALUES_COUNT")
	labelValuesCount := 1
	if labelValuesCountStr != "" {
		var err error
		labelValuesCount, err = strconv.Atoi(labelValuesCountStr)
		if err != nil {
			fmt.Println("Error: parsing LABEL_VALUES_COUNT:", err)
			os.Exit(1)
		}
	}

	refreshIntervalStr := os.Getenv("REFRESH_INTERVAL")
	refreshInterval := 5
	if refreshIntervalStr != "" {
		var err error
		refreshInterval, err = strconv.Atoi(refreshIntervalStr)
		if err != nil {
			fmt.Println("Error: parsing REFRESH_INTERVAL:", err)
			os.Exit(1)
		}
	}
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	customLabels := make(map[string]string)
	for _, env := range os.Environ() {
		pair := strings.SplitN(env, "=", 2)
		key, value := pair[0], pair[1]
		if strings.HasPrefix(key, "SE_LABEL") {
			labelKey := strings.ToLower(strings.TrimPrefix(key, "SE_LABEL_"))
			customLabels[labelKey] = value
		}
	}

	fmt.Printf("Custom labels: %v\n", customLabels)
	fmt.Println("METRICS_BASE_NAME:", metricsBaseName)
	fmt.Println("METRIC_COUNT:", metricCount)
	fmt.Println("LABELS_BASE_NAME:", labelsBaseName)
	fmt.Println("LABEL_COUNT:", labelCount)
	fmt.Println("LABEL_VALUES_COUNT:", labelValuesCount)

	// Pre-calculate the labels, which are the most costly operation
	labels := genLabels(labelCount, labelValuesCount, labelsBaseName, "value",customLabels)
	payload = genMultipleMetrics(metricsBaseName, metricCount, labels)
	// Start the metrics generation on a second thread
	go func() {
		ticker := time.NewTicker(time.Duration(refreshInterval) * time.Second)
		defer ticker.Stop()

		for range ticker.C {
			generatePayload(metricsBaseName, metricCount, labels)
		}
	}()

	http.HandleFunc("/metrics", func(w http.ResponseWriter, r *http.Request) {
		mu.Lock()
		fmt.Fprint(w, payload)
		mu.Unlock()
	})

    fmt.Println("Starting server at port 8080")
    http.ListenAndServe(":"+port, nil)
}

func generatePayload(metricsBaseName string, metricCount int, labels []map[string]string) {
	newPayload := genMultipleMetrics(metricsBaseName, metricCount, labels)
	mu.Lock()
	payload = newPayload
	mu.Unlock()
}

func genMultipleMetrics(metricBaseName string, metricCount int,	labels []map[string]string) string{
	payload := []string{}
	for i := 0; i < metricCount; i++ {
		metricName := fmt.Sprintf("%s_%d", metricBaseName, i)
		metricHelp := fmt.Sprintf("Help for metric %s", metricName)
		metricType := "gauge"
		payload = append(payload, genMetric(metricHelp, metricName, metricType, labels))
	}
	return strings.Join(payload, "")
}

func genMetric(metricHelp string, metricName string, metricType string, labels[]map[string]string) string {
	/*
	Builds a metric string with help, type, value and labels:
	HELP metric_name metric_help
    # TYPE metric_name metric_type
    metric_name{label1="value1", label2="value1"} metric_value
    metric_name{label1="value1", label2="value2"} metric_value
    ...
    metric_name{label1="value1", label2="value_n"} metric_value
    metric_name{label1="value2", label2="value1"} metric_value
    ...
    metric_name{label1="value_n", label2="value_n"} metric_value
	*/
	metric := []string{}
	metric = append(metric, fmt.Sprintf("# HELP %s %s\n", metricName, metricHelp))
	metric = append(metric, fmt.Sprintf("# TYPE %s %s\n", metricName, metricType))

	if len(labels) == 0 {
		tsValue := fmt.Sprintf("%f", rand.Float64()*100)
		metric = append(metric, genMetricTimeSerie(metricName, tsValue, nil))
		metric = append(metric, "\n")
	}

	for _, labels := range labels {
		tsValue := fmt.Sprintf("%f", rand.Float64()*100)
		metric = append(metric, genMetricTimeSerie(metricName, tsValue, labels))
		metric = append(metric, "\n")
	}

	return strings.Join(metric, "")
}

func genMetricTimeSerie(metricName string, timeSerieValue string, tsLabels map[string]string) string {
	var timeSerieStr string

	if len(tsLabels) == 0 {
		timeSerieStr = fmt.Sprintf("%s %s", metricName, timeSerieValue)
	} else {
		formattedLabels := []string{}
		for k, v := range tsLabels {
			formattedLabels = append(formattedLabels, fmt.Sprintf("%s=\"%s\"", k, v))
		}
		timeSerieStr = fmt.Sprintf("%s{%s} %s", metricName, strings.Join(formattedLabels, ", "), timeSerieValue)
	}
	return timeSerieStr
}

// func formatLabels(labels map[string]string) string {
// 	var formattedLabels []string
// 	for k, v := range labels {
// 		formattedLabels = append(formattedLabels, fmt.Sprintf("%s=\"%s\"", k, v))
// 	}
// 	return strings.Join(formattedLabels, ",")
// }

func genLabels(labelsCount int, labelValuesCount int, labelsBaseName string, valuesBaseName string, customLabels map[string]string) []map[string]string {
	labels := []map[string]string{}
	labelNames := genLabelNames(labelsCount, labelsBaseName)
	labelValues := genLabelValues(labelValuesCount, valuesBaseName)
	// Generates all combination of values for the labels
	var valuesCombination [][]string
	genValuesCombinations(labelValues, labelsCount, []string{}, &valuesCombination)
	// labelNames = [label1, label2, label3]
	// valuesCombination [[value1, value1, value1], [value1, value1, value2], ..., [value3, value3, value3]]
	// [[label1: value1, label2: value1, label3: value1], [label1: value1, label2: value1, label3: value2], ..., [label1: value3, label2: value3, label3: value3]]
	for _, combination := range valuesCombination{
		labelValuesCombination := make(map[string]string)
		for labelIdx, value := range combination{
			labelValuesCombination[labelNames[labelIdx]] = value
		}
		// Adding default labels
		for defaultLabel := range customLabels {
			labelValuesCombination[defaultLabel] = customLabels[defaultLabel]
		}
		labels = append(labels, labelValuesCombination)
	}
	return labels
}

// Generates all array combinations of size lenght
func genValuesCombinations(labelsValues []string, length int, current []string, result *[][]string) {
	if len(current) == length {
		combination := make([]string, length)
		copy(combination, current)
		*result = append(*result, combination)
		return
	}
	for _, v := range labelsValues {
		genValuesCombinations(labelsValues, length, append(current, v), result)
	}
}

func genLabelNames(count int, baseName string) []string {
	names := []string{}
	for i := 0; i < count; i++ {
		names = append(names, fmt.Sprintf("%s_%d", baseName, i))
	}
	return names
}

func genLabelValues(count int, baseName string) []string {
	labels := []string{}
	for i := 0; i < count; i++ {
		labels = append(labels, fmt.Sprintf("%s_%d", baseName, i))
	}
	return labels
}
