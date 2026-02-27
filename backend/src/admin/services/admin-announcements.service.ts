import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Announcement } from '@/announcements/entities/announcement.entity';
import { CreateAnnouncementDto } from '../dto/create-announcement.dto';
import { UpdateAnnouncementDto } from '../dto/update-announcement.dto';

@Injectable()
export class AdminAnnouncementsService {
  constructor(
    @InjectRepository(Announcement)
    private readonly announcementRepo: Repository<Announcement>,
  ) {}

  async listAnnouncements(query: { page?: number; limit?: number }) {
    const { page = 1, limit = 20 } = query;
    const skip = (page - 1) * limit;

    const [items, total] = await this.announcementRepo.findAndCount({
      order: { created_at: 'DESC' },
      skip,
      take: limit,
    });

    return {
      data: items,
      pagination: { page, limit, total },
    };
  }

  async createAnnouncement(dto: CreateAnnouncementDto): Promise<Announcement> {
    const announcement = this.announcementRepo.create({
      title: dto.title,
      content: dto.content,
      start_at: new Date(dto.start_at),
      end_at: new Date(dto.end_at),
    });
    return this.announcementRepo.save(announcement);
  }

  async updateAnnouncement(
    id: string,
    dto: UpdateAnnouncementDto,
  ): Promise<Announcement> {
    const announcement = await this.announcementRepo.findOne({ where: { id } });
    if (!announcement) {
      throw new NotFoundException(`공지사항을 찾을 수 없습니다: ${id}`);
    }

    const updateData: Partial<Announcement> = {};
    if (dto.title !== undefined) updateData.title = dto.title;
    if (dto.content !== undefined) updateData.content = dto.content;
    if (dto.start_at !== undefined)
      updateData.start_at = new Date(dto.start_at);
    if (dto.end_at !== undefined) updateData.end_at = new Date(dto.end_at);

    const updated = this.announcementRepo.merge(announcement, updateData);
    return this.announcementRepo.save(updated);
  }

  async softDeleteAnnouncement(id: string): Promise<void> {
    const announcement = await this.announcementRepo.findOne({ where: { id } });
    if (!announcement) {
      throw new NotFoundException(`공지사항을 찾을 수 없습니다: ${id}`);
    }
    const updated = this.announcementRepo.merge(announcement, {
      is_deleted: true,
    });
    await this.announcementRepo.save(updated);
  }
}
