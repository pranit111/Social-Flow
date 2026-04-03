import {
  Body,
  Controller,
  Get,
  HttpException,
  HttpStatus,
  Post,
  Query,
} from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { IncomingCommentsProxyService } from '@gitroom/nestjs-libraries/database/prisma/incoming-comments-proxy/incoming-comments-proxy.service';

@ApiTags('Instagram Webhooks')
@Controller('/instagram/webhooks')
export class NoAuthInstagramWebhooksController {
  constructor(
    private _incomingCommentsProxyService: IncomingCommentsProxyService
  ) {}

  @Get('/')
  verify(
    @Query('hub.mode') mode?: string,
    @Query('hub.verify_token') token?: string,
    @Query('hub.challenge') challenge?: string
  ) {
    const value = this._incomingCommentsProxyService.verifyWebhook(
      mode,
      token,
      challenge
    );

    if (value === null) {
      throw new HttpException('Forbidden', HttpStatus.FORBIDDEN);
    }

    return value;
  }

  @Post('/')
  async receive(@Body() body: any) {
    const result = await this._incomingCommentsProxyService.processWebhook(body);
    return {
      success: true,
      ...result,
    };
  }
}
