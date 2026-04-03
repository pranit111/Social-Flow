import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { GetOrgFromRequest } from '@gitroom/nestjs-libraries/user/org.from.request';
import { Organization } from '@prisma/client';
import { IncomingCommentsService } from '@gitroom/nestjs-libraries/database/prisma/incoming-comments/incoming-comments.service';
import { ReplyIncomingCommentDto } from '@gitroom/nestjs-libraries/dtos/incoming-comments/reply-incoming-comment.dto';

@ApiTags('Incoming Comments')
@Controller('/incoming-comments')
export class IncomingCommentsController {
  constructor(private _incomingCommentsService: IncomingCommentsService) {}

  @Get('/')
  list(
    @GetOrgFromRequest() org: Organization,
    @Query('platform') platform?: string,
    @Query('unread') unread?: string
  ) {
    return this._incomingCommentsService.list(
      org.id,
      platform,
      unread === 'true'
    );
  }

  @Post('/sync')
  sync(@GetOrgFromRequest() org: Organization) {
    return this._incomingCommentsService.sync(org.id);
  }

  @Post('/:id/reply')
  reply(
    @GetOrgFromRequest() org: Organization,
    @Param('id') id: string,
    @Body() body: ReplyIncomingCommentDto
  ) {
    return this._incomingCommentsService.reply(org.id, id, body.message);
  }

  @Patch('/:id/read')
  markRead(
    @GetOrgFromRequest() org: Organization,
    @Param('id') id: string
  ) {
    return this._incomingCommentsService.markRead(org.id, id);
  }
}
