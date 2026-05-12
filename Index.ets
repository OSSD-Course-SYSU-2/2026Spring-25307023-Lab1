import promptAction from '@ohos.promptAction';

interface CellPos {
  r: number;
  c: number;
}

@Entry
@Component
struct Game2048 {
  @State board: number[][] = [
    [0, 0, 0, 0],
    [0, 2, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 2]
  ];
  @State score: number = 0;

  getColor(value: number): string {
    if (value === 0) return '#CCC0B3';
    if (value === 2) return '#EEE4DA';
    if (value === 4) return '#EDE0C8';
    if (value === 8) return '#F2B179';
    if (value === 16) return '#F59563';
    if (value === 32) return '#F67C5F';
    if (value === 64) return '#F65E3B';
    if (value === 128) return '#EDCF72';
    if (value === 256) return '#EDCC61';
    if (value === 512) return '#EDC850';
    if (value === 1024) return '#EDC53F';
    if (value === 2048) return '#EDC22E';
    return '#3C3A32';
  }

  moveLeft() {
    let newBoard: number[][] = this.board.map((row: number[]) => {
      let filtered = row.filter(v => v !== 0);
      for (let i = 0; i < filtered.length - 1; i++) {
        if (filtered[i] === filtered[i + 1]) {
          filtered[i] *= 2;
          this.score += filtered[i];
          filtered.splice(i + 1, 1);
        }
      }
      while (filtered.length < 4) {
        filtered.push(0);
      }
      return filtered;
    });
    this.updateBoard(newBoard);
  }

  addRandom() {
    let emptyCells: CellPos[] = [];
    for (let r = 0; r < 4; r++) {
      for (let c = 0; c < 4; c++) {
        if (this.board[r][c] === 0) {
          emptyCells.push({ r: r, c: c });
        }
      }
    }
    if (emptyCells.length > 0) {
      let index = Math.floor(Math.random() * emptyCells.length);
      let cell = emptyCells[index];
      this.board[cell.r][cell.c] = Math.random() > 0.1 ? 2 : 4;
    }
  }

  updateBoard(newBoard: number[][]) {
    if (JSON.stringify(newBoard) !== JSON.stringify(this.board)) {
      this.board = newBoard;
      this.addRandom();
    }
  }

  build() {
    Column() {
      Text('2048 鸿蒙版')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40, bottom: 20 })

      Text(`得分: ${this.score}`)
        .fontSize(24)
        .margin({ bottom: 20 })

      Column({ space: 10 }) {
        ForEach(this.board, (row: number[]) => {
          Row({ space: 10 }) {
            ForEach(row, (cell: number) => {
              Text(cell === 0 ? '' : cell.toString())
                .width(70)
                .height(70)
                .backgroundColor(this.getColor(cell))
                .fontColor(cell <= 4 ? '#776E65' : '#F9F6F2')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .textAlign(TextAlign.Center)
                .borderRadius(5)
            })
          }
        })
      }
      .padding(10)
      .backgroundColor('#BBADA0')
      .borderRadius(10)

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
        Button('上').onClick(() => this.moveUp()).margin(5).width(80)
        Button('下').onClick(() => this.moveDown()).margin(5).width(80)
        Button('左').onClick(() => this.moveLeft()).margin(5).width(80)
        Button('右').onClick(() => this.moveRight()).margin(5).width(80)
      }
      .margin({ top: 30 })
      .width('100%')

      Button('重新开始')
        .margin({ top: 20 })
        .backgroundColor(Color.Orange)
        .onClick(() => {
          this.board = [[0, 0, 0, 0], [0, 2, 0, 0], [0, 0, 0, 0], [0, 0, 0, 2]];
          this.score = 0;
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAF8EF')
  }

  moveRight() {
    this.board = this.board.map((r: number[]) => r.slice().reverse());
    this.moveLeft();
    this.board = this.board.map((r: number[]) => r.slice().reverse());
  }

  // 此处已调换逻辑
  moveUp() {
    this.rotateBoard();
    this.rotateBoard();
    this.rotateBoard();
    this.moveLeft();
    this.rotateBoard();
  }

  // 此处已调换逻辑
  moveDown() {
    this.rotateBoard();
    this.moveLeft();
    this.rotateBoard();
    this.rotateBoard();
    this.rotateBoard();
  }

  rotateBoard() {
    let newBoard: number[][] = [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]];
    for (let r = 0; r < 4; r++) {
      for (let c = 0; c < 4; c++) {
        newBoard[c][3 - r] = this.board[r][c];
      }
    }
    this.board = newBoard;
  }
}
