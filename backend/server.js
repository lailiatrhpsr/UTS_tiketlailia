// Import library
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Buat server HTTP + Socket.IO
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST", "PUT"]
  }
});

// Struktur database RAM
let tickets = [
  {
    id: "TKT-2026-001",
    title: "Masalah Koneksi WiFi",
    description: "WiFi di lantai 2 sering terputus tiba-tiba.",
    status: "open",
    createdAt: new Date().toISOString(),
    attachmentPath: null,
    assignedTo: null,
    comments: []
  }
];

let activeSession = {
  isLoggedIn: false,
  username: null,
  role: "guest",
  loginAt: null
};

// ====================== AUTH ======================
app.post('/api/v1/auth/login', (req, res) => {
  const { username, password } = req.body;

  let role = "user";
  if (username.toLowerCase().includes("admin")) role = "admin";
  else if (username.toLowerCase().includes("helpdesk")) role = "helpdesk";

  activeSession = {
      isLoggedIn: true,
      username: username,
      role: role,
      loginAt: new Date().toISOString()
    };

  return res.status(200).json({
    status: 'success',
    message: 'Login berhasil',
    role
  });
});

app.get('/api/v1/auth/session', (req, res) => {
  res.status(200).json({
    status: 'success',
    data: activeSession
  });
});

// ====================== TICKETS ======================
// GET semua tiket
app.get('/api/v1/tickets', (req, res) => {
  res.status(200).json({ status: 'success', data: tickets });
});

// POST buat tiket baru
app.post('/api/v1/tickets', (req, res) => {
  const { title, description, attachmentPath } = req.body;
  const newTicket = {
    id: `TKT-2026-00${tickets.length + 1}`,
    title,
    description,
    status: "open",
    createdAt: new Date().toISOString(),
    attachmentPath: attachmentPath || null,
    assignedTo: null,
    comments: []
  };
  tickets.push(newTicket);

  // Broadcast realtime ke semua client
  io.emit('ticketCreated', newTicket);

  res.status(201).json({ status: 'success', data: newTicket });
});

// PUT update status tiket
app.put('/api/v1/tickets/:id/status', (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  const idx = tickets.findIndex(t => t.id === id);

  if (idx !== -1) {
    tickets[idx].status = status;

    // Broadcast realtime
    io.emit('statusUpdated', tickets[idx]);

    return res.status(200).json({ status: 'success', data: tickets[idx] });
  }
  return res.status(404).json({ message: 'Tiket tidak ada' });
});

// POST assign tiket ke helpdesk
app.post('/api/v1/tickets/:id/assign', (req, res) => {
  const { id } = req.params;
  const { helpdeskName } = req.body;
  const idx = tickets.findIndex(t => t.id === id);

  if (idx !== -1) {
    tickets[idx].assignedTo = helpdeskName;

    // Broadcast realtime
    io.emit('ticketAssigned', tickets[idx]);

    return res.status(200).json({ status: 'success', data: tickets[idx] });
  }
  return res.status(404).json({ message: 'Tiket tidak ada' });
});

// POST tambah komentar
app.post('/api/v1/tickets/:id/comments', (req, res) => {
  const { id } = req.params;
  const { sender, message } = req.body;
  const idx = tickets.findIndex(t => t.id === id);

  if (idx !== -1) {
    const newComment = {
      sender,
      message,
      createdAt: new Date().toISOString()
    };
    tickets[idx].comments.push(newComment);

    // Broadcast realtime
    io.emit('commentAdded', { ticketId: id, comment: newComment });

    return res.status(201).json({ status: 'success', data: tickets[idx] });
  }
  return res.status(404).json({ message: 'Tiket tidak ada' });
});

// ====================== SOCKET.IO ======================
io.on('connection', (socket) => {
  console.log('Client terhubung:', socket.id);

  socket.on('disconnect', () => {
    console.log('Client terputus:', socket.id);
  });
});

// Jalankan server
server.listen(PORT, () => console.log(`Server API berjalan di http://localhost:${PORT}`));
