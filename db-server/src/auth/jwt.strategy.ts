import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
@Injectable()
export class JwtStrategyAccessToken extends PassportStrategy(
	Strategy,
	"jwt-token",
) {
	constructor() {
		super({
			jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
			secretOrKey: 'key',
		});
	}
	// When the token is valid, the validate method will be called (Success)
	async validate(payload) {
		return {
			_id: payload._id.toString(),
			fullName: payload.fullName,
			email: payload.email,
			avatar: payload.avatar,
			phone: payload.phone,
		};
	}
}