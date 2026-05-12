@Entry
@Component
struct AdvancedShootingGame {
  @State page: string = 'home';
  @State level: number = 1;
  @State score: number = 0;
  @State hp: number = 100;
  @State targetX: number = 150;
  @State targetY: number = 300;
  @State timeLeft: number = 10; // 新增：剩余时间

  private timer: number | null = null;
  private countdownTimer: number | null = null; // 新增：倒计时定时器

  // 核心逻辑：确保血量扣除和状态判断准确
  hit(damage: number): void {
    if (this.hp <= 0) return;

    this.hp -= damage;
    this.score += damage;

    if (this.hp <= 0) {
      this.hp = 0;
      this.stopAllTimers(); // 停止所有逻辑
      this.page = 'result'; // 击杀敌人即判定关卡通过
    } else {
      if (this.level === 2) {
        this.moveEnemy();
      }
    }
  }

  moveEnemy(): void {
    this.targetX = Math.floor(Math.random() * 200) + 50;
    this.targetY = Math.floor(Math.random() * 400) + 100;
  }

  // 停止所有计时器
  stopAllTimers(): void {
    if (this.timer !== null) {
      clearInterval(this.timer);
      this.timer = null;
    }
    if (this.countdownTimer !== null) {
      clearInterval(this.countdownTimer);
      this.countdownTimer = null;
    }
  }

  startGame(lv: number): void {
    this.level = lv;
    this.hp = 100;
    this.score = 0;
    this.timeLeft = 10; // 重置时间
    this.page = 'game';
    this.moveEnemy();

    // 敌人移动逻辑（第三关）
    if (this.level === 3) {
      this.timer = setInterval((): void => { this.moveEnemy(); }, 800);
    }

    // 倒计时逻辑
    this.countdownTimer = setInterval((): void => {
      this.timeLeft -= 1;
      if (this.timeLeft <= 0) {
        this.stopAllTimers();
        this.page = 'result'; // 时间到，结算
      }
    }, 1000);
  }

  build() {
    Stack() {
      if (this.page === 'home') {
        Column({ space: 20 }) {
          Text("枪战训练营").fontSize(40).fontWeight(FontWeight.Bold)
          Button("第一关：定点靶").width(200).onClick(() => this.startGame(1))
          Button("第二关：闪现靶").width(200).onClick(() => this.startGame(2))
          Button("第三关：移动靶").width(200).onClick(() => this.startGame(3))
        }
      }

      if (this.page === 'game') {
        Column() {
          // 显示时间
          Text(`关卡: ${this.level} | 时间: ${this.timeLeft}s | 血量: ${this.hp}`).fontSize(20).margin(10)
          Text(`分数: ${this.score}`).fontSize(20).margin(10)

          Stack() {
            Rect({ width: 40, height: 40 }).radius(20).fill(Color.Red).position({ x: 5, y: 0 }).onClick(() => this.hit(100))
            Rect({ width: 50, height: 70 }).fill(Color.Blue).position({ x: 0, y: 40 }).onClick(() => this.hit(50))
            Rect({ width: 80, height: 20 }).fill(Color.Gray).position({ x: -15, y: 50 }).onClick(() => this.hit(20))
          }
          .width(50).height(120)
          .position({ x: this.targetX, y: this.targetY })
          .animation({ duration: 300 })

          Button("返回首页").margin({ top: 500 }).onClick(() => {
            this.stopAllTimers();
            this.page = 'home';
          })
        }.width('100%').height('100%')
      }

      if (this.page === 'result') {
        Column({ space: 20 }) {
          Text(this.hp <= 0 ? "目标击杀！" : "时间到，任务失败").fontSize(30)
          Text(`最终得分: ${this.score}`).fontSize(20)
          Button("返回首页").onClick(() => { this.page = 'home'; })
        }
      }
    }
    .width('100%').height('100%').backgroundColor('#f0f0f0')
  }
}