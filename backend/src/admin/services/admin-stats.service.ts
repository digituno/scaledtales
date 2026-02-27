import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Animal } from '@/animals/entities/animal.entity';
import { CareLog } from '@/care-logs/entities/care-log.entity';
import { Species } from '@/species/entities/species.entity';
import { SupabaseService } from '@config/supabase.service';

@Injectable()
export class AdminStatsService {
  constructor(
    @InjectRepository(Animal)
    private readonly animalRepo: Repository<Animal>,
    @InjectRepository(CareLog)
    private readonly careLogRepo: Repository<CareLog>,
    @InjectRepository(Species)
    private readonly speciesRepo: Repository<Species>,
    private readonly supabaseService: SupabaseService,
  ) {}

  async getStats() {
    const [
      totalAnimals,
      aliveAnimals,
      totalCareLogs,
      totalSpecies,
      careLogsByType,
      newAnimalsThisMonth,
    ] = await Promise.all([
      this.animalRepo.count(),
      this.animalRepo.count({ where: { status: 'ALIVE' as any } }),
      this.careLogRepo.count(),
      this.speciesRepo.count(),
      // 케어로그 타입별 통계
      this.careLogRepo
        .createQueryBuilder('cl')
        .select('cl.log_type', 'log_type')
        .addSelect('COUNT(*)', 'count')
        .groupBy('cl.log_type')
        .getRawMany(),
      // 이번달 신규 개체
      this.animalRepo
        .createQueryBuilder('a')
        .where("DATE_TRUNC('month', a.created_at) = DATE_TRUNC('month', NOW())")
        .getCount(),
    ]);

    // 신규 사용자 (이번달)
    const { data: authData } = await this.supabaseService
      .getAdminAuth()
      .listUsers({ page: 1, perPage: 1000 });

    const now = new Date();
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
    const newUsersThisMonth = ((authData?.users ?? []) as any[]).filter(
      (u) => new Date(u.created_at) >= monthStart,
    ).length;

    const totalUsers = (authData as any)?.total ?? authData?.users?.length ?? 0;

    return {
      animals: {
        total: totalAnimals,
        alive: aliveAnimals,
        newThisMonth: newAnimalsThisMonth,
      },
      careLogs: {
        total: totalCareLogs,
        byType: careLogsByType.map((r) => ({
          type: r.log_type,
          count: parseInt(r.count, 10),
        })),
      },
      species: {
        total: totalSpecies,
      },
      users: {
        total: totalUsers,
        newThisMonth: newUsersThisMonth,
      },
    };
  }
}
