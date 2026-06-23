import { router } from '@kit.ArkUI'

@Entry
@Component
struct Index {
  @State currentBreakpoint: string = 'sm'

  aboutToAppear(): void {
    // 检查是否有流转恢复的状态，如果有则直接跳转到对应应用
    const gameState = AppStorage.get('gameState')
    if (gameState && gameState['page'] === 'game') {
      router.pushUrl({ url: 'pages/ShootingGame' })
      return
    }
    const notepadState = AppStorage.get('notepadState')
    if (notepadState && notepadState['currentNoteIndex'] >= 0) {
      router.pushUrl({ url: 'pages/Notepad' })
      return
    }
  }

  @Builder
  HeaderSection() {
    Column({ space: 8 }) {
      Text('HarmonyOS 开源实践')
        .fontSize(14)
        .fontColor('#666666')
        .letterSpacing(2)
      Text('一次开发 · 多端部署 · 自由流转')
        .fontSize(this.currentBreakpoint === 'sm' ? 24 : 32)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
      Text('中山大学 开源软件设计课程 Lab1')
        .fontSize(13)
        .fontColor('#999999')
    }
    .width('100%')
    .padding({ top: 40, bottom: 20 })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  AppCard(
    icon: string,
    title: string,
    description: string,
    tags: string[],
    bgColor: string,
    routeUrl: string
  ) {
    Column({ space: 12 }) {
      // 图标
      Text(icon)
        .fontSize(48)

      // 标题
      Text(title)
        .fontSize(this.currentBreakpoint === 'sm' ? 20 : 24)
        .fontWeight(FontWeight.Bold)

      // 描述
      Text(description)
        .fontSize(13)
        .fontColor('#666666')
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Center)

      // 标签
      Row({ space: 6 }) {
        ForEach(tags, (tag: string) => {
          Text(tag)
            .fontSize(10)
            .fontColor('#FFFFFF')
            .backgroundColor('#007DFF')
            .borderRadius(10)
            .padding({ left: 10, right: 10, top: 3, bottom: 3 })
        })
      }

      Blank()

      // 进入按钮
      Button('进入应用 →')
        .fontSize(15)
        .backgroundColor('#007DFF')
        .fontColor(Color.White)
        .width('100%')
        .borderRadius(8)
        .onClick(() => {
          router.pushUrl({ url: routeUrl })
        })
    }
    .width('100%')
    .height(this.currentBreakpoint === 'sm' ? 260 : 320)
    .padding(20)
    .backgroundColor(bgColor)
    .borderRadius(16)
    .shadow({ radius: 12, color: '#15000000', offsetY: 4 })
  }

  @Builder
  FooterSection() {
    Column({ space: 8 }) {
      Divider().strokeWidth(1).color('#E0E0E0')
      Text(`当前设备断点: ${this.currentBreakpoint.toUpperCase()}`)
        .fontSize(12)
        .fontColor('#007DFF')
      Text(`sm(手机) | md(折叠屏/小平板) | lg(平板/PC)`)
        .fontSize(10)
        .fontColor('#BBBBBB')
      Text('开发者: 25307023')
        .fontSize(12)
        .fontColor('#999999')
        .margin({ top: 4 })
      Text('DevEco Studio 5.0+ · HarmonyOS NEXT API 12+')
        .fontSize(10)
        .fontColor('#BBBBBB')
    }
    .width('100%')
    .padding({ top: 8, bottom: 16 })
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    GridRow({
      columns: { sm: 4, md: 8, lg: 12 },
      gutter: { x: { sm: 12, md: 20, lg: 24 } },
      breakpoints: {
        value: ['320vp', '600vp', '840vp'],
        reference: BreakpointsReference.WindowSize
      }
    }) {
      GridCol({ span: { sm: 4, md: 8, lg: 12 } }) {
        Column({ space: 16 }) {
          // 顶部标题
          this.HeaderSection()

          // 应用选择区 —— 响应式布局
          if (this.currentBreakpoint === 'sm') {
            // 手机：纵向排列两个应用卡片
            Column({ space: 16 }) {
              this.AppCard(
                '🔫',
                '枪战训练营',
                '射击小游戏，支持三关难度挑战和多设备流转继续游戏',
                ['游戏', '多端部署', '自由流转'],
                '#FFF3E0',
                'pages/ShootingGame'
              )
              this.AppCard(
                '📝',
                '协作便签',
                '跨设备便签应用，支持创建、编辑便签并流转到其他设备继续编辑',
                ['生产力', '多端部署', '自由流转'],
                '#E8F5E9',
                'pages/Notepad'
              )
            }
            .padding({ left: 16, right: 16 })
          } else {
            // 平板：两个应用卡片横向并排
            Row({ space: 20 }) {
              Column() {
                this.AppCard(
                  '🔫',
                  '枪战训练营',
                  '射击小游戏，支持三关难度挑战。使用 GridRow/GridCol 实现手机平板自适应布局，通过 distributedDataObject 实现游戏状态跨设备流转。',
                  ['游戏', '多端部署', '自由流转'],
                  '#FFF3E0',
                  'pages/ShootingGame'
                )
              }
              .layoutWeight(1)

              Column() {
                this.AppCard(
                  '📝',
                  '协作便签',
                  '跨设备便签应用，支持创建彩色便签、编辑内容。响应式栅格布局适配多端，分布式数据对象实现编辑状态无缝流转。',
                  ['生产力', '多端部署', '自由流转'],
                  '#E8F5E9',
                  'pages/Notepad'
                )
              }
              .layoutWeight(1)
            }
            .padding({ left: 24, right: 24 })
          }

          // 底部信息
          this.FooterSection()
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#FAFAFA')
        .justifyContent(FlexAlign.SpaceBetween)
      }
    }
    .width('100%')
    .height('100%')
    .onBreakpointChange((breakpoint: string) => {
      this.currentBreakpoint = breakpoint
    })
  }
}
