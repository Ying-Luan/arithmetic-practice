import ArithmeticService from '../service/ArithmeticService'

@Entry
@Component
struct Index {
  @State service: ArithmeticService = new ArithmeticService();

  @Builder
  Header() {
    Text('小学生四则运算练习')
      .fontSize(32)
      .fontWeight(FontWeight.Bold)
      .margin({ top: 40, bottom: 20 })
      .fontColor(Color.Black)
  }

  @Builder
  ScoreBoard() {
    Row() {
      Text(`当前得分：${this.service.currentScore}`)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .fontColor(Color.Brown)
      Text(`历史最高：${this.service.highScore}`)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.End)
        .fontColor(Color.Orange)
    }
    .width('90%')
    .padding(15)
    .margin({ bottom: 25 })
    .borderRadius(12)
    .backgroundColor(Color.White)
    .shadow({
      radius: 8,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 4
    })
  }

  /**
   * 题目显示区域
   */
  @Builder
  QuestionArea() {
    Text(this.service.questionExpression)
      .fontSize(30)
      .fontWeight(FontWeight.Bold)
      .textAlign(TextAlign.Center)
      .padding(20)
      .margin({ bottom: 35 })
      .width('90%')
      .height(100)
      .borderRadius(16)
      .backgroundColor(Color.White)
      .fontColor(Color.Black)
      .shadow({
        radius: 10,
        color: '#30000000',
        offsetX: 0,
        offsetY: 5
      })
  }

  /**
   * 答案输入区域
   */
  @Builder
  InputArea() {
    TextInput({ placeholder: '请输入你的答案', text: this.service.userInput })
      .type(InputType.Number)
      .fontSize(24)
      .width('80%')
      .height(55)
      .margin({ bottom: 30 })
      .backgroundColor(Color.White)
      .borderRadius(8)
      .enabled(this.service.isGameActive)
      .onChange((value) => {
        this.service.handleInput(value); // 调用Service中的处理方法
      })
      .textAlign(TextAlign.Center)
      .fontWeight(FontWeight.Medium)
      .fontColor(Color.Black)
  }

  @Builder
  Buttons() {
    Row() {
      // 开始按钮
      Button('开始')
        .type(ButtonType.Capsule)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .backgroundColor(this.service.isGameActive ? Color.Grey : '#4CAF50')
        .onClick(() => {
          this.service.handleStart();
        })
        .layoutWeight(1)
        .margin({ right: 10 })
        .enabled(!this.service.isGameActive)

      // 提交答案按钮
      Button('提交')
        .type(ButtonType.Capsule)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .backgroundColor(this.service.isGameActive ? '#2196F3' : Color.Grey)
        .onClick(() => {
          this.service.handleSubmit();
        })
        .layoutWeight(1)
        .margin({ right: 10 })
        .enabled(this.service.isGameActive)

      // 停止按钮
      Button('停止')
        .type(ButtonType.Capsule)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .backgroundColor(this.service.isGameActive ? '#F44336' : Color.Grey)
        .onClick(() => {
          this.service.handleStop();
        })
        .layoutWeight(1)
        .enabled(this.service.isGameActive)
    }
    .width('90%')
    .padding({ top: 10, bottom: 10 })
  }

  private get messageFontColor(): Color | string {
    const message = this.service.gameOverMessage;
    if (message.includes('正确')) {
      return '#4CAF50';
    } else if (message.includes('错误')) {
      return '#F44336';
    } else {
      return Color.Black;
    }
  }

  @Builder
  MessageArea() {
    Text(this.service.gameOverMessage)
      .fontSize(20)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.messageFontColor)
      .textAlign(TextAlign.Center)
      .padding(15)
      .margin({ top: 30 })
      .width('90%')
      .borderRadius(8)
      .backgroundColor(Color.White)
      .opacity(this.service.gameOverMessage ? 1 : 0)
      .transition({ opacity: 300 })
  }

  build() {
    Column() {
      this.Header()
      this.ScoreBoard()
      this.QuestionArea()
      this.InputArea()
      this.Buttons()
      this.MessageArea()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EEEEEE')
  }
}