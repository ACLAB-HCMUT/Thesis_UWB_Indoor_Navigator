import { ApiProperty } from "@nestjs/swagger";

export class CreateDeviceDto {
    @ApiProperty()
    name: string
}
