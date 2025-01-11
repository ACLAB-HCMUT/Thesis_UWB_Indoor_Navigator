import {
    ConflictException,
    Injectable,
    NotFoundException,
} from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import * as bcrypt from 'bcrypt';
import { InjectModel } from '@nestjs/mongoose';
import { User } from './schema/user.schema';
import { Model } from 'mongoose';
import { DeviceService } from 'src/device/device.service';

@Injectable()
export class UserService {
    constructor(
        @InjectModel(User.name) private userModel: Model<User>,
        private readonly deviceService: DeviceService,
    ) {}
    async hashPassword(password: string) {
        const salt = await bcrypt.genSalt();
        const hash = await bcrypt.hash(password, salt);
        return hash;
    }
    findByEmail(email: string) {
      return this.userModel.findOne({ email }).exec();
    }
    async validateUser(email: string, pass: string): Promise<any> {
      const user = await this.findByEmail(email);
      if (user) {
        const isMatch = await bcrypt.compare(pass, user.password);
        if (isMatch) {
          delete user.password;
          return user;
        }
      }
      return null;
    }
    countByEmail(email: string) {
        return this.userModel.countDocuments({ email }).exec();
    }
    async create(createUserDto: CreateUserDto) {
        const count = await this.countByEmail(createUserDto.email);
        if (count >= 1) {
            throw new ConflictException('Email already exists');
        }
        const hash = await this.hashPassword(createUserDto.password);
        const createdUser = new this.userModel({
            ...createUserDto,
            password: hash,
        });
        return createdUser.save();
    }

    async update(id: string, deviceId: string) {
        const user = await this.userModel.findById(id);
        if (!user) {
            throw new NotFoundException(`User with ID ${id} not found`);
        }
        const device = this.deviceService.findOne(deviceId);
        if (!device) {
          throw new NotFoundException(`Device with ID ${deviceId} not found`);
        }
        if (!user.devices.includes(deviceId)) {
            user.devices.push(deviceId);
        }

        return user.save();
    }

    remove(id: string) {
        return this.userModel.deleteOne({ _id: id });
    }
}
