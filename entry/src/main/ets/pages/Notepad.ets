import { continuationManager } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import { NoteItem, NotepadState, NOTE_COLORS } from '../common/NotepadState'
import { NotepadManager } from '../common/NotepadManager'

@Entry
@Component
struct Notepad {
  @State notes: NoteItem[] = []
  @State currentNoteIndex: number = -1
  @State scrollOffset: number = 0
  @State currentBreakpoint: string = 'sm'
  @State editTitle: string = ''
  @State editContent: string = ''
  @State editColor: string = NOTE_COLORS[0]
  @State isAddingNew: boolean = false
  private manager: NotepadManager = NotepadManager.getInstance()

  aboutToAppear(): void {
    this.manager.onRestored((state: NotepadState) => {
      this.applyRestoredState(state)
    })
    // 加载一些示例便签（首次使用）
    if (this.notes.length === 0) {
      this.notes = [
        new NoteItem('1', '欢迎使用协作便签', '这是一个支持「一次开发，多端部署」及「自由流转」的跨设备协作便签应用。\n\n你可以：\n· 创建和编辑便签\n· 在不同设备上查看和编辑\n· 将编辑状态流转到其他设备继续编辑',
          NOTE_COLORS[0], new Date().toISOString()),
        new NoteItem('2', 'HarmonyOS NEXT 特性', '1. 一次开发，多端部署 —— 使用 GridRow/GridCol 响应式栅格布局，根据断点自动适配手机与平板\n2. 自由流转 —— 使用 distributedDataObject 实现编辑状态跨设备迁移',
          NOTE_COLORS[2], new Date().toISOString())
      ]
      this.persistState()
    }
  }

  // ==================== 状态管理 ====================
  persistState(): void {
    this.manager.saveToAppStorage(new NotepadState(this.notes, this.currentNoteIndex, this.scrollOffset))
  }

  applyRestoredState(state: NotepadState): void {
    if (state.notes && state.notes.length > 0) {
      this.notes = state.notes
    }
    if (state.currentNoteIndex !== undefined && state.currentNoteIndex >= 0) {
      this.currentNoteIndex = state.currentNoteIndex
      const note = this.notes[this.currentNoteIndex]
      if (note) {
        this.editTitle = note.title
        this.editContent = note.content
        this.editColor = note.color
      }
    }
    this.scrollOffset = state.scrollOffset ?? 0
    if (state.currentNoteIndex >= 0) {
      promptAction.showToast({ message: '便签编辑状态已从其他设备流转恢复' })
    }
  }

  // ==================== 便签操作 ====================
  generateId(): string {
    return `${Date.now()}_${Math.floor(Math.random() * 10000)}`
  }

  openNote(index: number): void {
    this.currentNoteIndex = index
    const note = this.notes[index]
    this.editTitle = note.title
    this.editContent = note.content
    this.editColor = note.color
    this.isAddingNew = false
    this.persistState()
  }

  addNewNote(): void {
    this.editTitle = ''
    this.editContent = ''
    this.editColor = NOTE_COLORS[Math.floor(Math.random() * NOTE_COLORS.length)]
    this.isAddingNew = true
    this.currentNoteIndex = -2 // 标记为新建中
    this.persistState()
  }

  saveNote(): void {
    if (this.editTitle.trim() === '' && this.editContent.trim() === '') {
      promptAction.showToast({ message: '标题或内容不能都为空' })
      return
    }
    if (this.isAddingNew) {
      const newNote = new NoteItem(
        this.generateId(),
        this.editTitle.trim() || '无标题',
        this.editContent,
        this.editColor,
        new Date().toISOString()
      )
      this.notes = [newNote, ...this.notes]
      this.currentNoteIndex = 0
      this.isAddingNew = false
    } else if (this.currentNoteIndex >= 0) {
      const note = this.notes[this.currentNoteIndex]
      note.title = this.editTitle.trim() || '无标题'
      note.content = this.editContent
      note.color = this.editColor
    }
    this.persistState()
    promptAction.showToast({ message: '便签已保存' })
  }

  deleteNote(): void {
    if (this.currentNoteIndex < 0) {
      return
    }
    this.notes.splice(this.currentNoteIndex, 1)
    this.currentNoteIndex = -1
    this.editTitle = ''
    this.editContent = ''
    this.persistState()
    promptAction.showToast({ message: '便签已删除' })
  }

  closeEditor(): void {
    this.currentNoteIndex = -1
    this.isAddingNew = false
    this.editTitle = ''
    this.editContent = ''
    this.persistState()
  }

  // ==================== 自由流转 ====================
  startContinuation(): void {
    const token = AppStorage.get<number>('continuationToken') ?? -1
    if (token === -1) {
      promptAction.showToast({ message: '流转服务未就绪' })
      return
    }
    this.persistState()
    continuationManager.startDeviceManager(token)
      .then(() => {
        promptAction.showToast({ message: '请选择目标设备继续编辑' })
      })
      .catch(() => {
        promptAction.showToast({ message: '流转失败，请确认设备已组网' })
      })
  }

  formatDate(iso: string): string {
    if (!iso) {
      return ''
    }
    const d = new Date(iso)
    return `${d.getMonth() + 1}/${d.getDate()} ${d.getHours().toString().padStart(2, '0')}:${d.getMinutes().toString().padStart(2, '0')}`
  }

  // ==================== 构建器 ====================
  @Builder
  NoteCard(note: NoteItem, index: number) {
    Column() {
      Text(note.title || '无标题')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
      Text(note.content)
        .fontSize(12)
        .fontColor('#555555')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .margin({ top: 4 })
      Blank()
      Text(this.formatDate(note.createdAt))
        .fontSize(10)
        .fontColor('#999999')
        .alignSelf(ItemAlign.End)
    }
    .width('100%')
    .height(100)
    .padding(12)
    .backgroundColor(note.color)
    .borderRadius(8)
    .onClick(() => this.openNote(index))
  }

  @Builder
  NoteGrid() {
    GridRow({
      columns: { sm: 8, md: 8, lg: 12 },
      gutter: { x: 8, y: 8 },
      breakpoints: {
        value: ['320vp', '600vp', '840vp'],
        reference: BreakpointsReference.WindowSize
      }
    }) {
      ForEach(this.notes, (note: NoteItem, index: number) => {
        GridCol({ span: { sm: 4, md: 4, lg: 4 } }) {
          this.NoteCard(note, index)
        }
      })
    }
    .width('100%')
    .padding(8)
  }

  @Builder
  EditorPanel() {
    Column({ space: 12 }) {
      // 标题栏
      Row() {
        Button('← 返回')
          .fontSize(14)
          .backgroundColor('#E0E0E0')
          .onClick(() => this.closeEditor())
        Blank()
        Text(this.isAddingNew ? '新建便签' : '编辑便签')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        Blank()
        Button('删除')
          .fontSize(14)
          .backgroundColor('#FF5252')
          .fontColor(Color.White)
          .onClick(() => this.deleteNote())
      }
      .width('100%')

      // 颜色选择
      Row({ space: 8 }) {
        Text('颜色:').fontSize(13)
        ForEach(NOTE_COLORS, (color: string) => {
          Row()
            .width(28)
            .height(28)
            .borderRadius(14)
            .backgroundColor(color)
            .border({
              width: this.editColor === color ? 3 : 1,
              color: this.editColor === color ? '#333333' : '#CCCCCC'
            })
            .onClick(() => { this.editColor = color })
        })
      }
      .width('100%')

      // 标题输入
      TextInput({ placeholder: '便签标题', text: this.editTitle })
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius(4)
        .onChange((value: string) => { this.editTitle = value })

      // 内容编辑区
      TextArea({ placeholder: '输入便签内容...', text: this.editContent })
        .fontSize(15)
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(Color.White)
        .borderRadius(4)
        .onChange((value: string) => { this.editContent = value })

      // 底部操作栏
      Row({ space: 12 }) {
        Button('保存便签')
          .fontSize(15)
          .backgroundColor('#4CAF50')
          .fontColor(Color.White)
          .layoutWeight(1)
          .onClick(() => this.saveNote())
        Button('流转→')
          .fontSize(15)
          .backgroundColor('#007DFF')
          .fontColor(Color.White)
          .layoutWeight(1)
          .onClick(() => this.startContinuation())
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }

  @Builder
  NoteListPanel() {
    Column({ space: 8 }) {
      Row() {
        Text('📝 协作便签')
          .fontSize(this.currentBreakpoint === 'sm' ? 24 : 28)
          .fontWeight(FontWeight.Bold)
        Blank()
        Button('+ 新增')
          .fontSize(14)
          .backgroundColor('#4CAF50')
          .fontColor(Color.White)
          .borderRadius(20)
          .onClick(() => this.addNewNote())
      }
      .width('100%')
      .padding({ left: 8, right: 8, top: 8 })

      if (this.notes.length === 0) {
        Column() {
          Text('暂无便签')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 60 })
          Text('点击右上角 "+ 新增" 创建第一篇便签')
            .fontSize(13)
            .fontColor('#BBBBBB')
            .margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          this.NoteGrid()
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }

      // 底部流转按钮
      Button('📱 流转到其他设备')
        .fontSize(14)
        .backgroundColor('#007DFF')
        .fontColor(Color.White)
        .width('100%')
        .borderRadius(8)
        .onClick(() => this.startContinuation())
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAFAFA')
  }

  // ==================== 主构建方法 ====================
  build() {
    GridRow({
      columns: { sm: 4, md: 8, lg: 12 },
      gutter: { x: { sm: 0, md: 0, lg: 0 } },
      breakpoints: {
        value: ['320vp', '600vp', '840vp'],
        reference: BreakpointsReference.WindowSize
      }
    }) {
      GridCol({ span: { sm: 4, md: 8, lg: 12 } }) {
        // 编辑模式判断
        if (this.currentNoteIndex >= 0 || this.isAddingNew) {
          // 编辑模式 —— 响应式布局
          if (this.currentBreakpoint === 'sm') {
            // 手机：全屏编辑器
            Column() {
              this.EditorPanel()
            }
            .width('100%')
            .height('100%')
          } else {
            // 平板：左侧列表 + 右侧编辑器
            Row() {
              Column() {
                this.NoteListPanel()
              }
              .width('32%')
              .height('100%')
              .border({
                width: { right: 1 },
                color: '#E0E0E0'
              })

              Column() {
                this.EditorPanel()
              }
              .layoutWeight(1)
              .height('100%')
            }
            .width('100%')
            .height('100%')
          }
        } else {
          // 浏览模式 —— 便签列表
          this.NoteListPanel()
        }
      }
    }
    .width('100%')
    .height('100%')
    .onBreakpointChange((breakpoint: string) => {
      this.currentBreakpoint = breakpoint
    })
  }
}
