import { Module } from '@nestjs/common';
import { DeviceService } from './device.service';
import { DeviceController } from './device.controller';
import { Device, DeviceSchema } from './schema/device.schema';
import { MongooseModule } from '@nestjs/mongoose';
import { HistoryModule } from 'src/history/history.module';

@Module({
    imports: [
        MongooseModule.forFeature([
            { name: Device.name, schema: DeviceSchema },
        ]),
		HistoryModule
    ],
    controllers: [DeviceController],
    providers: [DeviceService],
})
export class DeviceModule {}
