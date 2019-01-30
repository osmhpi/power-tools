package targets

import (
	"encoding/json"
	"io/ioutil"
	"os"
	"strconv"
	"sync"
)

var fileLock sync.Mutex

// Label json field
type Label struct {
	Name string `json:"name"`
}

// Exporter json field
type Exporter struct {
	Targets []string `json:"targets"`
	Labels  []Label  `json:"labels"`
}

// RegisterTarget registers a new target
func RegisterTarget(label string, host string, port int, filepath string) error {
	fileLock.Lock()
	defer fileLock.Unlock()
	target := host + ":" + strconv.Itoa(port)
	exporters, loadErr := loadExporterJSON(filepath)
	if loadErr != nil {
		return loadErr
	}
	exporters = addTarget(exporters, target, label)
	saveErr := saveExporterJSON(exporters, filepath)
	if saveErr != nil {
		return saveErr
	}
	return nil
}

func addTarget(exporters []Exporter, newTarget string, newLabel string) []Exporter {
	for i, exporter := range exporters {
		for _, label := range exporter.Labels {
			if label.Name == newLabel {
				exporters[i] = extendExporter(exporter, newTarget)
				return exporters
			}
		}
	}
	newExporter := Exporter{
		Targets: []string{newTarget},
		Labels:  []Label{Label{Name: newLabel}},
	}
	return append(exporters, newExporter)
}

func extendExporter(exporter Exporter, target string) Exporter {
	for _, t := range exporter.Targets {
		if t == target {
			return exporter
		}
	}
	exporter.Targets = append(exporter.Targets, target)
	return exporter
}

func loadExporterJSON(filename string) ([]Exporter, error) {
	if _, err := os.Stat(filename); os.IsNotExist(err) {
		os.Create(filename)
		ioutil.WriteFile(filename, []byte("[]"), 0644)
	}
	data, readErr := ioutil.ReadFile(filename)
	if readErr != nil {
		return nil, readErr
	}
	var exporter []Exporter
	decodeErr := json.Unmarshal([]byte(data), &exporter)
	if decodeErr != nil {
		return nil, decodeErr
	}
	return exporter, nil
}

func saveExporterJSON(exporter []Exporter, filename string) error {
	exporterJSON, encodeErr := json.Marshal(exporter)
	if encodeErr != nil {
		return encodeErr
	}
	writeErr := ioutil.WriteFile(filename, exporterJSON, 0644)
	if writeErr != nil {
		return writeErr
	}
	return nil
}
