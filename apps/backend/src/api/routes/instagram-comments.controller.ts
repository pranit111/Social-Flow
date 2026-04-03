import { Body, Controller, Get, Patch, Post, Query } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { Organization } from '@prisma/client';
import { GetOrgFromRequest } from '@gitroom/nestjs-libraries/user/org.from.request';
import { IncomingCommentsProxyService } from '@gitroom/nestjs-libraries/database/prisma/incoming-comments-proxy/incoming-comments-proxy.service';

@ApiTags('Instagram Comments')
@Controller('/instagram-comments')
export class InstagramCommentsController {
  constructor(
    private _incomingCommentsProxyService: IncomingCommentsProxyService
  ) {}

  @Get('/counter')
  getCounter(
    @GetOrgFromRequest() org: Organization,
    @Query('integrationId') integrationId: string,
    @Query('mediaId') mediaId?: string
  ) {
    return this._incomingCommentsProxyService.getCounter(
      org.id,
      integrationId,
      mediaId
    );
  }

  @Patch('/counter/reset')
  resetCounter(
    @GetOrgFromRequest() org: Organization,
    @Body() body: { integrationId: string; mediaId?: string }
  ) {
    return this._incomingCommentsProxyService.resetCounter(
      org.id,
      body.integrationId,
      body.mediaId
    );
  }

  @Get('/live')
  liveComments(
    @GetOrgFromRequest() org: Organization,
    @Query('integrationId') integrationId: string,
    @Query('mediaId') mediaId: string,
    @Query('limit') limit?: string,
    @Query('after') after?: string
  ) {
    return this._incomingCommentsProxyService.fetchLiveComments(
      org.id,
      integrationId,
      mediaId,
      limit ? Number(limit) : 25,
      after
    );
  }

  @Post('/reply')
  reply(
    @GetOrgFromRequest() org: Organization,
    @Body() body: { integrationId: string; commentId: string; message: string }
  ) {
    return this._incomingCommentsProxyService.reply(
      org.id,
      body.integrationId,
      body.commentId,
      body.message
    );
  }
}
