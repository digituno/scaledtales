import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Species } from '@/species/entities/species.entity';

@Entity('animal')
export class Animal {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  user_id: string;

  @Column({ type: 'uuid' })
  species_id: string;

  @ManyToOne(() => Species)
  @JoinColumn({ name: 'species_id' })
  species: Species;

  @Column({ length: 100 })
  name: string;

  @Column({ length: 200, nullable: true })
  morph: string;

  @Column({ length: 20 })
  sex: string;

  @Column({ type: 'int', nullable: true })
  birth_year: number;

  @Column({ type: 'int', nullable: true })
  birth_month: number;

  @Column({ type: 'int', nullable: true })
  birth_date: number;

  @Column({ length: 20 })
  origin_type: string;

  @Column({ length: 2, nullable: true })
  origin_country: string;

  @Column({ type: 'date' })
  acquisition_date: string;

  @Column({ length: 20 })
  acquisition_source: string;

  @Column({ type: 'text', nullable: true })
  acquisition_note: string;

  @Column({ type: 'uuid', nullable: true })
  father_id: string;

  @ManyToOne(() => Animal, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'father_id' })
  father: Animal;

  @Column({ type: 'uuid', nullable: true })
  mother_id: string;

  @ManyToOne(() => Animal, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'mother_id' })
  mother: Animal;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  current_weight: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  current_length: number;

  @Column({ type: 'date', nullable: true })
  last_measured_at: string;

  @Column({ length: 20, default: 'ALIVE' })
  status: string;

  @Column({ type: 'date', nullable: true })
  deceased_date: string;

  @Column({ type: 'text', nullable: true })
  profile_image_url: string;

  @Column({ type: 'text', nullable: true })
  notes: string;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}
