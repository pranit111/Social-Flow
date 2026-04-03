import { Injectable } from '@nestjs/common';
import { IntegrationRepository } from '@gitroom/nestjs-libraries/database/prisma/integrations/integration.repository';
import { IncomingCommentsProxyRepository } from '@gitroom/nestjs-libraries/database/prisma/incoming-comments-proxy/incoming-comments-proxy.repository';
import { IntegrationManager } from '@gitroom/nestjs-libraries/integrations/integration.manager';

@Injectable()
export class IncomingCommentsProxyService {
  private readonly supportedProviders = ['instagram', 'instagram-standalone'];

  constructor(
    private _integrationRepository: IntegrationRepository,
    private _incomingCommentsProxyRepository: IncomingCommentsProxyRepository,
    private _integrationManager: IntegrationManager
  ) {}

  verifyWebhook(mode?: string, verifyToken?: string, challenge?: string) {
    const expected =
      process.env.INSTAGRAM_WEBHOOK_VERIFY_TOKEN ||
      process.env.FACEBOOK_WEBHOOK_VERIFY_TOKEN;

    if (!expected) {
      return null;
    }

    if (mode === 'subscribe' && verifyToken === expected) {
      return challenge || '';
    }

    return null;
  }

  private async getOrgIntegrationOrThrow(orgId: string, integrationId: string) {
    const integration = await this._integrationRepository.getIntegrationById(
      orgId,
      integrationId
    );

    if (!integration || integration.deletedAt) {
      throw new Error('Integration not found');
    }

    if (!this.supportedProviders.includes(integration.providerIdentifier)) {
      throw new Error('Integration is not an Instagram channel');
    }

    return integration;
  }

  async processWebhook(payload: any) {
    const entries = Array.isArray(payload?.entry) ? payload.entry : [];
    let processed = 0;
    let ignored = 0;

    for (const entry of entries) {
      const instagramInternalId = String(entry?.id || '');
      if (!instagramInternalId) {
        ignored += 1;
        continue;
      }

      const integrations =
        await this._integrationRepository.listIntegrationsByProviderAndInternalId(
          this.supportedProviders,
          instagramInternalId
        );

      if (!integrations.length) {
        ignored += 1;
        continue;
      }

      const changes = Array.isArray(entry?.changes) ? entry.changes : [];

      for (const change of changes) {
        if (change?.field !== 'comments') {
          ignored += 1;
          continue;
        }

        const verb = String(change?.value?.verb || '').toLowerCase();
        if (verb && verb !== 'add' && verb !== 'created') {
          ignored += 1;
          continue;
        }

        const mediaId = change?.value?.media?.id
          ? String(change.value.media.id)
          : undefined;
        const eventId = String(
          change?.value?.id ||
            change?.value?.comment_id ||
            `${instagramInternalId}:${Date.now()}`
        );

        for (const integration of integrations) {
          const isNewEvent =
            await this._incomingCommentsProxyRepository.markEventSeen(
              integration.id,
              eventId
            );

          if (!isNewEvent) {
            ignored += 1;
            continue;
          }

          await this._incomingCommentsProxyRepository.incrementCounter(
            integration.id,
            mediaId,
            eventId
          );
          processed += 1;
        }
      }
    }

    return { processed, ignored };
  }

  async getCounter(orgId: string, integrationId: string, mediaId?: string) {
    const integration = await this.getOrgIntegrationOrThrow(orgId, integrationId);
    const counter = await this._incomingCommentsProxyRepository.getCounter(
      integration.id
    );

    return {
      total: counter.total,
      mediaId: mediaId || null,
      mediaCount: mediaId ? Number(counter.media[mediaId] || 0) : null,
      media: counter.media,
      lastSeenCommentId: counter.lastSeenCommentId,
      updatedAt: counter.updatedAt,
    };
  }

  async resetCounter(orgId: string, integrationId: string, mediaId?: string) {
    const integration = await this.getOrgIntegrationOrThrow(orgId, integrationId);
    const counter = await this._incomingCommentsProxyRepository.resetCounter(
      integration.id,
      mediaId
    );

    return {
      success: true,
      total: counter.total,
      media: counter.media,
      updatedAt: counter.updatedAt,
    };
  }

  async fetchLiveComments(
    orgId: string,
    integrationId: string,
    mediaId: string,
    limit = 25,
    after?: string
  ) {
    const integration = await this.getOrgIntegrationOrThrow(orgId, integrationId);
    const provider = this._integrationManager.getSocialIntegration(
      integration.providerIdentifier
    );

    if (!provider?.fetchLiveComments) {
      throw new Error('Instagram provider does not support live comments');
    }

    const live = await provider.fetchLiveComments(
      mediaId,
      integration.token,
      limit,
      after
    );

    const counter = await this._incomingCommentsProxyRepository.getCounter(
      integration.id
    );

    return {
      comments: live.comments,
      paging: {
        after: live.after || null,
      },
      counters: {
        total: counter.total,
        mediaCount: Number(counter.media[mediaId] || 0),
        lastSeenCommentId: counter.lastSeenCommentId,
      },
    };
  }

  async reply(
    orgId: string,
    integrationId: string,
    commentId: string,
    message: string
  ) {
    const integration = await this.getOrgIntegrationOrThrow(orgId, integrationId);
    const provider = this._integrationManager.getSocialIntegration(
      integration.providerIdentifier
    );

    if (!provider?.replyToComment) {
      throw new Error('Instagram provider does not support replying');
    }

    const response = await provider.replyToComment(
      commentId,
      message,
      integration.token,
      integration
    );

    return {
      success: true,
      replyId: response?.id || null,
    };
  }
}