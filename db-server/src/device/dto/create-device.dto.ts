import { ApiProperty } from '@nestjs/swagger';

export class CreateDeviceDto {
    @ApiProperty()
    name: string;

    @ApiProperty({ required: false, default: 0 })
    device_type: number = 0;
}
