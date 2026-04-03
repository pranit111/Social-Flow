import { IsString, MinLength } from 'class-validator';

export class ReplyIncomingCommentDto {
  @IsString()
  @MinLength(1)
  message: string;
}
