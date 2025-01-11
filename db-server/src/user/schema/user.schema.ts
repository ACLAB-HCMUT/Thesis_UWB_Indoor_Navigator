import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { HydratedDocument } from 'mongoose';
import { Device } from 'src/device/schema/device.schema';

export type UserDocument = HydratedDocument<User>;

@Schema({ timestamps: true })
export class User {
    @Prop({ required: true, type: String })
    fullName: string;

    @Prop({ required: true, type: String })
    password: string;

    @Prop({ required: true, type: String })
    email: string;

    @Prop({ type: String })
    phone: string;

    @Prop({ type: String })
    avatar: string;

    @Prop({
        type: [{ type: mongoose.Schema.Types.ObjectId, ref: Device.name }],
    })
    devices: string[];
}

export const UserSchema = SchemaFactory.createForClass(User);
