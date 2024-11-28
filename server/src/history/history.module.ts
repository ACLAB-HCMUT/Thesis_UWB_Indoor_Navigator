import { Module } from '@nestjs/common';
import { HistoryService } from './history.service';
import { MongooseModule } from '@nestjs/mongoose';
import { History, HistorySchema } from './schema/history.schema';

@Module({
    imports: [MongooseModule.forFeature([{ name: History.name, schema: HistorySchema }])],
    exports: [HistoryService],
    providers: [HistoryService],
})
export class HistoryModule {}
