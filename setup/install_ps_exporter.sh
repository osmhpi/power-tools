set -e

id -u node_exporter &>/dev/null || useradd --no-create-home --shell /bin/false node_exporter

# install go
add-apt-repository ppa:longsleep/golang-backports
apt-get update
apt-get install golang-go

# Download go bin
go get github.com/hpi-power-rangers/ps-exporter
cp ~/go/bin/ps-exporter /usr/local/bin

# Service
mkdir /usr/local/ps_exporter
cp .ps_exporter/ps_exporter.sh /usr/local/ps_exporter
cp ./systemd/ps_exporter.service /etc/systemd/sytem

# Start service
systemctl daemon-reload
systemctl start ps_exporter

# Log service status
systemctl status ps_exporter

