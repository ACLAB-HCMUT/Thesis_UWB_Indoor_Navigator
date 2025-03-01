import { PartialType } from '@nestjs/mapped-types';
import { CreateDeviceDto } from './create-device.dto';
import { ApiProperty } from '@nestjs/swagger';
import { CreateHistoryDto } from 'src/history/dto/create-history.dto';

export class UpdateDeviceDto extends PartialType(CreateDeviceDto) {
    @ApiProperty()
    history: CreateHistoryDto;

    @ApiProperty({ required: false, default: 0 })
    device_type: number = 0;
}
