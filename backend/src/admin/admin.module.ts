import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

// Entities
import { TaxonomyClass } from '@/species/entities/taxonomy-class.entity';
import { Order } from '@/species/entities/order.entity';
import { Family } from '@/species/entities/family.entity';
import { Genus } from '@/species/entities/genus.entity';
import { Species } from '@/species/entities/species.entity';
import { Animal } from '@/animals/entities/animal.entity';
import { CareLog } from '@/care-logs/entities/care-log.entity';
import { Announcement } from '@/announcements/entities/announcement.entity';

// Guards
import { AdminGuard } from './guards/admin.guard';

// Services
import { AdminUsersService } from './services/admin-users.service';
import { AdminSpeciesService } from './services/admin-species.service';
import { AdminTaxonomyService } from './services/admin-taxonomy.service';
import { AdminStatsService } from './services/admin-stats.service';
import { AdminAnnouncementsService } from './services/admin-announcements.service';

// Controllers
import { AdminUsersController } from './controllers/admin-users.controller';
import { AdminSpeciesController } from './controllers/admin-species.controller';
import { AdminTaxonomyController } from './controllers/admin-taxonomy.controller';
import { AdminStatsController } from './controllers/admin-stats.controller';
import { AdminAnnouncementsController } from './controllers/admin-announcements.controller';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      TaxonomyClass,
      Order,
      Family,
      Genus,
      Species,
      Animal,
      CareLog,
      Announcement,
    ]),
  ],
  providers: [
    AdminGuard,
    AdminUsersService,
    AdminSpeciesService,
    AdminTaxonomyService,
    AdminStatsService,
    AdminAnnouncementsService,
  ],
  controllers: [
    AdminUsersController,
    AdminSpeciesController,
    AdminTaxonomyController,
    AdminStatsController,
    AdminAnnouncementsController,
  ],
})
export class AdminModule {}
