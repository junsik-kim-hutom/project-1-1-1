import { config } from 'dotenv';
import { resolve } from 'path';
import { existsSync } from 'fs';

/**
 * 국가별 환경 설정 자동 로더
 * DEPLOY_COUNTRY 환경 변수에 따라 적절한 .env 파일을 로드합니다.
 *
 * 사용 가능한 국가:
 * - development (개발 환경 - 기본값)
 * - japan (일본)
 * - korea (한국)
 * - usa (미국)
 *
 * 우선순위:
 * 1. .env.{DEPLOY_COUNTRY} (국가별 설정)
 * 2. .env (기본 설정)
 */

export class EnvironmentLoader {
  private static instance: EnvironmentLoader;
  private loadedCountry: string = 'development';

  private constructor() {
    this.loadEnvironment();
  }

  public static getInstance(): EnvironmentLoader {
    if (!EnvironmentLoader.instance) {
      EnvironmentLoader.instance = new EnvironmentLoader();
    }
    return EnvironmentLoader.instance;
  }

  /**
   * 환경 변수를 로드합니다.
   */
  private loadEnvironment(): void {
    // 1. 먼저 기본 .env 파일을 로드 (fallback)
    const defaultEnvPath = resolve(process.cwd(), '.env');
    if (existsSync(defaultEnvPath)) {
      config({ path: defaultEnvPath });
      console.log('✅ Loaded default .env file');
    }

    // 2. DEPLOY_COUNTRY 환경 변수 확인
    const deployCountry = process.env.DEPLOY_COUNTRY || 'development';
    this.loadedCountry = deployCountry;

    // 3. 국가별 환경 파일 로드
    const countryEnvPath = resolve(process.cwd(), `.env.${deployCountry}`);

    if (existsSync(countryEnvPath)) {
      // override: true로 설정하여 기본 .env 값을 덮어씁니다
      config({ path: countryEnvPath, override: true });
      console.log(`✅ Loaded country-specific environment: .env.${deployCountry}`);
    } else {
      console.warn(`⚠️  Country-specific env file not found: .env.${deployCountry}`);
      console.warn(`⚠️  Using default .env file`);
    }

    // 4. 환경 정보 출력
    this.printEnvironmentInfo();
  }

  /**
   * 현재 로드된 환경 정보를 출력합니다.
   */
  private printEnvironmentInfo(): void {
    console.log('\n=== Environment Configuration ===');
    console.log(`🌍 Deploy Country: ${this.loadedCountry.toUpperCase()}`);
    console.log(`🔧 Node Environment: ${process.env.NODE_ENV}`);
    console.log(`💳 Payment Mode: ${process.env.PAYMENT_MODE}`);
    console.log(`💾 Storage Type: ${process.env.STORAGE_TYPE}`);
    console.log(`🌐 Default Language: ${process.env.DEFAULT_LANGUAGE || 'Not set'}`);
    console.log(`💰 Default Currency: ${process.env.DEFAULT_CURRENCY || 'Not set'}`);
    console.log(`⏰ Default Timezone: ${process.env.DEFAULT_TIMEZONE || 'Not set'}`);
    console.log('=================================\n');
  }

  /**
   * 현재 로드된 국가를 반환합니다.
   */
  public getLoadedCountry(): string {
    return this.loadedCountry;
  }

  /**
   * 특정 결제 수단이 활성화되어 있는지 확인합니다.
   */
  public isPaymentEnabled(paymentMethod: string): boolean {
    const envKey = `${paymentMethod.toUpperCase()}_ENABLED`;
    return process.env[envKey] === 'true';
  }

  /**
   * 국가별 활성화된 결제 수단 목록을 반환합니다.
   */
  public getEnabledPaymentMethods(): string[] {
    const paymentMethods = [
      'PAYPAY',
      'STRIPE',
      'RAKUTEN',
      'LINE_PAY',
      'TOSS',
      'KAKAOPAY',
      'NAVERPAY',
      'PAYPAL',
      'APPLE_PAY',
      'GOOGLE_PAY',
    ];

    return paymentMethods.filter(method => this.isPaymentEnabled(method));
  }

  /**
   * 현재 환경이 개발 환경인지 확인합니다.
   */
  public isDevelopment(): boolean {
    return process.env.NODE_ENV === 'development';
  }

  /**
   * 현재 환경이 프로덕션 환경인지 확인합니다.
   */
  public isProduction(): boolean {
    return process.env.NODE_ENV === 'production';
  }

  /**
   * Mock 모드가 활성화되어 있는지 확인합니다.
   */
  public isMockMode(): boolean {
    return process.env.PAYMENT_MODE === 'mock';
  }
}

// 싱글톤 인스턴스 초기화
export const envLoader = EnvironmentLoader.getInstance();

// 편의 함수들
export const getDeployCountry = () => envLoader.getLoadedCountry();
export const getEnabledPayments = () => envLoader.getEnabledPaymentMethods();
export const isDevelopment = () => envLoader.isDevelopment();
export const isProduction = () => envLoader.isProduction();
export const isMockMode = () => envLoader.isMockMode();
export const isPaymentEnabled = (method: string) => envLoader.isPaymentEnabled(method);
