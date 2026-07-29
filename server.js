// Import required enterprise modules
const express = require('express');
const client = require('prom-client');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 3000;

// Initialize Prometheus metrics collection
const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics({ register: client.register });

// Root Endpoint - Displays system info and friendly message
app.get('/', (req, res) => {
    res.json({
        status: "SUCCESS",
        message: "Welcome to the Ultimate DevOps End-to-End Enterprise Pipeline!",
        hostname: os.hostname(),
        platform: os.platform(),
        memoryTotal: `${(os.totalmem() / (1024 * 1024)).toFixed(2)} MB`,
        memoryFree: `${(os.freemem() / (1024 * 1024)).toFixed(2)} MB`,
        timestamp: new Date().toISOString()
    });
});

// Health Check Endpoint - Required for Kubernetes Liveness & Readiness Probes
app.get('/health', (req, res) => {
    res.status(200).json({ status: "UP", environment: "Production-Ready" });
});

// Metrics Endpoint - Scraped by Prometheus
app.get('/metrics', async (req, res) => {
    res.set('Content-Type', client.register.contentType);
    res.end(await client.register.metrics());
});

// Start the server
app.listen(PORT, () => {
    console.log(`[INFO] Server is running smoothly on port ${PORT}`);
});
