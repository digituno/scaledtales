import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { TaxonomyClass } from './taxonomy-class.entity';
import { Family } from './family.entity';

@Entity('order')
export class Order {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'class_id' })
  classId: string;

  @ManyToOne(() => TaxonomyClass, (cls) => cls.orders)
  @JoinColumn({ name: 'class_id' })
  taxonomyClass: TaxonomyClass;

  @Column({ length: 100 })
  name_kr: string;

  @Column({ length: 100 })
  name_en: string;

  @CreateDateColumn()
  created_at: Date;

  @OneToMany(() => Family, (family) => family.order)
  families: Family[];
}
