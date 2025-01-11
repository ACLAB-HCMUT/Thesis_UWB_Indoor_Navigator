import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

@Injectable()
export class AuthService {
    constructor(
		private jwtService: JwtService
	) {}
    issueAccessToken(user) {
		const payload = {
			email: user.email,
			_id: user._id,
			avatar: user.avatar,
			role: user.role,
			fullName: user.fullName,
			phone: user.phone,
		};
		return this.jwtService.sign(payload, {
			secret: 'key',
			expiresIn: 7200,
		});
	}
    login(user) {
		return {
			access_token: this.issueAccessToken(user),
			user,
		};
	}
}
