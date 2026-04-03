import { Injectable } from '@nestjs/common';
import { ioRedis } from '@gitroom/nestjs-libraries/redis/redis.service';

type CommentsCounterShape = {
  total: number;
  media: Record<string, number>;
  updatedAt: string;
};

@Injectable()
export class IncomingCommentsProxyRepository {
  private counterKey(integrationId: string) {
    return `ig:comments:counter:${integrationId}`;
  }

  private dedupeKey(integrationId: string, eventId: string) {
    return `ig:comments:dedupe:${integrationId}:${eventId}`;
  }

  private lastSeenKey(integrationId: string) {
    return `ig:comments:last_seen:${integrationId}`;
  }

  private async getCounterRaw(integrationId: string) {
    const raw = await ioRedis.get(this.counterKey(integrationId));
    if (!raw) {
      return {
        total: 0,
        media: {},
        updatedAt: new Date().toISOString(),
      } as CommentsCounterShape;
    }

    try {
      const parsed = JSON.parse(raw) as CommentsCounterShape;
      return {
        total: Number(parsed.total || 0),
        media: parsed.media || {},
        updatedAt: parsed.updatedAt || new Date().toISOString(),
      };
    } catch {
      return {
        total: 0,
        media: {},
        updatedAt: new Date().toISOString(),
      } as CommentsCounterShape;
    }
  }

  async markEventSeen(integrationId: string, eventId: string) {
    const key = this.dedupeKey(integrationId, eventId);
    const exists = await ioRedis.get(key);
    if (exists) {
      return false;
    }

    await ioRedis.set(key, '1');
    return true;
  }

  async incrementCounter(
    integrationId: string,
    mediaId?: string,
    lastSeenEventId?: string
  ) {
    const current = await this.getCounterRaw(integrationId);
    current.total += 1;

    if (mediaId) {
      current.media[mediaId] = Number(current.media[mediaId] || 0) + 1;
    }

    current.updatedAt = new Date().toISOString();
    await ioRedis.set(this.counterKey(integrationId), JSON.stringify(current));

    if (lastSeenEventId) {
      await ioRedis.set(this.lastSeenKey(integrationId), lastSeenEventId);
    }

    return current;
  }

  async getCounter(integrationId: string) {
    const counter = await this.getCounterRaw(integrationId);
    const lastSeenCommentId = await ioRedis.get(this.lastSeenKey(integrationId));
    return {
      ...counter,
      lastSeenCommentId: lastSeenCommentId || null,
    };
  }

  async resetCounter(integrationId: string, mediaId?: string) {
    const current = await this.getCounterRaw(integrationId);

    if (!mediaId) {
      const cleared = {
        total: 0,
        media: {},
        updatedAt: new Date().toISOString(),
      } as CommentsCounterShape;
      await ioRedis.set(this.counterKey(integrationId), JSON.stringify(cleared));
      return cleared;
    }

    const mediaCount = Number(current.media[mediaId] || 0);
    current.total = Math.max(0, current.total - mediaCount);
    delete current.media[mediaId];
    current.updatedAt = new Date().toISOString();

    await ioRedis.set(this.counterKey(integrationId), JSON.stringify(current));
    return current;
  }
}