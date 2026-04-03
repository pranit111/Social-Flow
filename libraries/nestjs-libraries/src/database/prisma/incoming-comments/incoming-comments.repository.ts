import { Injectable } from '@nestjs/common';
import { PrismaRepository } from '@gitroom/nestjs-libraries/database/prisma/prisma.service';
import { IncomingCommentItem } from '@gitroom/nestjs-libraries/integrations/social/social.integrations.interface';

@Injectable()
export class IncomingCommentsRepository {
  constructor(
    private _integration: PrismaRepository<'integration'>
  ) {}

  listForOrg(orgId: string, platform?: string, unreadOnly?: boolean) {
    return [] as any[];
  }

  upsertComment(
    orgId: string,
    integrationId: string,
    platform: string,
    item: IncomingCommentItem
  ) {
    return {
      id: item.externalCommentId,
      organizationId: orgId,
      integrationId,
      platform,
    };
  }

  markReplied(id: string) {
    return { id, repliedAt: new Date() };
  }

  markRead(id: string) {
    return { id, isRead: true };
  }

  findByIdForOrg(orgId: string, id: string) {
    return null;
  }
}
