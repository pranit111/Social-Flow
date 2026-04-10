import { Injectable } from '@nestjs/common';
import { PostsService } from '@gitroom/nestjs-libraries/database/prisma/posts/posts.service';

@Injectable()
export class IncomingCommentsProxyService {
  private readonly supportedProviders = ['instagram', 'instagram-standalone'];

  constructor(private _postsService: PostsService) {}

  private normalizeWebhookToken(value?: string) {
    if (!value) return '';
    const trimmed = value.trim();
    const hasSingleQuotes = trimmed.startsWith("'") && trimmed.endsWith("'");
    const hasDoubleQuotes = trimmed.startsWith('"') && trimmed.endsWith('"');
    if (hasSingleQuotes || hasDoubleQuotes) return trimmed.slice(1, -1).trim();
    return trimmed;
  }

  verifyWebhook(mode?: string, verifyToken?: string, challenge?: string) {
    const expectedRaw =
      process.env.INSTAGRAM_WEBHOOK_VERIFY_TOKEN ||
      process.env.FACEBOOK_WEBHOOK_VERIFY_TOKEN;
    const expected = this.normalizeWebhookToken(expectedRaw);
    const incomingToken = this.normalizeWebhookToken(verifyToken);
    const normalizedMode = (mode || '').trim().toLowerCase();

    if (!expected) return null;
    if (normalizedMode === 'subscribe' && incomingToken === expected) {
      return challenge || '';
    }
    return null;
  }

  async processWebhook(payload: any) {
    const entries = Array.isArray(payload?.entry) ? payload.entry : [];
    let processed = 0;
    let ignored = 0;

    for (const entry of entries) {
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
          : null;

        if (!mediaId) {
          ignored += 1;
          continue;
        }

        await this._postsService.incrementCommentsCount(mediaId);
        processed += 1;
      }
    }

    return { processed, ignored };
  }
}
