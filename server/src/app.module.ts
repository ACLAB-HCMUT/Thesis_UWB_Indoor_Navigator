import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { MongooseModule } from '@nestjs/mongoose';
import { HistoryModule } from './history/history.module';

@Module({
    imports: [
        MongooseModule.forRoot(
            'mongodb+srv://thesis:123qwe@thesis.jd2os.mongodb.net/master?retryWrites=true&w=majority&appName=Thesis',
        ),
        HistoryModule,
    ],
    controllers: [AppController],
    providers: [AppService],
})
export class AppModule {}
