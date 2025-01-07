import { Injectable, NotFoundException } from '@nestjs/common';
import { CreateDeviceDto } from './dto/create-device.dto';
import { UpdateDeviceDto } from './dto/update-device.dto';
import { InjectModel } from '@nestjs/mongoose';
import { Device } from './schema/device.schema';
import { Model } from 'mongoose';
import { HistoryService } from 'src/history/history.service';

@Injectable()
export class DeviceService {
    constructor(
        @InjectModel(Device.name) private deviceModel: Model<Device>,
        private readonly historyService: HistoryService,
    ) {}
    create(createDeviceDto: CreateDeviceDto) {
        return new this.deviceModel(createDeviceDto).save();
    }

    findOne(id: string) {
        return this.deviceModel.findById(id).populate({
            path: 'histories',
            select: 'x y createdAt',
            options: { sort: { createdAt: -1 } }
        });
    }

    findAll() {
        return this.deviceModel.find().populate({
          path: 'histories',
          select: 'x y createdAt',
          options: { sort: { createdAt: -1 } },
        });
      }

    async update(id: string, updateDeviceDto: UpdateDeviceDto) {
        const history = await this.historyService.create(updateDeviceDto.history);
        await this.deviceModel.findByIdAndUpdate(
            id,
            { $push: { histories: history._id } },
            { new: true }
        );
        return this.deviceModel.findById(id).populate({
            path: 'histories',
            select: 'x y createdAt',
            options: { sort: { createdAt: -1 } }
        });
    }

    async remove(id: string) {
        const device = await this.deviceModel.findById(id).populate('histories');

    if (!device) {
        throw new NotFoundException(`Device with id ${id} not found`);
    }
    const historyIds = device.histories.map((history: any) => history._id);
    await this.historyService.bulkRemove(historyIds);

    return this.deviceModel.findByIdAndDelete(id);
    }
}
