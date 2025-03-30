import { ApiProperty } from '@nestjs/swagger';
import { CreateHistoryDto } from 'src/history/dto/create-history.dto';
import {
    IsDefined,
    IsNotEmptyObject,
    ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

export class UpdateDeviceDto {
    @ApiProperty()
    @IsDefined()
    @IsNotEmptyObject()
    @ValidateNested()
    @Type(() => CreateHistoryDto)
    history: CreateHistoryDto;
}
