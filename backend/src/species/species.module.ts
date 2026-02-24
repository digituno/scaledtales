import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SpeciesController } from './species.controller';
import { SpeciesService } from './species.service';
import { TaxonomyClass } from './entities/taxonomy-class.entity';
import { Order } from './entities/order.entity';
import { Family } from './entities/family.entity';
import { Genus } from './entities/genus.entity';
import { Species } from './entities/species.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([TaxonomyClass, Order, Family, Genus, Species]),
  ],
  controllers: [SpeciesController],
  providers: [SpeciesService],
  exports: [SpeciesService],
})
export class SpeciesModule {}
