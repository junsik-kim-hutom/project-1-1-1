import express from 'express';
import cors from 'cors';
import path from 'path';
import { createServer } from 'http';
import { connectDatabase } from './config/database';
import { initializeSocket } from './socket';
import { envLoader, getDeployCountry, getEnabledPayments } from './config/env-loader';

import authRoutes from './modules/auth/auth.routes';
import profileRoutes from './modules/profile/profile.routes';
import locationRoutes from './modules/location/location.routes';
import balanceGameRoutes from './modules/balance-game/balance-game.routes';
import profileFieldRoutes from './modules/profile-field/profile-field.routes';
import eqTestRoutes from './modules/eq-test/eq-test.routes';
import chatRoutes from './modules/chat/chat.routes';

// 국가별 환경 설정 자동 로드
// .env.{DEPLOY_COUNTRY} 파일을 우선적으로 로드합니다.

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors({
  origin: process.env.CORS_ORIGIN?.split(',') || '*',
  credentials: true,
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 정적 파일 제공 (업로드된 이미지)
const uploadsPath = path.join(process.cwd(), process.env.LOCAL_UPLOAD_PATH || './uploads');
app.use('/uploads', express.static(uploadsPath));

app.get('/', (req, res) => {
  res.json({
    message: 'Marriage Matching API',
    version: '1.0.0',
    status: 'running',
    country: getDeployCountry(),
    environment: process.env.NODE_ENV,
    paymentMode: process.env.PAYMENT_MODE,
    enabledPayments: getEnabledPayments(),
  });
});

app.use('/api/auth', authRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/location', locationRoutes);
app.use('/api/balance-games', balanceGameRoutes);
app.use('/api/profile-fields', profileFieldRoutes);
app.use('/api/eq-test', eqTestRoutes);
app.use('/api/chat', chatRoutes);

app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Error:', err);
  res.status(500).json({
    error: 'Internal server error',
    message: err.message,
  });
});

const httpServer = createServer(app);

initializeSocket(httpServer);

async function startServer() {
  try {
    await connectDatabase();

    httpServer.listen(PORT, () => {
      console.log(`🚀 Server is running on port ${PORT}`);
      console.log(`📍 Environment: ${process.env.NODE_ENV || 'development'}`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

startServer();

process.on('SIGINT', async () => {
  console.log('\n👋 Shutting down gracefully...');
  process.exit(0);
});

export default app;
