package main

import (
	"flag"
	"fmt"
	"github.com/hpi-power-rangers/power-tools/exporter-registry/targets"
	"log"
	"net"
	"net/http"
	"strconv"
)

const labelParam = "label"
const portParam = "port"

// Label json field
type Label struct {
	Name string `json:"name"`
}

// Exporter json field
type Exporter struct {
	Targets []string `json:"targets"`
	Labels  []Label  `json:"labels"`
}

var port *int
var serviceFile *string

func main() {
	port = flag.Int("port", 7249, "Port used for the registry service")
	serviceFile = flag.String("out", "./target.json", "Exporter target file location")
	flag.Parse()
	log.Printf("Running on port %d. Registered nodes are stored in %s", *port, *serviceFile)
	http.HandleFunc("/register", registerNode)
	http.HandleFunc("/broadcast", acceptBroadcast)
	log.Fatal(http.ListenAndServe(":"+strconv.Itoa(*port), nil))
}

func acceptBroadcast(w http.ResponseWriter, req *http.Request) {
	fmt.Fprintf(w, "exporter-registry")
}

func registerNode(w http.ResponseWriter, req *http.Request) {
	host, _, err := net.SplitHostPort(req.RemoteAddr)
	if err != nil {
		http.Error(w, "Invalid remote address format", http.StatusBadRequest)
		log.Printf("Error: Remote address '%s' has invalid format", err)
		return
	}
	label, labelErr := getLabel(req)
	if labelErr != nil {
		http.Error(w, "Invalid url params", http.StatusBadRequest)
		log.Printf("Error parsing url params: %s\n", labelErr)
		return
	}
	port, portErr := getServicePort(req)
	if portErr != nil {
		http.Error(w, "Invalid url params", http.StatusBadRequest)
		log.Printf("Error parsing url params: %s\n", portErr)
		return
	}

	if err = targets.RegisterTarget(label, host, port, *serviceFile); err != nil {
		http.Error(w, "Error registering target", http.StatusInternalServerError)
		log.Printf("Error registering target: %s\n", err)
		return
	}
	log.Printf("Registered nod with: label: %s, host: %s, port: %d\n", label, host, port)
}

func getServicePort(req *http.Request) (int, error) {
	keys, ok := req.URL.Query()[portParam]
	if !ok || len(keys) != 1 {
		return -1, fmt.Errorf("Param %s not found", portParam)
	}
	port, err := strconv.Atoi(keys[0])
	if err != nil {
		return -1, fmt.Errorf("Port %s is not numeric", keys[0])
	}
	return port, nil
}

func getLabel(req *http.Request) (string, error) {
	keys, ok := req.URL.Query()[labelParam]
	if !ok || len(keys) != 1 {
		return "", fmt.Errorf("Param %s not found", labelParam)
	}
	return keys[0], nil
}
