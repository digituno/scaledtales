import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Animal } from '@/animals/entities/animal.entity';
import { CareLogDetails } from '../types/care-log-details.types';

@Entity('care_log')
export class CareLog {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  animal_id: string;

  @ManyToOne(() => Animal, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'animal_id' })
  animal: Animal;

  @Column({ type: 'uuid' })
  user_id: string;

  @Column({ length: 20 })
  log_type: string;

  @Column({ type: 'timestamp' })
  log_date: Date;

  @Column({ type: 'uuid', nullable: true })
  parent_log_id: string;

  @ManyToOne(() => CareLog, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'parent_log_id' })
  parentLog: CareLog;

  @Column({ type: 'jsonb' })
  details: CareLogDetails;

  @Column({ type: 'jsonb', nullable: true })
  images: Array<{ url: string; order: number; caption: string | null }>;

  @Column({ type: 'text', nullable: true })
  notes: string;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}
