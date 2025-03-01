import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { HydratedDocument } from 'mongoose';
import { History } from 'src/history/schema/history.schema';

export type DeviceDocument = HydratedDocument<Device>;

@Schema({ timestamps: true })
export class Device {
    @Prop({ required: true })
    name: string;

    @Prop({
        type: [{ type: mongoose.Schema.Types.ObjectId, ref: History.name }],
    })
    histories: History[];

    @Prop({ default: 0 })
    device_type: number;
}

export const DeviceSchema = SchemaFactory.createForClass(Device);
