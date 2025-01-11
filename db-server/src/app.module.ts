import { Module, ValidationPipe } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { MongooseModule } from '@nestjs/mongoose';
import { HistoryModule } from './history/history.module';
import { DeviceModule } from './device/device.module';
import { UserModule } from './user/user.module';
import { AuthModule } from './auth/auth.module';
import { APP_GUARD, APP_PIPE } from '@nestjs/core';
import { JwtAccessTokenAuthGuard } from './auth/jwt.guard';

@Module({
    imports: [
        MongooseModule.forRoot(
            'mongodb+srv://thesis:123qwe@thesis.jd2os.mongodb.net/master?retryWrites=true&w=majority&appName=Thesis',
        ),
        HistoryModule,
        DeviceModule,
        UserModule,
        AuthModule,
    ],
    controllers: [AppController],
    providers: [
        AppService,
        {
            provide: APP_GUARD,
            useClass: JwtAccessTokenAuthGuard,
        },
        {
            provide: APP_PIPE,
            useValue: new ValidationPipe({
                transform: true,
                transformOptions: { enableImplicitConversion: true },
            }),
        },
    ],
})
export class AppModule {}
