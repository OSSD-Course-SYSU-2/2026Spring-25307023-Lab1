import { NotepadState, NOTEPAD_STATE_KEY } from './NotepadState'

export { NOTEPAD_STATE_KEY }

/**
 * 便签全局状态管理器，供 UI 与 EntryAbility 共享
 */
export class NotepadManager {
  private static instance: NotepadManager | null = null
  private restoredCallback: ((state: NotepadState) => void) | null = null

  static getInstance(): NotepadManager {
    if (!NotepadManager.instance) {
      NotepadManager.instance = new NotepadManager()
    }
    return NotepadManager.instance
  }

  saveToAppStorage(state: NotepadState): void {
    AppStorage.setOrCreate(NOTEPAD_STATE_KEY, state)
  }

  getFromAppStorage(): NotepadState | undefined {
    return AppStorage.get<NotepadState>(NOTEPAD_STATE_KEY)
  }

  onRestored(callback: (state: NotepadState) => void): void {
    this.restoredCallback = callback
    const existing = this.getFromAppStorage()
    if (existing && existing.notes.length > 0) {
      callback(existing)
    }
  }

  notifyRestored(state: NotepadState): void {
    this.saveToAppStorage(state)
    if (this.restoredCallback) {
      this.restoredCallback(state)
    }
  }
}
