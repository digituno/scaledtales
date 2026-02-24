import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Animal } from '@/animals/entities/animal.entity';

@Entity('measurement_log')
export class MeasurementLog {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  animal_id: string;

  @ManyToOne(() => Animal, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'animal_id' })
  animal: Animal;

  @Column({ type: 'date' })
  measured_date: string;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  weight: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  length: number;

  @Column({ type: 'text', nullable: true })
  notes: string;

  @CreateDateColumn()
  created_at: Date;
}
