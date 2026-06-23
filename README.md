# 2026Spring-25307023-Lab1

中山大学开源软件设计课程 Lab1 —— HarmonyOS 开源实践

## 项目简介

本项目基于 **HarmonyOS NEXT (API 12+)** 实现了两个完整的 ArkTS 应用，分别展示了 HarmonyOS 核心能力：

| 应用 | 核心能力 |
|------|----------|
| 🔫 **枪战训练营** | 一次开发，多端部署 + 自由流转 |
| 📝 **协作便签** | 一次开发，多端部署 + 自由流转 |

两项应用均使用华为 **DevEco Studio 5.0+**（码道 dev Eco 套件）开发，并采用 **Stage 模型 + ArkTS** 架构。

---

## 两大核心能力

### 1. 一次开发，多端部署

使用 `GridRow` / `GridCol` 响应式栅格布局，通过断点系统（Breakpoint System）实现一套代码同时适配手机和平板：

```
断点阈值: 320vp(sm) ──── 600vp(md) ──── 840vp(lg)
           │                  │               │
         手机竖屏          折叠屏/小平板      平板/PC
         单列布局          自适应双栏        宽屏布局
```

**关键技术：**
- `GridRow` 的 `breakpoints` 配置自定义断点：`['320vp', '600vp', '840vp']`
- `GridCol` 的 `span` 按断点动态分配列数：`{ sm: 4, md: 8, lg: 12 }`
- `onBreakpointChange` 监听断点变化，动态调整字体、间距和布局策略
- 手机采用单列纵向布局，平板采用双栏/多栏布局

### 2. 自由流转

使用 `distributedDataObject` 分布式数据对象实现应用状态跨设备无缝迁移：

```
源设备                              目标设备
┌──────────────┐                   ┌──────────────┐
│ onContinue() │ ──dataSessionId──→ │ onCreate()   │
│ 保存状态到   │                   │ onNewWant()  │
│ dObject      │                   │ 接收并恢复   │
│              │                   │ 应用状态     │
│ save()       │                   │ setSessionId │
└──────────────┘                   └──────────────┘
```

**关键技术：**
- `module.json5` 中配置 `continuable: true` 和 `DISTRIBUTED_DATASYNC` 权限
- 源端 `onContinue()` 将应用数据封装为分布式对象并调用 `dObject.save()`
- 对端 `onCreate()` / `onNewWant()` 通过 `dataSessionId` 恢复数据
- `continuationManager.startDeviceManager()` 发起设备选择

---

## 应用一：🔫 枪战训练营

### 功能概述

一款包含三关难度的射击小游戏：
- **第一关 - 定点靶**：固定位置靶子，练习精准点击
- **第二关 - 闪现靶**：命中后随机更换位置
- **第三关 - 移动靶**：800ms 自动移动，考验反应速度

### 多端适配

| 设备 | 布局方式 |
|------|----------|
| 手机 (sm) | 竖屏单列：游戏区 + 操作按钮纵向排列 |
| 平板 (md/lg) | 双栏：左侧信息面板（关卡/血量/分数/时间）+ 右侧射击区域 |

### 流转场景

在手机上开始游戏 → 点击「流转到其他设备」→ 选择平板 → 平板自动恢复到当前关卡、分数、血量和剩余时间

### 核心文件

| 文件 | 作用 |
|------|------|
| `common/GameState.ets` | 游戏状态数据模型（关卡/分数/血量/目标坐标/时间） |
| `common/GameStateManager.ets` | 单例状态管理器，桥接 UI 与 Ability |
| `pages/ShootingGame.ets` | 游戏主界面，含响应式布局和全部游戏逻辑 |

---

## 应用二：📝 协作便签

### 功能概述

一款跨设备协作便签应用：
- **创建便签**：支持标题、内容、6 种颜色选择
- **编辑便签**：点击便签卡片进入编辑器
- **删除便签**：编辑器内提供删除按钮
- **首次使用**：预置两篇示例便签展示功能

### 多端适配

| 设备 | 布局方式 |
|------|----------|
| 手机 (sm) | 全屏：便签列表（2 列网格）⇄ 编辑器全屏切换 |
| 平板 (md/lg) | 分栏：左侧 32% 便签列表 + 右侧 68% 编辑器，同屏操作 |

### 流转场景

在手机上编辑一篇便签 → 点击「流转到其他设备」→ 选择平板 → 平板自动打开同一篇便签，保持标题、内容和颜色状态

### 核心文件

| 文件 | 作用 |
|------|------|
| `common/NotepadState.ets` | 便签数据模型（NoteItem / NotepadState / 颜色常量） |
| `common/NotepadManager.ets` | 单例状态管理器 |
| `pages/Notepad.ets` | 便签主界面，含响应式布局和全部编辑逻辑 |

---

## 项目结构

```
25307023-Lab1/
├── entry/
│   ├── src/main/
│   │   ├── ets/
│   │   │   ├── common/
│   │   │   │   ├── GameState.ets          # 射击游戏数据模型
│   │   │   │   ├── GameStateManager.ets   # 射击游戏状态管理
│   │   │   │   ├── NotepadState.ets       # 便签数据模型
│   │   │   │   └── NotepadManager.ets     # 便签状态管理
│   │   │   ├── entryability/
│   │   │   │   └── EntryAbility.ets       # 入口 Ability（含 onContinue 双应用流转逻辑）
│   │   │   ├── entrybackupability/
│   │   │   │   └── EntryBackupAbility.ets # 备份扩展 Ability
│   │   │   └── pages/
│   │   │       ├── Index.ets              # 启动器首页（双应用选择）
│   │   │       ├── ShootingGame.ets       # 枪战训练营游戏界面
│   │   │       └── Notepad.ets            # 协作便签界面
│   │   ├── module.json5                   # 模块配置（continuable + 分布式权限）
│   │   └── resources/
│   │       ├── base/
│   │       │   ├── element/
│   │       │   │   ├── color.json         # 颜色资源
│   │       │   │   └── string.json        # 字符串资源
│   │       │   ├── media/                 # 图标与图片资源
│   │       │   └── profile/
│   │       │       ├── backup_config.json
│   │       │       └── main_pages.json    # 页面路由配置
│   │       └── dark/element/
│   │           └── color.json             # 深色模式颜色
│   ├── build-profile.json5                # 模块构建配置
│   ├── hvigorfile.ts                      # Hvigor 构建脚本
│   ├── obfuscation-rules.txt              # 代码混淆规则
│   └── oh-package.json5                   # 模块依赖声明
├── .gitignore
└── README.md
```

---

## 运行环境

| 组件 | 要求 |
|------|------|
| IDE | DevEco Studio 5.0+ |
| SDK | HarmonyOS NEXT API 12+ |
| 设备 | 支持 Phone / Tablet / 2in1 模拟器或真机 |
| 流转测试 | 两台已组网的 HarmonyOS 设备（同华为账号、同 Wi-Fi、蓝牙开启） |

---

## 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/OSSD-Course-SYSU-2/2026Spring-25307023-Lab1.git
```

### 2. 在 DevEco Studio 中打开

1. 启动 DevEco Studio 5.0+
2. 选择 `File → Open`
3. 选择项目根目录
4. 等待 Gradle/Hvigor 同步完成

### 3. 编译运行

1. 连接 HarmonyOS 设备或启动模拟器
2. 点击工具栏 `Run` 按钮（或按 `Shift+F10`）
3. 应用安装后自动启动，进入应用选择首页

### 4. 在模拟器中切换设备

1. `Tools → Device Manager`
2. 分别创建 Phone 和 Tablet 模拟器
3. 在两个模拟器中分别运行，观察不同的布局效果

---

## 测试步骤

### 多端部署测试

| 步骤 | 操作 | 预期结果 |
|------|------|----------|
| 1 | 在 DevEco Studio 中打开项目并编译运行 | 应用启动，显示双应用选择首页 |
| 2 | 选择 Phone 模拟器，点击「枪战训练营」 | 竖屏单列布局，关卡按钮纵向排列 |
| 3 | 进入游戏后观察 | 游戏区在上，操作按钮在下 |
| 4 | 切换到 Tablet 模拟器，再次进入游戏 | 双栏布局，左侧信息面板 + 右侧射击区 |
| 5 | 重复测试「协作便签」应用 | Phone 全屏切换，Tablet 左右分栏 |
| 6 | 首页观察断点信息 | 不同设备显示不同的 sm/md/lg 断点 |

### 自由流转测试

| 步骤 | 操作 | 预期结果 |
|------|------|----------|
| 1 | 两台设备登录同一华为账号并开启蓝牙/Wi-Fi | 设备在同一局域网 |
| 2 | 在源设备进入枪战训练营，开始游戏（获取一定分数） | 游戏正常运行 |
| 3 | 点击「流转到其他设备」按钮 | 弹出设备选择列表 |
| 4 | 选择目标设备 | 目标设备自动启动应用，恢复游戏状态 |
| 5 | 验证关卡、分数、血量正确恢复 | 数据与源设备一致 |
| 6 | 在源设备编辑一篇便签 | 输入标题和内容 |
| 7 | 点击「流转到其他设备」 | 目标设备恢复便签编辑状态 |
| 8 | 验证便签标题、内容、颜色正确恢复 | 与源设备一致 |

---

## 技术实现详解

### 响应式栅格布局

```typescript
// 断点配置位于每个页面的 build() 方法中
GridRow({
  columns: { sm: 4, md: 8, lg: 12 },          // 不同断点的列数
  breakpoints: {
    value: ['320vp', '600vp', '840vp'],         // 自定义断点阈值
    reference: BreakpointsReference.WindowSize   // 相对于窗口大小
  }
}) {
  GridCol({ span: { sm: 4, md: 8, lg: 12 } }) {
    // 内容区域 —— 自动适配列宽
  }
}
.onBreakpointChange((breakpoint: string) => {
  this.currentBreakpoint = breakpoint  // 监听断点变化，驱动 UI 切换
})
```

### 分布式数据对象流转

```typescript
// 源端（onContinue）
async onContinue(wantParam: Record<string, Object>): Promise<AbilityConstant.OnContinueResult> {
  const payload = { gameState: {...}, notepadState: {...} }
  this.dObject = distributedDataObject.create(this.context, payload)
  const sessionId = distributedDataObject.genSessionId()
  this.dObject.setSessionId(sessionId)
  wantParam['dataSessionId'] = sessionId
  await this.dObject.save(wantParam.targetDevice as string)
  return AbilityConstant.OnContinueResult.AGREE
}

// 对端（handleDistributedRestore）
this.dObject.on('status', (sessionId, networkId, status) => {
  if (status === 'restored') {
    // 从 this.dObject 中读取恢复的数据并通知 UI 更新
  }
})
this.dObject.setSessionId(dataSessionId)
```

### 模块配置关键项

```json5
// module.json5
{
  "abilities": [{ "continuable": true }],      // 开启接续能力
  "deviceTypes": ["phone", "tablet", "2in1"],  // 声明多设备支持
  "requestPermissions": [{
    "name": "ohos.permission.DISTRIBUTED_DATASYNC"  // 分布式数据同步权限
  }]
}
```

---

## 开发者

- **学号**：25307023
- **课程**：中山大学 开源软件设计 2026Spring
- **开发工具**：华为 DevEco Studio（码道 dev Eco）

## 许可证

MIT License

## 参考文档

- [一次开发，多端部署 - 页面布局场景](https://developer.huawei.com/consumer/cn/doc/best-practices/bpta-multi-device-page-layout)
- [HarmonyOS 自由流转开发指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/app-continuation)
- [栅格布局 GridRow/GridCol](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-container-gridrow)
- [分布式数据对象](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-data-distributedobject)
- [应用接续开发指导](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-continuation-dev)
