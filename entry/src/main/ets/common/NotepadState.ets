/**
 * 便签数据模型
 */
export class NoteItem {
  id: string
  title: string
  content: string
  color: string
  createdAt: string

  constructor(
    id: string = '',
    title: string = '',
    content: string = '',
    color: string = '#FFF9C4',
    createdAt: string = ''
  ) {
    this.id = id
    this.title = title
    this.content = content
    this.color = color
    this.createdAt = createdAt
  }
}

/**
 * 便签应用完整状态 —— 用于分布式数据对象跨设备迁移
 */
export class NotepadState {
  notes: NoteItem[]
  currentNoteIndex: number
  scrollOffset: number

  constructor(
    notes?: NoteItem[],
    currentNoteIndex?: number,
    scrollOffset?: number
  ) {
    this.notes = notes ?? []
    this.currentNoteIndex = currentNoteIndex ?? -1
    this.scrollOffset = scrollOffset ?? 0
  }
}

/**
 * 预设的便签背景颜色
 */
export const NOTE_COLORS: string[] = [
  '#FFF9C4', // 淡黄
  '#F8BBD0', // 淡粉
  '#BBDEFB', // 淡蓝
  '#C8E6C9', // 淡绿
  '#FFE0B2', // 淡橙
  '#E1BEE7'  // 淡紫
]

export const NOTEPAD_STATE_KEY = 'notepadState'
