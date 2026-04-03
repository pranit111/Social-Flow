import { Injectable } from '@nestjs/common';
import { IncomingCommentsRepository } from '@gitroom/nestjs-libraries/database/prisma/incoming-comments/incoming-comments.repository';
import { IntegrationRepository } from '@gitroom/nestjs-libraries/database/prisma/integrations/integration.repository';
import { IntegrationManager } from '@gitroom/nestjs-libraries/integrations/integration.manager';

@Injectable()
export class IncomingCommentsService {
  constructor(
    private _incomingCommentsRepository: IncomingCommentsRepository,
    private _integrationRepository: IntegrationRepository,
    private _integrationManager: IntegrationManager
  ) {}

  list(orgId: string, platform?: string, unreadOnly?: boolean) {
    return this._incomingCommentsRepository.listForOrg(orgId, platform, unreadOnly);
  }

  markRead(orgId: string, id: string) {
    return this._incomingCommentsRepository.markRead(id);
  }

  async sync(orgId: string) {
    return { processed: 0 };
  }

  async reply(orgId: string, commentId: string, message: string) {
    const record = await this._incomingCommentsRepository.findByIdForOrg(
      orgId,
      commentId
    );

    if (!record) {
      throw new Error('Comment not found');
    }

    const provider = this._integrationManager.getSocialIntegration(
      record.integration.providerIdentifier
    );

    if (!provider?.replyToComment) {
      throw new Error(
        `Provider ${record.integration.providerIdentifier} does not support replying to comments`
      );
    }

    await provider.replyToComment(
      record.externalCommentId,
      message,
      record.integration.token,
      record.integration
    );

    return this._incomingCommentsRepository.markReplied(record.id);
  }
}
