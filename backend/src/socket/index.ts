import { Server as HttpServer } from 'http';
import { Server, ServerOptions } from 'socket.io';
import { ChatSocketHandler } from './chat.handler';

export function initializeSocket(httpServer: HttpServer) {
  const io = new Server(httpServer, {
    cors: {
      origin: process.env.SOCKET_IO_CORS_ORIGIN || '*',
      methods: ['GET', 'POST'],
      credentials: true,
    },
  } as ServerOptions);

  const chatHandler = new ChatSocketHandler(io);

  io.on('connection', (socket) => {
    chatHandler.handleConnection(socket);
  });

  console.log('✅ Socket.IO initialized');

  return io;
}
