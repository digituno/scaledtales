import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Announcement } from './entities/announcement.entity';

@Injectable()
export class AnnouncementsService {
  constructor(
    @InjectRepository(Announcement)
    private readonly announcementRepo: Repository<Announcement>,
  ) {}

  async findActive(): Promise<Announcement[]> {
    const now = new Date();
    return this.announcementRepo
      .createQueryBuilder('a')
      .where('a.is_deleted = false')
      .andWhere('a.start_at <= :now', { now })
      .andWhere('a.end_at >= :now', { now })
      .orderBy('a.start_at', 'DESC')
      .getMany();
  }
}
