const express = require('express');
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
const cors = require('cors');
const helmet = require('helmet');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Fix the middleware order and configuration
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Enhanced CORS configuration
app.use(cors({
    origin: true,
    credentials: false,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
}));

// Fixed helmet configuration for dashboard
app.use(helmet({
    contentSecurityPolicy: {
        directives: {
            defaultSrc: ["'self'"],
            scriptSrc: ["'self'", "'unsafe-inline'", "https://unpkg.com"],
            styleSrc: ["'self'", "'unsafe-inline'", "https://unpkg.com"],
            imgSrc: ["'self'", "data:", "https:"],
            connectSrc: ["'self'"],
            fontSrc: ["'self'"],
            objectSrc: ["'none'"],
            mediaSrc: ["'self'"],
            frameSrc: ["'none'"],
        },
    },
    crossOriginOpenerPolicy: false,
    crossOriginEmbedderPolicy: false
}));

// Remove static file serving for dashboard to avoid conflicts
// Only serve static files that are NOT the dashboard
app.use(express.static(path.join(__dirname, '/'), {
    index: false, // Don't serve index files
    setHeaders: (res, filePath) => {
        // Block serving any HTML files to avoid conflicts
        if (filePath.endsWith('.html')) {
            res.status(404).end();
        }
    }
}));

// Add request logging middleware
app.use((req, res, next) => {
    console.log(`${req.method} ${req.url}`, req.body ? 'Body received' : 'No body');
    next();
});

// FIXED: Use the correct database configuration from your working version
const dbConfig = {
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  ssl: {
    rejectUnauthorized: false
  }
};

async function testConnection() {
  try {
    const connection = await mysql.createConnection(dbConfig);
    console.log('Database connected successfully');
    await connection.end();
  } catch (error) {
    console.error('Database connection failed:', error);
  }
}

// FIXED: Registration endpoint with all required fields
app.post('/api/register', async (req, res) => {
  const connection = await mysql.createConnection(dbConfig);

  try {
    const {
      username, email, password, firstName, lastName, dateOfBirth,
      gender, studentId, bloodType, emergencyContact, medicalConditions,
      allergies, currentMedications, immunizationHistory, medicalDevices
    } = req.body;

    if (!username || !email || !password || !firstName || !lastName ||
        !dateOfBirth || !gender || !studentId || !emergencyContact) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields'
      });
    }

    const [existingUsers] = await connection.execute(
      'SELECT id FROM users WHERE username = ? OR email = ? OR student_id = ?',
      [username, email, studentId]
    );

    if (existingUsers.length > 0) {
      return res.status(409).json({
        success: false,
        message: 'User with this username, email, or student ID already exists'
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const [day, month, year] = dateOfBirth.split('/');
    const formattedDate = `${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`;

    const [result] = await connection.execute(
      `INSERT INTO users (
        username, email, password, first_name, last_name, date_of_birth,
        gender, student_id, blood_type, emergency_contact, medical_conditions,
        allergies, current_medications, immunization_history, medical_devices
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        username, email, hashedPassword, firstName, lastName, formattedDate,
        gender, studentId, bloodType || null, emergencyContact, medicalConditions || null,
        allergies || null, currentMedications || null, immunizationHistory || null,
        medicalDevices || null
      ]
    );

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      userId: result.insertId
    });

  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  } finally {
    await connection.end();
  }
});

// FIXED: Login endpoint
app.post('/api/login', async (req, res) => {
  const connection = await mysql.createConnection(dbConfig);

  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({
        success: false,
        message: 'Username and password are required'
      });
    }

    const [users] = await connection.execute(
      'SELECT * FROM users WHERE username = ? OR email = ?',
      [username, username]
    );

    if (users.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Invalid username or password'
      });
    }

    const user = users[0];
    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Invalid username or password'
      });
    }

    const { password: _, ...userWithoutPassword } = user;

    res.status(200).json({
      success: true,
      message: 'Login successful',
      user: userWithoutPassword
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  } finally {
    await connection.end();
  }
});

// FIXED: Send Emergency Alert endpoint
app.post('/api/send-alert', async (req, res) => {
  const connection = await mysql.createConnection(dbConfig);

  try {
    const {
      userId,
      firstName,
      lastName,
      studentId,
      emergencyContact,
      latitude,
      longitude
    } = req.body;

    if (!userId || !firstName || !lastName || !studentId || !emergencyContact || !latitude || !longitude) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields'
      });
    }

    const [result] = await connection.execute(
      `INSERT INTO alerts (
        user_id, first_name, last_name, student_id, emergency_contact, latitude, longitude
      ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [userId, firstName, lastName, studentId, emergencyContact, latitude, longitude]
    );

    res.status(201).json({
      success: true,
      message: 'Emergency alert sent successfully',
      alertId: result.insertId
    });

  } catch (error) {
    console.error('Alert error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  } finally {
    await connection.end();
  }
});

// FIXED: Get all alerts endpoint
app.get('/api/alerts', async (req, res) => {
  const connection = await mysql.createConnection(dbConfig);

  try {
    const [alerts] = await connection.execute(
      'SELECT * FROM alerts ORDER BY alert_time DESC'
    );

    res.status(200).json({
      success: true,
      alerts: alerts
    });

  } catch (error) {
    console.error('Get alerts error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  } finally {
    await connection.end();
  }
});

// MANUAL REFRESH ONLY: Keep Leaflet map and interactive markers - NO auto-refresh to prevent crashes
app.get('/dashboard', async (req, res) => {
  const connection = await mysql.createConnection(dbConfig);
  
  try {
    const [alerts] = await connection.execute(
      'SELECT * FROM alerts ORDER BY alert_time DESC'
    );
    
    const dashboardHTML = `<!DOCTYPE html>
<html>
<head>
    <title>TapCare Emergency Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .header { 
            background: linear-gradient(135deg, #dc3545, #c82333); 
            color: white; 
            padding: 20px; 
            text-align: center; 
            margin-bottom: 20px; 
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(220, 53, 69, 0.3);
        }
        .controls { 
            background: white; 
            padding: 15px; 
            margin-bottom: 20px; 
            border-radius: 8px; 
            display: flex;
            gap: 15px;
            align-items: center;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .container { 
            display: grid; 
            grid-template-columns: 1fr 1fr; 
            gap: 20px; 
        }
        .section { 
            background: white; 
            padding: 25px; 
            border-radius: 12px; 
            box-shadow: 0 4px 16px rgba(0,0,0,0.1);
        }
        #map { 
            height: 500px; 
            border-radius: 8px;
            border: 2px solid #dc3545;
        }
        .alert { 
            background: white; 
            border: 3px solid #dc3545; 
            padding: 20px; 
            margin: 15px 0; 
            border-radius: 12px;
            cursor: pointer; 
            transition: all 0.3s;
        }
        .alert:hover { 
            background: #fff8f8;
            transform: translateY(-3px);
            box-shadow: 0 8px 24px rgba(220, 53, 69, 0.25);
        }
        .alert-title { 
            font-weight: bold; 
            color: #dc3545; 
            margin-bottom: 12px; 
            font-size: 18px;
        }
        .alert-details { 
            font-size: 14px; 
            color: #555; 
            line-height: 1.8;
        }
        .btn { 
            padding: 12px 24px; 
            background: #dc3545; 
            color: white; 
            border: none; 
            cursor: pointer; 
            border-radius: 8px; 
            font-weight: bold;
            transition: all 0.3s;
        }
        .btn:hover { 
            background: #c82333;
            transform: translateY(-2px);
        }
        .btn-green { background: #28a745; }
        .btn-green:hover { background: #218838; }
        .status {
            margin-left: auto;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 600;
            background: ${alerts.length > 0 ? '#f8d7da' : '#d4edda'};
            color: ${alerts.length > 0 ? '#721c24' : '#155724'};
        }
        .no-alerts { 
            text-align: center; 
            padding: 60px 20px; 
            color: #666; 
        }
        .emergency-pulse { 
            animation: emergencyPulse 2s infinite; 
        }
        @keyframes emergencyPulse { 
            0% { border-color: #dc3545; } 
            50% { border-color: #ff6b6b; } 
            100% { border-color: #dc3545; } 
        }
        @media (max-width: 768px) { 
            .container { grid-template-columns: 1fr; }
            .controls { flex-direction: column; text-align: center; }
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🚨 TapCare Emergency Dashboard</h1>
        <p>Database: CONNECTED | Active Alerts: ${alerts.length} | Last Updated: ${new Date().toLocaleString()}</p>
    </div>
    
    <div class="controls">
        <button class="btn" onclick="window.location.reload()">🔄 REFRESH NOW</button>
        <button class="btn btn-green" onclick="testEmergencySound()">🚨 TEST SOUND</button>
        <div class="status">
            ${alerts.length > 0 ? '🚨 ACTIVE EMERGENCIES' : '✅ ALL CLEAR'}
        </div>
    </div>
    
    <div class="container">
        <div class="section">
            <h3>🗺️ Emergency Locations (${alerts.length})</h3>
            <div id="map"></div>
        </div>
        
        <div class="section">
            <h3>📋 Database Alerts</h3>
            <div id="alerts">
                ${alerts.length === 0 ? `
                    <div class="no-alerts">
                        <div style="font-size: 64px; margin-bottom: 20px;">✅</div>
                        <div style="font-size: 18px; font-weight: bold;">NO ACTIVE EMERGENCIES</div>
                        <div style="font-size: 14px; margin-top: 10px; color: #28a745;">System operational - Click refresh to update</div>
                    </div>
                ` : alerts.map((alert, index) => `
                    <div class="alert ${index < 2 ? 'emergency-pulse' : ''}" data-lat="${alert.latitude}" data-lng="${alert.longitude}">
                        <div class="alert-title">
                            🚨 EMERGENCY ALERT #${alert.id}
                        </div>
                        <div class="alert-details">
                            <strong>Student:</strong> ${alert.first_name} ${alert.last_name}<br>
                            <strong>ID:</strong> ${alert.student_id}<br>
                            <strong>Contact:</strong> <a href="tel:${alert.emergency_contact}" style="color: #dc3545; font-weight: bold;">${alert.emergency_contact}</a><br>
                            <strong>Time:</strong> ${new Date(alert.alert_time).toLocaleString()}<br>
                            <strong>Location:</strong> ${parseFloat(alert.latitude).toFixed(6)}, ${parseFloat(alert.longitude).toFixed(6)}<br>
                            <strong>Status:</strong> <span style="background: #dc3545; color: white; padding: 2px 8px; border-radius: 10px; font-size: 12px;">${alert.status || 'EMERGENCY'}</span>
                        </div>
                    </div>
                `).join('')}
            </div>
        </div>
    </div>

    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script>
        var emergencyMap = null;
        var audioContext = null;
        
        function initDashboard() {
            console.log('🚨 Emergency dashboard loading...');
            
            // Initialize audio for emergency sounds
            try {
                audioContext = new (window.AudioContext || window.webkitAudioContext)();
            } catch(e) {
                console.log('Audio not supported');
            }
            
            initMap();
            initAlertClicks();
            
            console.log('✅ Emergency dashboard ready - NO auto-refresh');
        }
        
        function initMap() {
            try {
                var alerts = ${JSON.stringify(alerts)};
                var defaultLat = alerts.length > 0 ? parseFloat(alerts[0].latitude) : 14.5995;
                var defaultLng = alerts.length > 0 ? parseFloat(alerts[0].longitude) : 120.9842;
                
                emergencyMap = L.map('map').setView([defaultLat, defaultLng], 12);
                
                L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                    attribution: '© OpenStreetMap | TapCare Emergency'
                }).addTo(emergencyMap);
                
                // Add emergency markers with custom styling
                alerts.forEach(function(alert, index) {
                    var lat = parseFloat(alert.latitude);
                    var lng = parseFloat(alert.longitude);
                    
                    if (!isNaN(lat) && !isNaN(lng)) {
                        // Create emergency icon with pulsing effect
                        var emergencyIcon = L.divIcon({
                            className: 'emergency-marker',
                            html: '<div style="width: 30px; height: 30px; background: radial-gradient(circle, #dc3545, #a71e2a); border: 3px solid white; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-weight: bold; font-size: 14px; box-shadow: 0 0 15px rgba(220,53,69,0.7); animation: emergencyBlink 1s infinite;">🚨</div><style>@keyframes emergencyBlink { 0%, 100% { opacity: 1; transform: scale(1); } 50% { opacity: 0.7; transform: scale(1.1); } }</style>',
                            iconSize: [30, 30],
                            iconAnchor: [15, 15]
                        });
                        
                        var marker = L.marker([lat, lng], { icon: emergencyIcon }).addTo(emergencyMap);
                        
                        // Enhanced popup with emergency styling
                        var popupContent = 
                            '<div style="min-width: 250px; font-family: Arial, sans-serif;">' +
                            '<div style="background: linear-gradient(135deg, #dc3545, #c82333); color: white; padding: 12px; margin: -9px -12px 12px; font-weight: bold; text-align: center; border-radius: 8px 8px 0 0;">' +
                            '🚨 EMERGENCY ALERT #' + alert.id +
                            '</div>' +
                            '<div style="line-height: 1.8; padding: 8px 0;">' +
                            '<strong>🎓 Student:</strong> ' + alert.first_name + ' ' + alert.last_name + '<br>' +
                            '<strong>🆔 ID:</strong> ' + alert.student_id + '<br>' +
                            '<strong>📞 Contact:</strong> <a href="tel:' + alert.emergency_contact + '" style="color: #dc3545; font-weight: bold;">' + alert.emergency_contact + '</a><br>' +
                            '<strong>⏰ Time:</strong> ' + new Date(alert.alert_time).toLocaleString() + '<br>' +
                            '<strong>🎯 Status:</strong> <span style="background: #dc3545; color: white; padding: 3px 8px; border-radius: 12px; font-size: 11px;">EMERGENCY</span>' +
                            '</div>' +
                            '</div>';
                        
                        marker.bindPopup(popupContent, { 
                            maxWidth: 300,
                            closeButton: true 
                        });
                        
                        // Auto-open popup for most recent alerts
                        if (index < 2) {
                            marker.openPopup();
                        }
                    }
                });
                
                // Fit map to show all emergency locations
                if (alerts.length > 0) {
                    var coords = alerts.map(function(alert) {
                        return [parseFloat(alert.latitude), parseFloat(alert.longitude)];
                    });
                    var group = new L.featureGroup(coords.map(function(coord) {
                        return L.marker(coord);
                    }));
                    emergencyMap.fitBounds(group.getBounds().pad(0.2));
                }
                
                console.log('🗺️ Emergency map loaded with ' + alerts.length + ' locations');
                
            } catch (error) {
                console.error('Map initialization error:', error);
                document.getElementById('map').innerHTML = '<div style="display: flex; align-items: center; justify-content: center; height: 100%; background: #f8f9fa; color: #666; font-size: 16px;">⚠️ Map temporarily unavailable</div>';
            }
        }
        
        function initAlertClicks() {
            // Make alert cards interactive - click to focus on map
            document.querySelectorAll('.alert').forEach(function(alertEl) {
                alertEl.addEventListener('click', function() {
                    var lat = parseFloat(alertEl.getAttribute('data-lat'));
                    var lng = parseFloat(alertEl.getAttribute('data-lng'));
                    
                    if (emergencyMap && !isNaN(lat) && !isNaN(lng)) {
                        emergencyMap.setView([lat, lng], 16);
                        console.log('📍 Focused on emergency at: ' + lat + ', ' + lng);
                    }
                });
            });
        }
        
        function testEmergencySound() {
            if (!audioContext) {
                alert('🔇 Audio not available in this browser');
                return;
            }
            
            try {
                // Resume audio context if suspended
                if (audioContext.state === 'suspended') {
                    audioContext.resume();
                }
                
                // Create emergency siren sound
                var osc1 = audioContext.createOscillator();
                var osc2 = audioContext.createOscillator();
                var gain = audioContext.createGain();
                
                osc1.connect(gain);
                osc2.connect(gain);
                gain.connect(audioContext.destination);
                
                // Emergency frequencies
                osc1.frequency.setValueAtTime(800, audioContext.currentTime);
                osc2.frequency.setValueAtTime(1000, audioContext.currentTime);
                
                gain.gain.setValueAtTime(0, audioContext.currentTime);
                gain.gain.linearRampToValueAtTime(0.3, audioContext.currentTime + 0.1);
                gain.gain.linearRampToValueAtTime(0, audioContext.currentTime + 2);
                
                // Frequency modulation for siren effect
                osc1.frequency.exponentialRampToValueAtTime(1000, audioContext.currentTime + 1);
                osc1.frequency.exponentialRampToValueAtTime(800, audioContext.currentTime + 2);
                osc2.frequency.exponentialRampToValueAtTime(1200, audioContext.currentTime + 1);
                osc2.frequency.exponentialRampToValueAtTime(1000, audioContext.currentTime + 2);
                
                osc1.start();
                osc2.start();
                osc1.stop(audioContext.currentTime + 2);
                osc2.stop(audioContext.currentTime + 2);
                
                console.log('🚨 Emergency siren played');
                
            } catch (error) {
                console.error('Sound error:', error);
                alert('🔇 Could not play emergency sound');
            }
        }
        
        // Initialize when page loads
        document.addEventListener('DOMContentLoaded', initDashboard);
        
        // NO AUTO-REFRESH - Only manual refresh to prevent crashes
        console.log('🛡️ Emergency dashboard loaded - Manual refresh only');
        
    </script>
</body>
</html>`;
    
    res.send(dashboardHTML);
    
  } catch (error) {
    console.error('Dashboard error:', error);
    res.status(500).send('<h1>Dashboard Error</h1><p>' + error.message + '</p>');
  } finally {
    await connection.end();
  }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'Server is running', timestamp: new Date().toISOString() });
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  testConnection();
});