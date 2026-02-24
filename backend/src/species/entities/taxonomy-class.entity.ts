import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  OneToMany,
} from 'typeorm';
import { Order } from './order.entity';

@Entity('class')
export class TaxonomyClass {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 100 })
  name_kr: string;

  @Column({ length: 100 })
  name_en: string;

  @Column({ length: 20, unique: true })
  code: string;

  @CreateDateColumn()
  created_at: Date;

  @OneToMany(() => Order, (order) => order.taxonomyClass)
  orders: Order[];
}
