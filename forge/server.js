const http = require('http');
const { execSync } = require('child_process');
const PORT = process.env.PORT || 8200;
const COMFYUI_URL = process.env.COMFYUI_URL || 'http://comfyui:8188';
const server = http.createServer((req, res) => {
  if (req.method === 'GET' && req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok', comfyui: COMFYUI_URL }));
    return;
  }
  if (req.method === 'GET' && req.url === '/') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ name: 'forge-pipeline', version: '2.0.0', endpoints: ['/health', '/render', '/status'], comfyui: COMFYUI_URL }));
    return;
  }
  res.writeHead(404);
  res.end('Not found');
});
server.listen(PORT, () => { console.log(`Forge pipeline listening on :${PORT}`); console.log(`ComfyUI endpoint: ${COMFYUI_URL}`); });
