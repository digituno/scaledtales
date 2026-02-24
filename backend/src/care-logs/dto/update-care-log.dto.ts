import { PartialType } from '@nestjs/swagger';
import { CreateCareLogDto } from './create-care-log.dto';

export class UpdateCareLogDto extends PartialType(CreateCareLogDto) {}
