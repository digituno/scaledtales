import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Genus } from './genus.entity';

@Entity('species')
export class Species {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'genus_id' })
  genusId: string;

  @ManyToOne(() => Genus, (genus) => genus.species)
  @JoinColumn({ name: 'genus_id' })
  genus: Genus;

  @Column({ length: 100 })
  species_kr: string;

  @Column({ length: 100 })
  species_en: string;

  @Column({ length: 200 })
  scientific_name: string;

  @Column({ length: 200, nullable: true })
  common_name_kr: string;

  @Column({ length: 200, nullable: true })
  common_name_en: string;

  @Column({ default: false })
  is_cites: boolean;

  @Column({ length: 20, nullable: true })
  cites_level: string;

  @Column({ default: false })
  is_whitelist: boolean;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}
