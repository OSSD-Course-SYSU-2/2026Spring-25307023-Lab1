import { AbilityConstant, ConfigurationConstant, UIAbility, Want, continuationManager } from '@kit.AbilityKit'
import { distributedDataObject } from '@kit.ArkData'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit'
import { GameState } from '../common/GameState'
import { GameStateManager } from '../common/GameStateManager'
import { NotepadState } from '../common/NotepadState'
import { NotepadManager } from '../common/NotepadManager'

const DOMAIN = 0x0000
const TAG = 'EntryAbility'

/**
 * 当前活跃的应用类型，用于判断流转时保存/恢复哪个应用的状态
 */
enum ActiveApp {
  NONE = 'none',
  SHOOTING_GAME = 'shootingGame',
  NOTEPAD = 'notepad'
}

export default class EntryAbility extends UIAbility {
  private dObject?: distributedDataObject.DataObject
  private continuationToken: number = -1

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to set colorMode: %{public}s', JSON.stringify(err))
    }

    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      this.handleDistributedRestore(want)
    }

    this.registerContinuation()
    hilog.info(DOMAIN, TAG, 'Ability onCreate')
  }

  onDestroy(): void {
    if (this.continuationToken !== -1) {
      continuationManager.unregister(this.continuationToken).catch(() => {})
    }
    hilog.info(DOMAIN, TAG, 'Ability onDestroy')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, TAG, 'Ability onWindowStageCreate')
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'Failed to load content: %{public}s', JSON.stringify(err))
        return
      }
      hilog.info(DOMAIN, TAG, 'Succeeded in loading content')
    })
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, TAG, 'Ability onWindowStageDestroy')
  }

  onForeground(): void {
    hilog.info(DOMAIN, TAG, 'Ability onForeground')
  }

  onBackground(): void {
    hilog.info(DOMAIN, TAG, 'Ability onBackground')
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      this.handleDistributedRestore(want)
    }
  }

  /**
   * 自由流转：源端保存当前活跃应用的状态到分布式数据对象
   * 同时保存射击游戏和便签两个应用的状态，对端根据 activeApp 字段恢复
   */
  async onContinue(wantParam: Record<string, Object>): Promise<AbilityConstant.OnContinueResult> {
    const gameManager = GameStateManager.getInstance()
    const notepadManager = NotepadManager.getInstance()
    const gameCurrent = gameManager.getFromAppStorage()
    const notepadCurrent = notepadManager.getFromAppStorage()

    // 保存射击游戏状态
    const gameState = new GameState(
      gameCurrent?.page ?? 'home',
      gameCurrent?.level ?? 1,
      gameCurrent?.score ?? 0,
      gameCurrent?.hp ?? 100,
      gameCurrent?.targetX ?? 150,
      gameCurrent?.targetY ?? 300,
      gameCurrent?.timeLeft ?? 10
    )

    // 保存便签状态
    const notepadState = new NotepadState(
      notepadCurrent?.notes ?? [],
      notepadCurrent?.currentNoteIndex ?? -1,
      notepadCurrent?.scrollOffset ?? 0
    )

    // 合并为一个流转状态对象
    const continuationPayload = {
      gameState: gameState,
      notepadState: notepadState
    }

    this.dObject = distributedDataObject.create(this.context, continuationPayload)
    const dataSessionId: string = distributedDataObject.genSessionId()
    this.dObject.setSessionId(dataSessionId)
    wantParam['dataSessionId'] = dataSessionId

    try {
      await this.dObject.save(wantParam.targetDevice as string)
      hilog.info(DOMAIN, TAG, 'Continuation state saved, sessionId: %{public}s', dataSessionId)
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to save distributed object: %{public}s', JSON.stringify(err))
      return AbilityConstant.OnContinueResult.REJECT
    }

    return AbilityConstant.OnContinueResult.AGREE
  }

  /**
   * 对端恢复：从分布式数据对象恢复两个应用的状态
   */
  private handleDistributedRestore(want: Want): void {
    const remoteSource = {}
    this.dObject = distributedDataObject.create(this.context, remoteSource)

    let dataSessionId = ''
    if (want.parameters !== undefined) {
      dataSessionId = want.parameters['dataSessionId'] as string
    }

    this.dObject.on('status', (sessionId: string, networkId: string, status: 'online' | 'offline' | 'restored') => {
      hilog.info(DOMAIN, TAG, 'Distributed status: %{public}s', status)
      if (status === 'restored' && this.dObject) {
        // 恢复射击游戏状态
        const gameState = new GameState(
          this.dObject['gameState']?.['page'] as string,
          this.dObject['gameState']?.['level'] as number,
          this.dObject['gameState']?.['score'] as number,
          this.dObject['gameState']?.['hp'] as number,
          this.dObject['gameState']?.['targetX'] as number,
          this.dObject['gameState']?.['targetY'] as number,
          this.dObject['gameState']?.['timeLeft'] as number
        )
        GameStateManager.getInstance().notifyRestored(gameState)
        hilog.info(DOMAIN, TAG, 'Game state restored: level=%{public}d score=%{public}d',
          gameState.level ?? 0, gameState.score ?? 0)

        // 恢复便签状态
        const notepadState = new NotepadState(
          this.dObject['notepadState']?.['notes'] as [],
          this.dObject['notepadState']?.['currentNoteIndex'] as number,
          this.dObject['notepadState']?.['scrollOffset'] as number
        )
        NotepadManager.getInstance().notifyRestored(notepadState)
        hilog.info(DOMAIN, TAG, 'Notepad state restored: notes=%{public}d currentIndex=%{public}d',
          notepadState.notes.length, notepadState.currentNoteIndex)
      }
    })

    this.dObject.setSessionId(dataSessionId)
  }

  private registerContinuation(): void {
    continuationManager.register({ deviceType: ['phone', 'tablet', '2in1'] })
      .then((token: number) => {
        this.continuationToken = token
        AppStorage.setOrCreate('continuationToken', token)
        hilog.info(DOMAIN, TAG, 'Continuation registered, token: %{public}d', token)
      })
      .catch((err: BusinessError) => {
        hilog.error(DOMAIN, TAG, 'Continuation register failed: %{public}s', JSON.stringify(err))
      })
  }
}
