import { GameState, GAME_STATE_KEY } from './GameState'

export { GAME_STATE_KEY }

/**
 * 全局游戏状态管理，供 UI 与 EntryAbility 共享
 */
export class GameStateManager {
  private static instance: GameStateManager | null = null
  private restoredCallback: ((state: GameState) => void) | null = null

  static getInstance(): GameStateManager {
    if (!GameStateManager.instance) {
      GameStateManager.instance = new GameStateManager()
    }
    return GameStateManager.instance
  }

  saveToAppStorage(state: GameState): void {
    AppStorage.setOrCreate(GAME_STATE_KEY, state)
  }

  getFromAppStorage(): GameState | undefined {
    return AppStorage.get<GameState>(GAME_STATE_KEY)
  }

  onRestored(callback: (state: GameState) => void): void {
    this.restoredCallback = callback
    const existing = this.getFromAppStorage()
    if (existing && existing.page !== undefined) {
      callback(existing)
    }
  }

  notifyRestored(state: GameState): void {
    this.saveToAppStorage(state)
    if (this.restoredCallback) {
      this.restoredCallback(state)
    }
  }
}
