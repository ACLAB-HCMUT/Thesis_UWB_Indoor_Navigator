import { Injectable } from '@nestjs/common';
import { CreateHistoryDto } from './dto/create-history.dto';
import { UpdateHistoryDto } from './dto/update-history.dto';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { History } from './schema/history.schema';

@Injectable()
export class HistoryService {
    constructor(@InjectModel(History.name) private historyModel: Model<History>) {}
    create(createHistoryDto: CreateHistoryDto) {
        return new this.historyModel(createHistoryDto).save();
    }

    findAll() {
        return this.historyModel.find().exec();
    }

    findOne(id: string) {
        return this.historyModel.findById(id);
    }

    update(id: string, updateHistoryDto: UpdateHistoryDto) {
        return this.historyModel.updateOne({_id: id}, updateHistoryDto);
    }

    remove(id: string) {
        return this.historyModel.deleteOne({_id: id});
    }
}
