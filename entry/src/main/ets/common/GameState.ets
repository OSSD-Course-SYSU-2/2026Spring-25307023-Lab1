/**
 * 游戏状态数据模型，用于分布式数据对象跨设备迁移
 */
export class GameState {
  page: string | undefined
  level: number | undefined
  score: number | undefined
  hp: number | undefined
  targetX: number | undefined
  targetY: number | undefined
  timeLeft: number | undefined

  constructor(
    page?: string,
    level?: number,
    score?: number,
    hp?: number,
    targetX?: number,
    targetY?: number,
    timeLeft?: number
  ) {
    this.page = page
    this.level = level
    this.score = score
    this.hp = hp
    this.targetX = targetX
    this.targetY = targetY
    this.timeLeft = timeLeft
  }
}

export const GAME_STATE_KEY = 'gameState'
