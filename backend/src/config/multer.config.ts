import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { Request } from 'express';

// 환경 변수에서 설정 가져오기
const STORAGE_TYPE = process.env.STORAGE_TYPE || 'local';
const LOCAL_UPLOAD_PATH = process.env.LOCAL_UPLOAD_PATH || './uploads';
const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB

// 업로드 디렉토리 생성
const uploadsDir = path.join(process.cwd(), LOCAL_UPLOAD_PATH);
const profileImagesDir = path.join(uploadsDir, 'profile-images');

// 디렉토리가 없으면 생성
[uploadsDir, profileImagesDir].forEach(dir => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
});

// 파일 저장 설정
const storage = multer.diskStorage({
  destination: (req: Request, file: Express.Multer.File, cb) => {
    // 파일 타입에 따라 다른 디렉토리에 저장
    let uploadPath = profileImagesDir;

    if (req.path.includes('profile')) {
      uploadPath = profileImagesDir;
    }

    cb(null, uploadPath);
  },
  filename: (req: Request, file: Express.Multer.File, cb) => {
    // 고유한 파일명 생성: timestamp-randomstring-originalname
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    const nameWithoutExt = path.basename(file.originalname, ext);
    const sanitizedName = nameWithoutExt.replace(/[^a-zA-Z0-9]/g, '_');

    cb(null, `${sanitizedName}-${uniqueSuffix}${ext}`);
  }
});

// 파일 필터 (이미지만 허용)
const fileFilter = (req: Request, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
  const allowedMimes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];

  if (allowedMimes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Only image files (JPEG, PNG, WebP) are allowed'));
  }
};

// Multer 설정
export const uploadProfileImage = multer({
  storage: storage,
  limits: {
    fileSize: MAX_FILE_SIZE,
    files: 6 // 최대 6개 파일
  },
  fileFilter: fileFilter
});

// 단일 파일 업로드
export const uploadSingle = uploadProfileImage.single('image');

// 여러 파일 업로드 (최대 6개)
export const uploadMultiple = uploadProfileImage.array('images', 6);

// 파일 URL 생성 헬퍼 함수
export const getFileUrl = (filename: string, folder: string = 'profile-images'): string => {
  const baseUrl = process.env.LOCAL_BASE_URL || 'http://localhost:3000/uploads';
  return `${baseUrl}/${folder}/${filename}`;
};

// 파일 삭제 헬퍼 함수
export const deleteFile = (filepath: string): void => {
  try {
    if (fs.existsSync(filepath)) {
      fs.unlinkSync(filepath);
    }
  } catch (error) {
    console.error('Failed to delete file:', error);
  }
};
