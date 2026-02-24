import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { Family } from './family.entity';
import { Species } from './species.entity';

@Entity('genus')
export class Genus {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'family_id' })
  familyId: string;

  @ManyToOne(() => Family, (family) => family.genera)
  @JoinColumn({ name: 'family_id' })
  family: Family;

  @Column({ length: 100 })
  name_kr: string;

  @Column({ length: 100 })
  name_en: string;

  @CreateDateColumn()
  created_at: Date;

  @OneToMany(() => Species, (species) => species.genus)
  species: Species[];
}
