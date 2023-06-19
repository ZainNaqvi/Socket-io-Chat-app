const express = require('express');
const app = express();
const http = require('http');
const server = http.createServer(app);
const { Server } = require("socket.io");
const io = new Server(server);
const messages = [];

io.on('connection', (socket) => {
  console.log("User Name:", socket.handshake.query.username);
  const username = socket.handshake.query.username;
  console.log(username);

  socket.on('message', (data) => {
    const message = {
      type: 'message',
      message: data.message,
      senderUsername: username,
      sentAt: Date.now()
    };
    messages.push(message);
    io.emit('message', message);
  });

  socket.on('reply', (data) => {
    const message = {
      type: 'reply',
      message: data.message,
      senderUsername: username,
      sentAt: Date.now()
    };
    messages.push(message);
    io.emit('message', message);
  });
});

server.listen(3000, "0.0.0.0", () => {
  console.log('listening on *:3000');
});
