import { Entity, PrimaryColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('country')
export class Country {
  @PrimaryColumn({ length: 2 })
  code: string;

  @Column({ length: 100 })
  name_kr: string;

  @Column({ length: 100 })
  name_en: string;

  @Column({ default: 999 })
  display_order: number;

  @Column({ default: true })
  is_active: boolean;

  @CreateDateColumn()
  created_at: Date;
}
