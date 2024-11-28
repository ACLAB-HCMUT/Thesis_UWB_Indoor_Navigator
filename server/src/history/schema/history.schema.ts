import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type HistoryDocument = HydratedDocument<History>;

@Schema({ timestamps: true })
export class History {
    @Prop({ required: true })
    x: number;
    @Prop({ required: true })
    y: number;
}

export const HistorySchema = SchemaFactory.createForClass(History);

