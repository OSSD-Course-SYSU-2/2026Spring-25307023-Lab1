import { AbilityConstant, ConfigurationConstant, UIAbility, Want, continuationManager } from '@kit.AbilityKit'
import { distributedDataObject } from '@kit.ArkData'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit'
import { GameState } from '../common/GameState'
import { GameStateManager } from '../common/GameStateManager'

const DOMAIN = 0x0000
const TAG = 'EntryAbility'

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
   * 自由流转：源端保存游戏状态到分布式数据对象
   */
  async onContinue(wantParam: Record<string, Object>): Promise<AbilityConstant.OnContinueResult> {
    const manager = GameStateManager.getInstance()
    const current = manager.getFromAppStorage()

    const source = new GameState(
      current?.page ?? 'game',
      current?.level ?? 1,
      current?.score ?? 0,
      current?.hp ?? 100,
      current?.targetX ?? 150,
      current?.targetY ?? 300,
      current?.timeLeft ?? 10
    )

    this.dObject = distributedDataObject.create(this.context, source)
    const dataSessionId: string = distributedDataObject.genSessionId()
    this.dObject.setSessionId(dataSessionId)
    wantParam['dataSessionId'] = dataSessionId

    try {
      await this.dObject.save(wantParam.targetDevice as string)
      hilog.info(DOMAIN, TAG, 'Game state saved for continuation, sessionId: %{public}s', dataSessionId)
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to save distributed object: %{public}s', JSON.stringify(err))
      return AbilityConstant.OnContinueResult.REJECT
    }

    return AbilityConstant.OnContinueResult.AGREE
  }

  private handleDistributedRestore(want: Want): void {
    const remoteSource = new GameState(undefined, undefined, undefined, undefined, undefined, undefined, undefined)
    this.dObject = distributedDataObject.create(this.context, remoteSource)

    let dataSessionId = ''
    if (want.parameters !== undefined) {
      dataSessionId = want.parameters['dataSessionId'] as string
    }

    this.dObject.on('status', (sessionId: string, networkId: string, status: 'online' | 'offline' | 'restored') => {
      hilog.info(DOMAIN, TAG, 'Distributed status: %{public}s', status)
      if (status === 'restored' && this.dObject) {
        const restored = new GameState(
          this.dObject['page'] as string,
          this.dObject['level'] as number,
          this.dObject['score'] as number,
          this.dObject['hp'] as number,
          this.dObject['targetX'] as number,
          this.dObject['targetY'] as number,
          this.dObject['timeLeft'] as number
        )
        GameStateManager.getInstance().notifyRestored(restored)
        hilog.info(DOMAIN, TAG, 'Game state restored: level=%{public}d score=%{public}d',
          restored.level ?? 0, restored.score ?? 0)
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
