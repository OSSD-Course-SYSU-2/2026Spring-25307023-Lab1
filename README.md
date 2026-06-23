# 2026Spring-25307023-Lab1

中山大学开源软件设计课程 Lab1 —— HarmonyOS 开源实践

## 项目简介

**枪战训练营** 是一款基于 HarmonyOS NEXT 的射击小游戏，实现了课程要求的两大核心能力：

1. **一次开发，多端部署** — 使用 `GridRow` / `GridCol` 响应式栅格布局，根据断点（sm / md / lg）自动适配手机与平板界面
2. **自由流转** — 使用分布式数据对象（`distributedDataObject`）实现游戏状态跨设备迁移

## 功能说明

### 一次开发，多端部署

- 使用 `GridRow` 配置断点：`320vp`（sm）、`600vp`（md）、`840vp`（lg）
- **手机（sm）**：竖屏单列布局，游戏区域与操作按钮纵向排列
- **平板（md/lg）**：双栏布局，左侧信息面板 + 右侧射击区域
- 通过 `onBreakpointChange` 监听断点变化，动态调整字体与控件尺寸

### 自由流转

- 在 `module.json5` 中配置 `continuable: true`
- 源端 `EntryAbility.onContinue()` 将游戏状态（关卡、分数、血量、目标位置等）保存至分布式数据对象
- 对端 `onCreate` / `onNewWant` 接收 `dataSessionId` 并恢复游戏状态
- 游戏界面提供「流转到其他设备」按钮，调用 `continuationManager.startDeviceManager()` 发起迁移

## 项目结构

```
entry/
├── src/main/
│   ├── ets/
│   │   ├── common/
│   │   │   ├── GameState.ets          # 游戏状态数据模型
│   │   │   └── GameStateManager.ets   # 全局状态管理
│   │   ├── entryability/
│   │   │   └── EntryAbility.ets       # 含 onContinue 流转逻辑
│   │   └── pages/
│   │       └── Index.ets              # 响应式游戏主界面
│   ├── module.json5                   # continuable + 分布式权限
│   └── resources/
└── build-profile.json5
```

## 运行环境

- DevEco Studio 5.0+
- HarmonyOS NEXT API 12+
- 两台已组网的 HarmonyOS 设备（用于测试自由流转）

## 测试步骤

### 多端部署测试

1. 在 DevEco Studio 中打开项目并编译运行
2. 选择 Phone 模拟器运行，观察竖屏单列布局
3. 选择 Tablet 模拟器运行，观察双栏布局与信息面板

### 自由流转测试

1. 两台设备登录同一华为账号并开启蓝牙/Wi-Fi
2. 在源设备开始游戏，点击「流转到其他设备」
3. 选择目标设备，确认游戏状态（关卡、分数、血量）正确恢复

## 开发者

学号：25307023

## 参考文档

- [一次开发，多端部署 - 页面布局场景](https://developer.huawei.com/consumer/cn/doc/best-practices/bpta-multi-device-page-layout)
- [HarmonyOS 自由流转开发指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/app-continuation)
