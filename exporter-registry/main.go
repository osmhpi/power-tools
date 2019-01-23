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

const ipmiParam = "ipmi"
const psParam = "ps"
const nodeParam = "node"

const ipmiTargetLabel = "ipmi_exporter"
const psTargetLabel = "ps_exporter"
const nodeTargetLabel = "node_exporter"

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
	port = flag.Int("port", 9095, "Port used for the registry service")
	serviceFile = flag.String("out", "./target.json", "Exporter target file location")
	flag.Parse()
	log.Printf("Running on port %d. Registered nodes are stored in %s", *port, *serviceFile)
	http.HandleFunc("/register", registerNode)
	http.ListenAndServe(":"+strconv.Itoa(*port), nil)
}

func registerNode(w http.ResponseWriter, req *http.Request) {
	host, _, err := net.SplitHostPort(req.RemoteAddr)
	if err != nil {
		http.Error(w, "Invalid remote address format", http.StatusBadRequest)
		log.Printf("Error: Remote address '%s' has invalid format", err)
		return
	}
	ipmiParam, ipmiErr := getServicePort(req, ipmiParam)
	psParam, psErr := getServicePort(req, psParam)
	nodeParam, nodeErr := getServicePort(req, nodeParam)
	if ipmiErr != nil || psErr != nil || nodeErr != nil {
		http.Error(w, "Invalid remote address format", http.StatusBadRequest)
		log.Printf("Error parsing url params\n")
		return
	}
	if err = targets.RegisterTarget(ipmiTargetLabel, host, ipmiParam, *serviceFile); err != nil {
		http.Error(w, "Error registering target", http.StatusInternalServerError)
		log.Printf("Error registering target: %s\n", err)
		return
	}
	if err = targets.RegisterTarget(psTargetLabel, host, psParam, *serviceFile); err != nil {
		http.Error(w, "Error registering target", http.StatusInternalServerError)
		log.Printf("Error registering target: %s\n", err)
		return
	}
	if err = targets.RegisterTarget(nodeTargetLabel, host, nodeParam, *serviceFile); err != nil {
		http.Error(w, "Error registering target", http.StatusInternalServerError)
		log.Printf("Error registering target: %s\n", err)
		return
	}
	log.Printf("Registered node %s with ports: ipmi:%d, ps:%d, node:%d\n", host, ipmiParam, psParam, nodeParam)
}

func getServicePort(req *http.Request, key string) (int, error) {
	keys, ok := req.URL.Query()[key]
	if !ok || len(keys) != 1 {
		return -1, fmt.Errorf("Key %s not found in url params", key)
	}
	port, err := strconv.Atoi(keys[0])
	if err != nil {
		return -1, fmt.Errorf("Port %s is not numeric", keys[0])
	}
	return port, nil
}
