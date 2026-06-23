import { continuationManager } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import { GameState } from '../common/GameState'
import { GameStateManager } from '../common/GameStateManager'

@Entry
@Component
struct ShootingGame {
  @State page: string = 'home'
  @State level: number = 1
  @State score: number = 0
  @State hp: number = 100
  @State targetX: number = 150
  @State targetY: number = 300
  @State timeLeft: number = 10
  @State currentBreakpoint: string = 'sm'

  private timer: number | null = null
  private countdownTimer: number | null = null
  private stateManager: GameStateManager = GameStateManager.getInstance()

  aboutToAppear(): void {
    this.stateManager.onRestored((state: GameState) => {
      this.applyRestoredState(state)
    })
  }

  aboutToDisappear(): void {
    this.stopAllTimers()
  }

  syncState(): void {
    this.stateManager.saveToAppStorage(new GameState(
      this.page, this.level, this.score, this.hp, this.targetX, this.targetY, this.timeLeft
    ))
  }

  applyRestoredState(state: GameState): void {
    this.page = state.page ?? 'game'
    this.level = state.level ?? 1
    this.score = state.score ?? 0
    this.hp = state.hp ?? 100
    this.targetX = state.targetX ?? 150
    this.targetY = state.targetY ?? 300
    this.timeLeft = state.timeLeft ?? 10
    if (this.page === 'game') {
      this.resumeGameTimers()
      promptAction.showToast({ message: '游戏状态已从其他设备流转恢复' })
    }
  }

  hit(damage: number): void {
    if (this.hp <= 0) {
      return
    }
    this.hp -= damage
    this.score += damage
    this.syncState()

    if (this.hp <= 0) {
      this.hp = 0
      this.stopAllTimers()
      this.page = 'result'
      this.syncState()
    } else if (this.level === 2) {
      this.moveEnemy()
    }
  }

  moveEnemy(): void {
    this.targetX = Math.floor(Math.random() * 200) + 50
    this.targetY = Math.floor(Math.random() * 400) + 100
    this.syncState()
  }

  stopAllTimers(): void {
    if (this.timer !== null) {
      clearInterval(this.timer)
      this.timer = null
    }
    if (this.countdownTimer !== null) {
      clearInterval(this.countdownTimer)
      this.countdownTimer = null
    }
  }

  resumeGameTimers(): void {
    this.stopAllTimers()
    if (this.level === 3) {
      this.timer = setInterval((): void => { this.moveEnemy() }, 800)
    }
    this.countdownTimer = setInterval((): void => {
      this.timeLeft -= 1
      this.syncState()
      if (this.timeLeft <= 0) {
        this.stopAllTimers()
        this.page = 'result'
        this.syncState()
      }
    }, 1000)
  }

  startGame(lv: number): void {
    this.level = lv
    this.hp = 100
    this.score = 0
    this.timeLeft = 10
    this.page = 'game'
    this.moveEnemy()
    this.syncState()
    this.resumeGameTimers()
  }

  startContinuation(): void {
    const token = AppStorage.get<number>('continuationToken') ?? -1
    if (token === -1) {
      promptAction.showToast({ message: '流转服务未就绪' })
      return
    }
    continuationManager.startDeviceManager(token)
      .then(() => {
        promptAction.showToast({ message: '请选择目标设备继续游戏' })
      })
      .catch(() => {
        promptAction.showToast({ message: '流转失败，请确认设备已组网' })
      })
  }

  @Builder
  HomeContent() {
    Column({ space: 20 }) {
      Text('🔫 枪战训练营')
        .fontSize(this.currentBreakpoint === 'sm' ? 32 : 40)
        .fontWeight(FontWeight.Bold)
      Text('一次开发 · 多端部署 · 自由流转')
        .fontSize(14)
        .fontColor('#666666')
      Button('第一关：定点靶')
        .width(this.currentBreakpoint === 'sm' ? 240 : 280)
        .fontSize(16)
        .onClick(() => this.startGame(1))
      Button('第二关：闪现靶')
        .width(this.currentBreakpoint === 'sm' ? 240 : 280)
        .fontSize(16)
        .onClick(() => this.startGame(2))
      Button('第三关：移动靶')
        .width(this.currentBreakpoint === 'sm' ? 240 : 280)
        .fontSize(16)
        .onClick(() => this.startGame(3))
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  StatsPanel() {
    Column({ space: 12 }) {
      Text('📊 游戏信息')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
      Text(`当前断点: ${this.currentBreakpoint.toUpperCase()}`)
        .fontSize(14)
        .fontColor('#007DFF')
      Divider().strokeWidth(1).color('#E0E0E0')
      Text(`关卡: 第 ${this.level} 关`)
        .fontSize(18)
      Text(`⏱ 剩余时间: ${this.timeLeft}s`)
        .fontSize(18)
      Text(`❤️ 血量: ${this.hp}`)
        .fontSize(18)
      Text(`⭐ 分数: ${this.score}`)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
      Divider().strokeWidth(1).color('#E0E0E0')
      Button('📱 流转到其他设备')
        .width('100%')
        .backgroundColor('#007DFF')
        .fontColor(Color.White)
        .borderRadius(8)
        .onClick(() => this.startContinuation())
      Button('🏠 返回首页')
        .width('100%')
        .backgroundColor('#E0E0E0')
        .onClick(() => {
          this.stopAllTimers()
          this.page = 'home'
          this.syncState()
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 8, color: '#10000000', offsetY: 2 })
  }

  @Builder
  GameArea() {
    Stack() {
      Rect({ width: 40, height: 40 })
        .radius(20)
        .fill(Color.Red)
        .position({ x: 5, y: 0 })
        .onClick(() => this.hit(100))
      Rect({ width: 50, height: 70 })
        .fill(Color.Blue)
        .position({ x: 0, y: 40 })
        .onClick(() => this.hit(50))
      Rect({ width: 80, height: 20 })
        .fill(Color.Gray)
        .position({ x: -15, y: 50 })
        .onClick(() => this.hit(20))
    }
    .width(50)
    .height(120)
    .position({ x: this.targetX, y: this.targetY })
    .animation({ duration: 300 })
  }

  @Builder
  GameContent() {
    if (this.currentBreakpoint === 'sm') {
      // 手机：单列纵向布局
      Column() {
        Row() {
          Text(`第 ${this.level} 关`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
          Blank()
          Text(`⏱ ${this.timeLeft}s`)
            .fontSize(16)
          Blank()
          Text(`❤️ ${this.hp}`)
            .fontSize(16)
            .fontColor(Color.Red)
        }
        .width('100%')
        .padding(12)

        Text(`⭐ 分数: ${this.score}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 8 })

        Stack() {
          this.GameArea()
        }
        .width('100%')
        .height(400)
        .backgroundColor('#E8E8E8')
        .borderRadius(8)
        .margin({ left: 16, right: 16 })

        Row({ space: 12 }) {
          Button('📱 流转')
            .backgroundColor('#007DFF')
            .fontColor(Color.White)
            .layoutWeight(1)
            .onClick(() => this.startContinuation())
          Button('🏠 返回')
            .backgroundColor('#E0E0E0')
            .layoutWeight(1)
            .onClick(() => {
              this.stopAllTimers()
              this.page = 'home'
              this.syncState()
            })
        }
        .margin({ top: 16, left: 16, right: 16 })
      }
      .width('100%')
      .height('100%')
    } else {
      // 平板：双栏布局
      Row({ space: 16 }) {
        Column() {
          this.StatsPanel()
        }
        .width('30%')
        .height('100%')
        .justifyContent(FlexAlign.Center)

        Column() {
          Text('🎯 射击区域')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 12 })
          Stack() {
            this.GameArea()
          }
          .width('100%')
          .height('80%')
          .backgroundColor('#E8E8E8')
          .borderRadius(12)
        }
        .layoutWeight(1)
        .height('100%')
        .padding(16)
      }
      .width('100%')
      .height('100%')
      .padding(16)
    }
  }

  @Builder
  ResultContent() {
    Column({ space: 20 }) {
      Text(this.hp <= 0 ? '🎉 目标击杀！' : '⏰ 时间到，任务失败')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
      Text(`最终得分: ${this.score}`)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FF6600')
      Button('🔄 再来一局')
        .fontSize(18)
        .width(200)
        .backgroundColor('#4CAF50')
        .fontColor(Color.White)
        .onClick(() => this.startGame(this.level))
      Button('🏠 返回首页')
        .fontSize(16)
        .width(200)
        .backgroundColor('#E0E0E0')
        .onClick(() => {
          this.page = 'home'
          this.syncState()
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    GridRow({
      columns: { sm: 4, md: 8, lg: 12 },
      breakpoints: {
        value: ['320vp', '600vp', '840vp'],
        reference: BreakpointsReference.WindowSize
      }
    }) {
      GridCol({ span: { sm: 4, md: 8, lg: 12 } }) {
        Column() {
          if (this.page === 'home') {
            this.HomeContent()
          } else if (this.page === 'game') {
            this.GameContent()
          } else {
            this.ResultContent()
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#F0F0F0')
      }
    }
    .width('100%')
    .height('100%')
    .onBreakpointChange((breakpoint: string) => {
      this.currentBreakpoint = breakpoint
    })
  }
}
