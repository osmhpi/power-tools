package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net"
	"net/http"
	"os"
	"strconv"
)

const ipmiParam = "ipmi"
const psParam = "ps"
const nodeParam = "node"

// Label json field
type Label struct {
	Name string `json:"name"`
}

// Target json field
type Target struct {
	Targets []string `json:"targets"`
	Labels  []Label  `json:"labels"`
}

var port *int
var serviceFile *string

func main() {
	port = flag.Int("port", 9095, "Port used for the registry service")
	serviceFile = flag.String("out", "./target.json", "Exporter target file location")

	log.Printf("Running on port %d", *port)
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
		log.Printf("Error: Error parsing url params\n")
		return
	}
	appendToFile(*serviceFile, host, ipmiParam, psParam, nodeParam)
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

func appendToFile(filename string, host string, ipmiPort int, psPort int, nodePort int) {
	if _, err := os.Stat(filename); os.IsNotExist(err) {
		os.Create(filename)
		ioutil.WriteFile(filename, []byte("[]"), 0644)
	}
	data, readErr := ioutil.ReadFile(filename)
	if readErr != nil {
		log.Printf("Error decoding json: %s\n", readErr)
		return
	}
	var targets []Target
	decodeErr := json.Unmarshal([]byte(data), &targets)
	if decodeErr != nil {
		log.Printf("Error decoding json: %s\n", decodeErr)
		return
	}
	ipmiTarget := Target{
		Targets: []string{host + ":" + strconv.Itoa(ipmiPort)},
		Labels:  []Label{Label{Name: "ipmi_exporter"}},
	}
	psTarget := Target{
		Targets: []string{host + ":" + strconv.Itoa(psPort)},
		Labels:  []Label{Label{Name: "ps_exporter"}},
	}
	nodeTarget := Target{
		Targets: []string{host + ":" + strconv.Itoa(nodePort)},
		Labels:  []Label{Label{Name: "node_exporter"}},
	}
	targets = append(targets, ipmiTarget, psTarget, nodeTarget)
	log.Printf("Targets: %s\n", targets)
	targetsJSON, encodeErr := json.Marshal(targets)
	if encodeErr != nil {
		log.Printf("Error encoding json: %s\n", encodeErr)
		return
	}
	writeErr := ioutil.WriteFile(filename, targetsJSON, 0644)
	if writeErr != nil {
		log.Printf("Error writing json: %s\n", writeErr)
		return
	}
}
