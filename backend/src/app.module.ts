import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { APP_FILTER, APP_INTERCEPTOR } from '@nestjs/core';
import { SupabaseModule } from './config/supabase.module';
import { AuthModule } from './auth/auth.module';
import { SpeciesModule } from './species/species.module';
import { CountriesModule } from './countries/countries.module';
import { AnimalsModule } from './animals/animals.module';
import { UploadModule } from './upload/upload.module';
import { MeasurementsModule } from './measurements/measurements.module';
import { CareLogsModule } from './care-logs/care-logs.module';
import { AdminModule } from './admin/admin.module';
import { GlobalExceptionFilter } from './common/filters/http-exception.filter';
import { ResponseInterceptor } from './common/interceptors/response.interceptor';

const imports: any[] = [
  // Environment
  ConfigModule.forRoot({
    isGlobal: true,
    envFilePath: `.env.${process.env.NODE_ENV || 'development'}`,
  }),

  // Supabase
  SupabaseModule,

  // Auth
  AuthModule,
];

// Database (Supabase Pooler 연결 필요 - 연결 정보는 Supabase Dashboard > Connect 참조)
if (process.env.DB_HOST) {
  imports.push(
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get<string>('DB_HOST'),
        port: configService.get<number>('DB_PORT'),
        username: configService.get<string>('DB_USERNAME'),
        password: configService.get<string>('DB_PASSWORD'),
        database: configService.get<string>('DB_NAME'),
        autoLoadEntities: true,
        synchronize: configService.get<string>('NODE_ENV') !== 'production',
        logging: configService.get<string>('NODE_ENV') === 'development',
        ssl:
          configService.get<string>('NODE_ENV') === 'production'
            ? { rejectUnauthorized: true }
            : { rejectUnauthorized: false },
        retryAttempts: 3,
        retryDelay: 3000,
      }),
    }),
    SpeciesModule,
    CountriesModule,
    AnimalsModule,
    MeasurementsModule,
    CareLogsModule,
    UploadModule,
    AdminModule,
  );
}

@Module({
  imports,
  providers: [
    {
      provide: APP_FILTER,
      useClass: GlobalExceptionFilter,
    },
    {
      provide: APP_INTERCEPTOR,
      useClass: ResponseInterceptor,
    },
  ],
})
export class AppModule {}
