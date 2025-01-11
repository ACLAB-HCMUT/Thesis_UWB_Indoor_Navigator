import { Controller, Get, Post, UseGuards } from '@nestjs/common';
import { AuthService } from './auth.service';
import { Public } from './public.decorator';
import { AuthGuard } from '@nestjs/passport';
import { User } from './user.decorator';
import { ApiBearerAuth, ApiBody, ApiTags } from '@nestjs/swagger';

@ApiTags('Auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @UseGuards(AuthGuard("local"))
	@Public()
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        email: { type: 'string' },
        password: { type: 'string' },
      },
      required: ['email', 'password'],
    },
  })
	@Post("login")
	async login(
		@User() user,
	) {
		return this.authService.login(user);
	}

  @ApiBearerAuth()
	@Get("account")
	async account(@User() user) {
		return { user };
	}
}
