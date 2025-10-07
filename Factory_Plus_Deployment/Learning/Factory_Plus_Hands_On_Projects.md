# Factory+ Hands-On Projects
## Practical Learning Exercises for Factory+ Mastery

---

## 🎯 **Project Overview**

This guide provides hands-on projects to help you master Factory+ and the AMRC Connectivity Stack. Each project builds upon the previous one, taking you from beginner to expert level.

---

## 📋 **Prerequisites**

Before starting these projects, ensure you have:
- ✅ Factory+ system running (all services accessible)
- ✅ Basic understanding of manufacturing concepts
- ✅ Access to Manager, Visualiser, and Grafana services
- ✅ Basic knowledge of data formats (JSON, CSV)
- ✅ Understanding of MQTT and OPC UA concepts

---

## 🚀 **Project 1: Basic Data Collection Setup**

### **Objective**
Set up your first data collection system and create a basic monitoring dashboard.

### **Learning Goals**
- Understand Factory+ data flow
- Configure data schemas
- Create basic visualizations
- Learn MQTT topic structure

### **Project Steps**

#### **Step 1: Configure Your Organization**
1. **Access Manager Service**
   - Open http://localhost:8081/login
   - Log in with admin credentials
   - Navigate to Organization Settings

2. **Set Up Organization Details**
   ```json
   {
     "name": "Learning Factory",
     "domain": "learning.factoryplus.local",
     "timezone": "UTC",
     "language": "en",
     "notifications": {
       "email": "admin@learning.factoryplus.local",
       "alerts": true
     }
   }
   ```

3. **Create Your First Data Schema**
   - Navigate to Data Schemas
   - Create a new schema called "Temperature Sensor"
   - Define the schema structure:

   ```json
   {
     "name": "Temperature Sensor",
     "version": "1.0",
     "description": "Basic temperature sensor data",
     "fields": [
       {
         "name": "temperature",
         "type": "double",
         "unit": "°C",
         "description": "Temperature reading"
       },
       {
         "name": "humidity",
         "type": "double",
         "unit": "%",
         "description": "Humidity reading"
       },
       {
         "name": "timestamp",
         "type": "datetime",
         "description": "Data timestamp"
       },
       {
         "name": "sensor_id",
         "type": "string",
         "description": "Sensor identifier"
       }
     ]
   }
   ```

#### **Step 2: Simulate Data Source**
1. **Create a Python Script** (simulate_sensor.py):
   ```python
   import paho.mqtt.client as mqtt
   import json
   import time
   import random
   from datetime import datetime

   # MQTT Configuration
   MQTT_BROKER = "localhost"
   MQTT_PORT = 1883
   MQTT_TOPIC = "factory-plus/devices/temp-sensor-001/data"

   def on_connect(client, userdata, flags, rc):
       print(f"Connected with result code {rc}")

   def on_publish(client, userdata, mid):
       print(f"Message {mid} published")

   # Create MQTT client
   client = mqtt.Client()
   client.on_connect = on_connect
   client.on_publish = on_publish

   # Connect to broker
   client.connect(MQTT_BROKER, MQTT_PORT, 60)

   # Start the loop
   client.loop_start()

   # Simulate sensor data
   while True:
       # Generate random sensor data
       temperature = round(random.uniform(20.0, 30.0), 2)
       humidity = round(random.uniform(40.0, 60.0), 2)
       timestamp = datetime.now().isoformat()
       
       # Create message payload
       message = {
           "timestamp": timestamp,
           "temperature": temperature,
           "humidity": humidity,
           "sensor_id": "temp-sensor-001"
       }
       
       # Publish message
       client.publish(MQTT_TOPIC, json.dumps(message))
       print(f"Published: {message}")
       
       # Wait 5 seconds
       time.sleep(5)

   client.loop_stop()
   client.disconnect()
   ```

2. **Run the Simulation**
   ```bash
   python simulate_sensor.py
   ```

#### **Step 3: Create Basic Dashboard**
1. **Access Visualiser Service**
   - Open http://localhost:8082/
   - Create a new dashboard called "Temperature Monitoring"

2. **Add Temperature Chart**
   - Add a line chart widget
   - Configure data source: MQTT topic `factory-plus/devices/temp-sensor-001/data`
   - Set up real-time updates
   - Configure chart settings:
     - Title: "Temperature Trends"
     - Y-axis: Temperature (°C)
     - X-axis: Time
     - Update interval: 5 seconds

3. **Add Humidity Gauge**
   - Add a gauge widget
   - Configure data source: MQTT topic `factory-plus/devices/temp-sensor-001/data`
   - Set up real-time updates
   - Configure gauge settings:
     - Title: "Humidity Level"
     - Min: 0, Max: 100
     - Unit: %
     - Color scheme: Green (0-50%), Yellow (50-80%), Red (80-100%)

#### **Step 4: Test and Validate**
1. **Verify Data Flow**
   - Check that data is flowing from MQTT to Visualiser
   - Verify real-time updates
   - Test different time ranges

2. **Document Your Setup**
   - Create a project documentation file
   - Document your configuration
   - Note any issues and solutions

### **Deliverables**
- ✅ Working data simulation
- ✅ Basic dashboard with temperature and humidity
- ✅ Documentation of your setup
- ✅ Understanding of MQTT data flow

---

## 🏭 **Project 2: Production Line Monitoring**

### **Objective**
Create a comprehensive monitoring system for a simulated production line with multiple machines and sensors.

### **Learning Goals**
- Design complex data schemas
- Create multi-device dashboards
- Implement alerting systems
- Learn about production metrics

### **Project Steps**

#### **Step 1: Design Production Line Schema**
1. **Create Machine Schema**
   ```json
   {
     "name": "Production Machine",
     "version": "1.0",
     "description": "Production machine data",
     "fields": [
       {
         "name": "machine_id",
         "type": "string",
         "description": "Machine identifier"
       },
       {
         "name": "status",
         "type": "string",
         "description": "Machine status (running, stopped, error)"
       },
       {
         "name": "speed",
         "type": "double",
         "unit": "rpm",
         "description": "Machine speed"
       },
       {
         "name": "temperature",
         "type": "double",
         "unit": "°C",
         "description": "Machine temperature"
       },
       {
         "name": "vibration",
         "type": "double",
         "unit": "mm/s",
         "description": "Vibration level"
       },
       {
         "name": "production_count",
         "type": "integer",
         "description": "Total production count"
       },
       {
         "name": "timestamp",
         "type": "datetime",
         "description": "Data timestamp"
       }
     ]
   }
   ```

2. **Create Quality Schema**
   ```json
   {
     "name": "Quality Inspection",
     "version": "1.0",
     "description": "Quality inspection data",
     "fields": [
       {
         "name": "inspection_id",
         "type": "string",
         "description": "Inspection identifier"
       },
       {
         "name": "product_id",
         "type": "string",
         "description": "Product identifier"
       },
       {
         "name": "quality_score",
         "type": "double",
         "description": "Quality score (0-100)"
       },
       {
         "name": "defects",
         "type": "integer",
         "description": "Number of defects"
       },
       {
         "name": "pass_fail",
         "type": "boolean",
         "description": "Pass/fail result"
       },
       {
         "name": "timestamp",
         "type": "datetime",
         "description": "Inspection timestamp"
       }
     ]
   }
   ```

#### **Step 2: Create Production Line Simulation**
1. **Create Production Line Simulator** (production_line.py):
   ```python
   import paho.mqtt.client as mqtt
   import json
   import time
   import random
   from datetime import datetime

   class ProductionLineSimulator:
       def __init__(self):
           self.mqtt_client = mqtt.Client()
           self.mqtt_client.on_connect = self.on_connect
           self.mqtt_client.on_publish = self.on_publish
           self.mqtt_client.connect("localhost", 1883, 60)
           self.mqtt_client.loop_start()
           
           self.machines = {
               "machine-001": {"status": "running", "speed": 100, "temperature": 45, "vibration": 2.1, "production_count": 0},
               "machine-002": {"status": "running", "speed": 95, "temperature": 42, "vibration": 1.8, "production_count": 0},
               "machine-003": {"status": "stopped", "speed": 0, "temperature": 38, "vibration": 0.5, "production_count": 0}
           }
           
           self.quality_scores = []
           
       def on_connect(self, client, userdata, flags, rc):
           print(f"Connected with result code {rc}")
           
       def on_publish(self, client, userdata, mid):
           print(f"Message {mid} published")
           
       def simulate_machine_data(self):
           for machine_id, data in self.machines.items():
               # Simulate machine behavior
               if data["status"] == "running":
                   # Random variations
                   data["speed"] += random.uniform(-5, 5)
                   data["temperature"] += random.uniform(-2, 2)
                   data["vibration"] += random.uniform(-0.1, 0.1)
                   
                   # Production count increases
                   if random.random() < 0.3:  # 30% chance of producing
                       data["production_count"] += 1
                       
                   # Random status changes
                   if random.random() < 0.05:  # 5% chance of status change
                       data["status"] = random.choice(["running", "stopped", "error"])
                       
               # Create message
               message = {
                   "machine_id": machine_id,
                   "status": data["status"],
                   "speed": round(data["speed"], 2),
                   "temperature": round(data["temperature"], 2),
                   "vibration": round(data["vibration"], 2),
                   "production_count": data["production_count"],
                   "timestamp": datetime.now().isoformat()
               }
               
               # Publish to MQTT
               topic = f"factory-plus/devices/{machine_id}/data"
               self.mqtt_client.publish(topic, json.dumps(message))
               print(f"Published machine data: {message}")
               
       def simulate_quality_inspection(self):
           # Simulate quality inspection
           if random.random() < 0.2:  # 20% chance of inspection
               inspection = {
                   "inspection_id": f"insp-{int(time.time())}",
                   "product_id": f"prod-{random.randint(1000, 9999)}",
                   "quality_score": round(random.uniform(70, 100), 2),
                   "defects": random.randint(0, 3),
                   "pass_fail": random.random() > 0.1,  # 90% pass rate
                   "timestamp": datetime.now().isoformat()
               }
               
               # Publish to MQTT
               topic = "factory-plus/quality/inspections"
               self.mqtt_client.publish(topic, json.dumps(inspection))
               print(f"Published quality data: {inspection}")
               
       def run_simulation(self):
           while True:
               self.simulate_machine_data()
               self.simulate_quality_inspection()
               time.sleep(10)  # Update every 10 seconds

   if __name__ == "__main__":
       simulator = ProductionLineSimulator()
       simulator.run_simulation()
   ```

#### **Step 3: Create Production Dashboard**
1. **Access Visualiser Service**
   - Create a new dashboard called "Production Line Monitoring"

2. **Add Machine Status Panel**
   - Create a status panel showing all machines
   - Use color coding: Green (running), Red (error), Yellow (stopped)
   - Show machine speed, temperature, and vibration

3. **Add Production Metrics**
   - Total production count
   - Production rate (items per hour)
   - Efficiency metrics
   - Quality scores

4. **Add Real-time Charts**
   - Temperature trends for all machines
   - Vibration levels
   - Speed variations
   - Quality score trends

#### **Step 4: Implement Alerting**
1. **Access Grafana Service**
   - Create alert rules for:
     - High temperature (>50°C)
     - High vibration (>3.0 mm/s)
     - Machine stopped
     - Low quality score (<80)

2. **Configure Notifications**
   - Set up email notifications
   - Create alert channels
   - Test alert system

### **Deliverables**
- ✅ Production line simulation
- ✅ Multi-machine dashboard
- ✅ Quality monitoring system
- ✅ Alert configuration
- ✅ Documentation

---

## 🔧 **Project 3: Advanced Analytics and Machine Learning**

### **Objective**
Implement advanced analytics and machine learning capabilities for predictive maintenance and optimization.

### **Learning Goals**
- Understand time-series analysis
- Implement predictive models
- Create advanced visualizations
- Learn about anomaly detection

### **Project Steps**

#### **Step 1: Enhanced Data Collection**
1. **Create Advanced Sensor Schema**
   ```json
   {
     "name": "Advanced Sensor",
     "version": "2.0",
     "description": "Advanced sensor with multiple parameters",
     "fields": [
       {
         "name": "sensor_id",
         "type": "string",
         "description": "Sensor identifier"
       },
       {
         "name": "temperature",
         "type": "double",
         "unit": "°C",
         "description": "Temperature reading"
       },
       {
         "name": "pressure",
         "type": "double",
         "unit": "bar",
         "description": "Pressure reading"
       },
       {
         "name": "flow_rate",
         "type": "double",
         "unit": "L/min",
         "description": "Flow rate"
       },
       {
         "name": "vibration_x",
         "type": "double",
         "unit": "mm/s",
         "description": "X-axis vibration"
       },
       {
         "name": "vibration_y",
         "type": "double",
         "unit": "mm/s",
         "description": "Y-axis vibration"
       },
       {
         "name": "vibration_z",
         "type": "double",
         "unit": "mm/s",
         "description": "Z-axis vibration"
       },
       {
         "name": "power_consumption",
         "type": "double",
         "unit": "kW",
         "description": "Power consumption"
       },
       {
         "name": "timestamp",
         "type": "datetime",
         "description": "Data timestamp"
       }
     ]
   }
   ```

#### **Step 2: Create Advanced Simulator**
1. **Create Advanced Simulator** (advanced_simulator.py):
   ```python
   import paho.mqtt.client as mqtt
   import json
   import time
   import random
   import math
   from datetime import datetime

   class AdvancedSimulator:
       def __init__(self):
           self.mqtt_client = mqtt.Client()
           self.mqtt_client.on_connect = self.on_connect
           self.mqtt_client.on_publish = self.on_publish
           self.mqtt_client.connect("localhost", 1883, 60)
           self.mqtt_client.loop_start()
           
           self.sensors = {
               "sensor-001": {"base_temp": 45, "base_pressure": 2.5, "base_flow": 100},
               "sensor-002": {"base_temp": 42, "base_pressure": 2.3, "base_flow": 95},
               "sensor-003": {"base_temp": 48, "base_pressure": 2.7, "base_flow": 105}
           }
           
           self.time_step = 0
           
       def on_connect(self, client, userdata, flags, rc):
           print(f"Connected with result code {rc}")
           
       def on_publish(self, client, userdata, mid):
           print(f"Message {mid} published")
           
       def generate_realistic_data(self, sensor_id, base_values):
           # Add realistic variations and trends
           self.time_step += 1
           
           # Temperature with daily cycle
           temp_cycle = math.sin(self.time_step * 0.01) * 5
           temperature = base_values["base_temp"] + temp_cycle + random.uniform(-2, 2)
           
           # Pressure with gradual changes
           pressure = base_values["base_pressure"] + random.uniform(-0.1, 0.1)
           
           # Flow rate with correlation to pressure
           flow_rate = base_values["base_flow"] + (pressure - 2.5) * 20 + random.uniform(-5, 5)
           
           # Vibration with machine wear simulation
           wear_factor = 1 + (self.time_step * 0.0001)  # Gradual wear
           vibration_x = random.uniform(0.5, 2.0) * wear_factor
           vibration_y = random.uniform(0.3, 1.8) * wear_factor
           vibration_z = random.uniform(0.2, 1.5) * wear_factor
           
           # Power consumption correlated with flow and temperature
           power = (flow_rate * 0.1) + (temperature * 0.05) + random.uniform(-2, 2)
           
           return {
               "sensor_id": sensor_id,
               "temperature": round(temperature, 2),
               "pressure": round(pressure, 2),
               "flow_rate": round(flow_rate, 2),
               "vibration_x": round(vibration_x, 3),
               "vibration_y": round(vibration_y, 3),
               "vibration_z": round(vibration_z, 3),
               "power_consumption": round(power, 2),
               "timestamp": datetime.now().isoformat()
           }
           
       def simulate_sensor_data(self):
           for sensor_id, base_values in self.sensors.items():
               data = self.generate_realistic_data(sensor_id, base_values)
               
               # Publish to MQTT
               topic = f"factory-plus/devices/{sensor_id}/data"
               self.mqtt_client.publish(topic, json.dumps(data))
               print(f"Published sensor data: {data}")
               
       def run_simulation(self):
           while True:
               self.simulate_sensor_data()
               time.sleep(5)  # Update every 5 seconds

   if __name__ == "__main__":
       simulator = AdvancedSimulator()
       simulator.run_simulation()
   ```

#### **Step 3: Create Analytics Dashboard**
1. **Access Grafana Service**
   - Create a new dashboard called "Advanced Analytics"

2. **Add Statistical Panels**
   - Mean, median, standard deviation
   - Min/max values
   - Percentiles
   - Correlation matrices

3. **Add Time-Series Analysis**
   - Moving averages
   - Trend analysis
   - Seasonal patterns
   - Anomaly detection

4. **Add Predictive Panels**
   - Forecast charts
   - Trend predictions
   - Maintenance schedules
   - Performance optimization

#### **Step 4: Implement Machine Learning**
1. **Create Anomaly Detection**
   ```python
   import numpy as np
   from sklearn.ensemble import IsolationForest
   from sklearn.preprocessing import StandardScaler
   
   class AnomalyDetector:
       def __init__(self):
           self.model = IsolationForest(contamination=0.1)
           self.scaler = StandardScaler()
           self.is_fitted = False
           
       def fit(self, data):
           # Normalize data
           normalized_data = self.scaler.fit_transform(data)
           self.model.fit(normalized_data)
           self.is_fitted = True
           
       def predict(self, data):
           if not self.is_fitted:
               return np.ones(len(data))  # No anomalies if not fitted
           
           normalized_data = self.scaler.transform(data)
           return self.model.predict(normalized_data)
           
       def detect_anomalies(self, sensor_data):
           # Extract features
           features = np.array([
               sensor_data['temperature'],
               sensor_data['pressure'],
               sensor_data['flow_rate'],
               sensor_data['vibration_x'],
               sensor_data['vibration_y'],
               sensor_data['vibration_z'],
               sensor_data['power_consumption']
           ]).reshape(1, -1)
           
           # Predict anomalies
           prediction = self.predict(features)
           return prediction[0] == -1  # -1 means anomaly
   ```

2. **Create Predictive Maintenance**
   ```python
   class PredictiveMaintenance:
       def __init__(self):
           self.maintenance_threshold = 0.8
           self.vibration_threshold = 3.0
           self.temperature_threshold = 60.0
           
       def calculate_health_score(self, sensor_data):
           # Calculate health score based on multiple factors
           vibration_score = max(0, 1 - (sensor_data['vibration_x'] / self.vibration_threshold))
           temperature_score = max(0, 1 - (sensor_data['temperature'] / self.temperature_threshold))
           
           # Combine scores
           health_score = (vibration_score + temperature_score) / 2
           return health_score
           
       def predict_maintenance(self, sensor_data):
           health_score = self.calculate_health_score(sensor_data)
           needs_maintenance = health_score < self.maintenance_threshold
           
           return {
               'health_score': health_score,
               'needs_maintenance': needs_maintenance,
               'maintenance_urgency': 'high' if health_score < 0.5 else 'medium' if health_score < 0.7 else 'low'
           }
   ```

### **Deliverables**
- ✅ Advanced sensor simulation
- ✅ Analytics dashboard
- ✅ Anomaly detection system
- ✅ Predictive maintenance
- ✅ Machine learning models
- ✅ Documentation

---

## 🌐 **Project 4: System Integration and API Development**

### **Objective**
Create a complete integration system with external APIs, webhooks, and custom applications.

### **Learning Goals**
- Understand API development
- Learn webhook integration
- Create custom applications
- Implement security best practices

### **Project Steps**

#### **Step 1: Create REST API**
1. **Create API Server** (api_server.py):
   ```python
   from flask import Flask, request, jsonify
   from flask_cors import CORS
   import paho.mqtt.client as mqtt
   import json
   from datetime import datetime
   import uuid

   app = Flask(__name__)
   CORS(app)

   class FactoryPlusAPI:
       def __init__(self):
           self.mqtt_client = mqtt.Client()
           self.mqtt_client.on_connect = self.on_connect
           self.mqtt_client.connect("localhost", 1883, 60)
           self.mqtt_client.loop_start()
           
       def on_connect(self, client, userdata, flags, rc):
           print(f"MQTT Connected with result code {rc}")
           
       def publish_command(self, device_id, command):
           topic = f"factory-plus/devices/{device_id}/commands"
           self.mqtt_client.publish(topic, json.dumps(command))
           
   api = FactoryPlusAPI()

   @app.route('/api/devices', methods=['GET'])
   def get_devices():
       # Return list of devices
       devices = [
           {"id": "device-001", "name": "Temperature Sensor 1", "type": "sensor", "status": "online"},
           {"id": "device-002", "name": "Production Machine 1", "type": "machine", "status": "running"},
           {"id": "device-003", "name": "Quality Inspector", "type": "inspector", "status": "online"}
       ]
       return jsonify(devices)

   @app.route('/api/devices/<device_id>/data', methods=['GET'])
   def get_device_data(device_id):
       # Return recent data for a device
       # This would typically query your database
       data = {
           "device_id": device_id,
           "timestamp": datetime.now().isoformat(),
           "temperature": 25.5,
           "humidity": 60.2,
           "status": "normal"
       }
       return jsonify(data)

   @app.route('/api/devices/<device_id>/commands', methods=['POST'])
   def send_device_command(device_id):
       command = request.json
       command['id'] = str(uuid.uuid4())
       command['timestamp'] = datetime.now().isoformat()
       
       # Publish command to MQTT
       api.publish_command(device_id, command)
       
       return jsonify({"status": "success", "command_id": command['id']})

   @app.route('/api/alerts', methods=['GET'])
   def get_alerts():
       # Return recent alerts
       alerts = [
           {
               "id": "alert-001",
               "device_id": "device-001",
               "type": "temperature_high",
               "message": "Temperature exceeded threshold",
               "timestamp": datetime.now().isoformat(),
               "severity": "warning"
           }
       ]
       return jsonify(alerts)

   if __name__ == '__main__':
       app.run(host='0.0.0.0', port=5000, debug=True)
   ```

#### **Step 2: Create Webhook System**
1. **Create Webhook Handler** (webhook_handler.py):
   ```python
   import requests
   import json
   from datetime import datetime

   class WebhookHandler:
       def __init__(self):
           self.webhook_urls = {
               'alerts': 'http://localhost:5000/webhook/alerts',
               'data': 'http://localhost:5000/webhook/data',
               'commands': 'http://localhost:5000/webhook/commands'
           }
           
       def send_webhook(self, event_type, data):
           if event_type in self.webhook_urls:
               try:
                   response = requests.post(
                       self.webhook_urls[event_type],
                       json=data,
                       timeout=5
                   )
                   print(f"Webhook sent: {event_type} - Status: {response.status_code}")
               except Exception as e:
                   print(f"Webhook failed: {e}")
                   
       def handle_alert(self, alert_data):
           webhook_data = {
               'event_type': 'alert',
               'timestamp': datetime.now().isoformat(),
               'data': alert_data
           }
           self.send_webhook('alerts', webhook_data)
           
       def handle_data(self, data):
           webhook_data = {
               'event_type': 'data',
               'timestamp': datetime.now().isoformat(),
               'data': data
           }
           self.send_webhook('data', webhook_data)
   ```

#### **Step 3: Create Custom Application**
1. **Create Web Application** (web_app.py):
   ```python
   from flask import Flask, render_template, request, jsonify
   import requests
   import json

   app = Flask(__name__)

   @app.route('/')
   def index():
       return render_template('index.html')

   @app.route('/api/dashboard-data')
   def get_dashboard_data():
       # Fetch data from Factory+ API
       try:
           response = requests.get('http://localhost:5000/api/devices')
           devices = response.json()
           
           # Process data for dashboard
           dashboard_data = {
               'total_devices': len(devices),
               'online_devices': len([d for d in devices if d['status'] == 'online']),
               'devices': devices
           }
           
           return jsonify(dashboard_data)
       except Exception as e:
           return jsonify({'error': str(e)}), 500

   @app.route('/api/send-command', methods=['POST'])
   def send_command():
       data = request.json
       device_id = data.get('device_id')
       command = data.get('command')
       
       try:
           response = requests.post(
               f'http://localhost:5000/api/devices/{device_id}/commands',
               json=command
           )
           return jsonify(response.json())
       except Exception as e:
           return jsonify({'error': str(e)}), 500

   if __name__ == '__main__':
       app.run(host='0.0.0.0', port=3000, debug=True)
   ```

2. **Create HTML Template** (templates/index.html):
   ```html
   <!DOCTYPE html>
   <html lang="en">
   <head>
       <meta charset="UTF-8">
       <meta name="viewport" content="width=device-width, initial-scale=1.0">
       <title>Factory+ Dashboard</title>
       <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
   </head>
   <body>
       <h1>Factory+ Dashboard</h1>
       
       <div id="devices-panel">
           <h2>Devices</h2>
           <div id="devices-list"></div>
       </div>
       
       <div id="charts-panel">
           <h2>Charts</h2>
           <canvas id="temperature-chart"></canvas>
       </div>
       
       <script>
           // Fetch dashboard data
           fetch('/api/dashboard-data')
               .then(response => response.json())
               .then(data => {
                   updateDevicesList(data.devices);
                   updateCharts(data);
               });
               
           function updateDevicesList(devices) {
               const devicesList = document.getElementById('devices-list');
               devicesList.innerHTML = devices.map(device => `
                   <div class="device-card">
                       <h3>${device.name}</h3>
                       <p>Type: ${device.type}</p>
                       <p>Status: ${device.status}</p>
                       <button onclick="sendCommand('${device.id}')">Send Command</button>
                   </div>
               `).join('');
           }
           
           function sendCommand(deviceId) {
               const command = {
                   action: 'start',
                   parameters: {}
               };
               
               fetch(`/api/send-command`, {
                   method: 'POST',
                   headers: {
                       'Content-Type': 'application/json'
                   },
                   body: JSON.stringify({
                       device_id: deviceId,
                       command: command
                   })
               })
               .then(response => response.json())
               .then(data => {
                   console.log('Command sent:', data);
               });
           }
       </script>
   </body>
   </html>
   ```

#### **Step 4: Implement Security**
1. **Add Authentication**
   ```python
   from functools import wraps
   import jwt
   from datetime import datetime, timedelta

   SECRET_KEY = 'your-secret-key'

   def token_required(f):
       @wraps(f)
       def decorated(*args, **kwargs):
           token = request.headers.get('Authorization')
           if not token:
               return jsonify({'message': 'Token is missing'}), 401
           
           try:
               data = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
               current_user = data['user']
           except:
               return jsonify({'message': 'Token is invalid'}), 401
           
           return f(current_user, *args, **kwargs)
       return decorated

   @app.route('/api/login', methods=['POST'])
   def login():
       auth = request.authorization
       
       if auth and auth.username == 'admin' and auth.password == 'password':
           token = jwt.encode({
               'user': auth.username,
               'exp': datetime.utcnow() + timedelta(hours=24)
           }, SECRET_KEY, algorithm='HS256')
           
           return jsonify({'token': token})
       
       return jsonify({'message': 'Invalid credentials'}), 401

   @app.route('/api/protected')
   @token_required
   def protected(current_user):
       return jsonify({'message': f'Hello {current_user}'})
   ```

### **Deliverables**
- ✅ REST API server
- ✅ Webhook system
- ✅ Custom web application
- ✅ Security implementation
- ✅ Documentation

---

## 🎓 **Project 5: Complete System Deployment**

### **Objective**
Deploy a complete Factory+ system with all components, monitoring, and documentation.

### **Learning Goals**
- Understand system deployment
- Learn monitoring and maintenance
- Create comprehensive documentation
- Implement backup and recovery

### **Project Steps**

#### **Step 1: System Architecture Design**
1. **Create System Architecture Document**
   ```markdown
   # Factory+ System Architecture
   
   ## Overview
   Complete Factory+ deployment with all components and integrations.
   
   ## Components
   - Manager Service (Port 8081)
   - Visualiser Service (Port 8082)
   - Grafana Service (Port 8083)
   - Auth Service (Port 8084)
   - ConfigDB Service (Port 8085)
   - Custom API Server (Port 5000)
   - Web Application (Port 3000)
   
   ## Data Flow
   1. Manufacturing Equipment → Edge Gateway → MQTT Broker
   2. MQTT Broker → InfluxDB (Time-series data)
   3. MQTT Broker → PostgreSQL (Metadata)
   4. Services → Redis (Caching)
   5. External Systems → API Server → Factory+ Services
   ```

#### **Step 2: Monitoring and Alerting**
1. **Create Monitoring Dashboard**
   - System health monitoring
   - Performance metrics
   - Resource utilization
   - Service status

2. **Implement Alerting**
   - Service down alerts
   - Performance threshold alerts
   - Security alerts
   - Maintenance alerts

#### **Step 3: Backup and Recovery**
1. **Create Backup Script**
   ```bash
   #!/bin/bash
   # backup_factory_plus.sh
   
   BACKUP_DIR="/backups/factory-plus"
   DATE=$(date +%Y%m%d_%H%M%S)
   
   # Create backup directory
   mkdir -p $BACKUP_DIR/$DATE
   
   # Backup databases
   kubectl exec -n factory-plus postgresql-0 -- pg_dump -U postgres factory_plus > $BACKUP_DIR/$DATE/postgresql.sql
   kubectl exec -n factory-plus influxdb-0 -- influxd backup $BACKUP_DIR/$DATE/influxdb
   
   # Backup configurations
   kubectl get configmap -n factory-plus -o yaml > $BACKUP_DIR/$DATE/configmaps.yaml
   kubectl get secret -n factory-plus -o yaml > $BACKUP_DIR/$DATE/secrets.yaml
   
   # Compress backup
   tar -czf $BACKUP_DIR/$DATE.tar.gz -C $BACKUP_DIR $DATE
   rm -rf $BACKUP_DIR/$DATE
   
   echo "Backup completed: $BACKUP_DIR/$DATE.tar.gz"
   ```

2. **Create Recovery Script**
   ```bash
   #!/bin/bash
   # restore_factory_plus.sh
   
   BACKUP_FILE=$1
   
   if [ -z "$BACKUP_FILE" ]; then
       echo "Usage: $0 <backup_file>"
       exit 1
   fi
   
   # Extract backup
   tar -xzf $BACKUP_FILE
   BACKUP_DIR=$(basename $BACKUP_FILE .tar.gz)
   
   # Restore databases
   kubectl exec -n factory-plus postgresql-0 -- psql -U postgres -d factory_plus -f $BACKUP_DIR/postgresql.sql
   kubectl exec -n factory-plus influxdb-0 -- influxd restore $BACKUP_DIR/influxdb
   
   # Restore configurations
   kubectl apply -f $BACKUP_DIR/configmaps.yaml
   kubectl apply -f $BACKUP_DIR/secrets.yaml
   
   echo "Recovery completed"
   ```

#### **Step 4: Documentation and Training**
1. **Create User Manual**
   - System overview
   - User guides
   - Troubleshooting
   - Best practices

2. **Create Administrator Guide**
   - Installation procedures
   - Configuration management
   - Maintenance tasks
   - Security guidelines

3. **Create Developer Guide**
   - API documentation
   - Integration examples
   - Custom development
   - Testing procedures

### **Deliverables**
- ✅ Complete system deployment
- ✅ Monitoring and alerting
- ✅ Backup and recovery
- ✅ Comprehensive documentation
- ✅ User training materials

---

## 🏆 **Project Completion Checklist**

### **Beginner Level**
- [ ] Basic data collection setup
- [ ] Simple dashboard creation
- [ ] MQTT data flow understanding
- [ ] Basic configuration management

### **Intermediate Level**
- [ ] Multi-device monitoring
- [ ] Alert system implementation
- [ ] Quality monitoring
- [ ] Production metrics

### **Advanced Level**
- [ ] Machine learning implementation
- [ ] Predictive maintenance
- [ ] Anomaly detection
- [ ] Advanced analytics

### **Expert Level**
- [ ] Complete system integration
- [ ] Custom API development
- [ ] Security implementation
- [ ] System deployment and maintenance

---

## 📚 **Additional Resources**

### **Documentation**
- Factory+ Framework: https://factoryplus.app.amrc.co.uk
- ACS GitHub: https://github.com/AMRC-FactoryPlus/amrc-connectivity-stack
- Your local guides in the project folder

### **Tools and Libraries**
- **Python**: paho-mqtt, flask, scikit-learn, pandas
- **JavaScript**: Chart.js, D3.js, React
- **Databases**: InfluxDB, PostgreSQL, Redis
- **Monitoring**: Grafana, Prometheus

### **Learning Path**
1. **Week 1-2**: Complete Project 1 (Basic Data Collection)
2. **Week 3-4**: Complete Project 2 (Production Line Monitoring)
3. **Week 5-6**: Complete Project 3 (Advanced Analytics)
4. **Week 7-8**: Complete Project 4 (System Integration)
5. **Week 9-10**: Complete Project 5 (Complete Deployment)

---

**Remember**: These projects are designed to build your expertise gradually. Take your time with each project, experiment with different approaches, and don't hesitate to explore beyond the basic requirements. The goal is to become proficient with Factory+ and industrial data management! 🏭✨
