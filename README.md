# WaterMonitor

## Starting as Service on boot

sudo cp water-monitor.service /etc/systemd/system/water-monitor.service
sudo systemctl enable water-monitor.service 

## Debugging Service

Start: sudo systemctl start water-monitor
Stop: sudo systemctl stop water-monitor
Status: sudo systemctl status water-monitor
Restart: sudo systemctl restart water-monitor
Disable on Boot: sudo systemctl disable water-monitor.service
