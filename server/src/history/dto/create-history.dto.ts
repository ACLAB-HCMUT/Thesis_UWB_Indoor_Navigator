import { ApiProperty } from "@nestjs/swagger"

export class CreateHistoryDto {
    @ApiProperty()
    x: number
    @ApiProperty()
    y: number
}
