if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface AdvancedShootingGame_Params {
    page?: string;
    level?: number;
    score?: number;
    hp?: number;
    targetX?: number;
    targetY?: number;
    timeLeft?: number;
    timer?: number | null;
    countdownTimer?: number | null;
}
class AdvancedShootingGame extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__page = new ObservedPropertySimplePU('home', this, "page");
        this.__level = new ObservedPropertySimplePU(1, this, "level");
        this.__score = new ObservedPropertySimplePU(0, this, "score");
        this.__hp = new ObservedPropertySimplePU(100, this, "hp");
        this.__targetX = new ObservedPropertySimplePU(150, this, "targetX");
        this.__targetY = new ObservedPropertySimplePU(300, this, "targetY");
        this.__timeLeft = new ObservedPropertySimplePU(10, this, "timeLeft");
        this.timer = null;
        this.countdownTimer = null;
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: AdvancedShootingGame_Params) {
        if (params.page !== undefined) {
            this.page = params.page;
        }
        if (params.level !== undefined) {
            this.level = params.level;
        }
        if (params.score !== undefined) {
            this.score = params.score;
        }
        if (params.hp !== undefined) {
            this.hp = params.hp;
        }
        if (params.targetX !== undefined) {
            this.targetX = params.targetX;
        }
        if (params.targetY !== undefined) {
            this.targetY = params.targetY;
        }
        if (params.timeLeft !== undefined) {
            this.timeLeft = params.timeLeft;
        }
        if (params.timer !== undefined) {
            this.timer = params.timer;
        }
        if (params.countdownTimer !== undefined) {
            this.countdownTimer = params.countdownTimer;
        }
    }
    updateStateVars(params: AdvancedShootingGame_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__page.purgeDependencyOnElmtId(rmElmtId);
        this.__level.purgeDependencyOnElmtId(rmElmtId);
        this.__score.purgeDependencyOnElmtId(rmElmtId);
        this.__hp.purgeDependencyOnElmtId(rmElmtId);
        this.__targetX.purgeDependencyOnElmtId(rmElmtId);
        this.__targetY.purgeDependencyOnElmtId(rmElmtId);
        this.__timeLeft.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__page.aboutToBeDeleted();
        this.__level.aboutToBeDeleted();
        this.__score.aboutToBeDeleted();
        this.__hp.aboutToBeDeleted();
        this.__targetX.aboutToBeDeleted();
        this.__targetY.aboutToBeDeleted();
        this.__timeLeft.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __page: ObservedPropertySimplePU<string>;
    get page() {
        return this.__page.get();
    }
    set page(newValue: string) {
        this.__page.set(newValue);
    }
    private __level: ObservedPropertySimplePU<number>;
    get level() {
        return this.__level.get();
    }
    set level(newValue: number) {
        this.__level.set(newValue);
    }
    private __score: ObservedPropertySimplePU<number>;
    get score() {
        return this.__score.get();
    }
    set score(newValue: number) {
        this.__score.set(newValue);
    }
    private __hp: ObservedPropertySimplePU<number>;
    get hp() {
        return this.__hp.get();
    }
    set hp(newValue: number) {
        this.__hp.set(newValue);
    }
    private __targetX: ObservedPropertySimplePU<number>;
    get targetX() {
        return this.__targetX.get();
    }
    set targetX(newValue: number) {
        this.__targetX.set(newValue);
    }
    private __targetY: ObservedPropertySimplePU<number>;
    get targetY() {
        return this.__targetY.get();
    }
    set targetY(newValue: number) {
        this.__targetY.set(newValue);
    }
    private __timeLeft: ObservedPropertySimplePU<number>; // 新增：剩余时间
    get timeLeft() {
        return this.__timeLeft.get();
    }
    set timeLeft(newValue: number) {
        this.__timeLeft.set(newValue);
    }
    private timer: number | null;
    private countdownTimer: number | null; // 新增：倒计时定时器
    // 核心逻辑：确保血量扣除和状态判断准确
    hit(damage: number): void {
        if (this.hp <= 0)
            return;
        this.hp -= damage;
        this.score += damage;
        if (this.hp <= 0) {
            this.hp = 0;
            this.stopAllTimers(); // 停止所有逻辑
            this.page = 'result'; // 击杀敌人即判定关卡通过
        }
        else {
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
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Stack.create();
            Stack.width('100%');
            Stack.height('100%');
            Stack.backgroundColor('#f0f0f0');
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.page === 'home') {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create({ space: 20 });
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create("枪战训练营");
                        Text.fontSize(40);
                        Text.fontWeight(FontWeight.Bold);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel("第一关：定点靶");
                        Button.width(200);
                        Button.onClick(() => this.startGame(1));
                    }, Button);
                    Button.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel("第二关：闪现靶");
                        Button.width(200);
                        Button.onClick(() => this.startGame(2));
                    }, Button);
                    Button.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel("第三关：移动靶");
                        Button.width(200);
                        Button.onClick(() => this.startGame(3));
                    }, Button);
                    Button.pop();
                    Column.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.page === 'game') {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.width('100%');
                        Column.height('100%');
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 显示时间
                        Text.create(`关卡: ${this.level} | 时间: ${this.timeLeft}s | 血量: ${this.hp}`);
                        // 显示时间
                        Text.fontSize(20);
                        // 显示时间
                        Text.margin(10);
                    }, Text);
                    // 显示时间
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(`分数: ${this.score}`);
                        Text.fontSize(20);
                        Text.margin(10);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Stack.create();
                        Context.animation({ duration: 300 });
                        Stack.width(50);
                        Stack.height(120);
                        Stack.position({ x: this.targetX, y: this.targetY });
                        Context.animation(null);
                    }, Stack);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Rect.create({ width: 40, height: 40 });
                        Rect.radius(20);
                        Rect.fill(Color.Red);
                        Rect.position({ x: 5, y: 0 });
                        Rect.onClick(() => this.hit(100));
                    }, Rect);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Rect.create({ width: 50, height: 70 });
                        Rect.fill(Color.Blue);
                        Rect.position({ x: 0, y: 40 });
                        Rect.onClick(() => this.hit(50));
                    }, Rect);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Rect.create({ width: 80, height: 20 });
                        Rect.fill(Color.Gray);
                        Rect.position({ x: -15, y: 50 });
                        Rect.onClick(() => this.hit(20));
                    }, Rect);
                    Stack.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel("返回首页");
                        Button.margin({ top: 500 });
                        Button.onClick(() => {
                            this.stopAllTimers();
                            this.page = 'home';
                        });
                    }, Button);
                    Button.pop();
                    Column.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.page === 'result') {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create({ space: 20 });
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.hp <= 0 ? "目标击杀！" : "时间到，任务失败");
                        Text.fontSize(30);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(`最终得分: ${this.score}`);
                        Text.fontSize(20);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel("返回首页");
                        Button.onClick(() => { this.page = 'home'; });
                    }, Button);
                    Button.pop();
                    Column.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        Stack.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "AdvancedShootingGame";
    }
}
registerNamedRoute(() => new AdvancedShootingGame(undefined, {}), "", { bundleName: "com.example.myapplication_gungame", moduleName: "entry", pagePath: "pages/Index", pageFullPath: "entry/src/main/ets/pages/Index", integratedHsp: "false", moduleType: "followWithHap" });
