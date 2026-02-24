import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { Order } from './order.entity';
import { Genus } from './genus.entity';

@Entity('family')
export class Family {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'order_id' })
  orderId: string;

  @ManyToOne(() => Order, (order) => order.families)
  @JoinColumn({ name: 'order_id' })
  order: Order;

  @Column({ length: 100 })
  name_kr: string;

  @Column({ length: 100 })
  name_en: string;

  @CreateDateColumn()
  created_at: Date;

  @OneToMany(() => Genus, (genus) => genus.family)
  genera: Genus[];
}
