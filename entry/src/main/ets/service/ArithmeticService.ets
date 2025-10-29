import parser from './Parser';

/**
 * 消息管理
 */
class MessageManager {
  readonly INITIAL = () => "点击开始按钮以练习";
  readonly CORRECT = () => "✅ 回答正确！继续努力！";
  readonly WRONG = (correctAnswer: number) => `❌ 答案错误！正确答案是 ${correctAnswer}。`;
  readonly INVALID_INPUT = () => "⚠️ 请输入有效数字答案！";
  readonly RESTART = () => "点击开始重新练习";
  readonly END_GAME_BASE = (currentScore: number) => `练习结束，本次得分：${currentScore} 分。`;
  readonly HIGH_SCORE_BREAK = (highScore: number) => `\n恭喜，创造了新的历史最高分：${highScore} 分。`
  readonly HIGH_SCORE_KEPT = (highScore: number) => `\n历史最高分：${highScore} 分。`
}

const MESSAGE = new MessageManager();

type operator = '' | '+' | '-' | '*';

@Observed
class ArithmeticService {
  isGameActive: boolean = false;
  currentScore: number = 0;
  highScore: number = 0;
  questionExpression: string = MESSAGE.INITIAL();
  correctAnswer: number = 0;
  userInput: string = "";
  gameOverMessage: string = "";
  // 题目配置
  private operators: operator[] = ['+', '-', '*'];
  private minOps: number = 3;
  private maxOps: number = 5;
  private minNum: number = 0;
  private maxNum: number = 100;
  private maxAddSubNum: number = 30;
  private minMultiply: number = 2;
  private maxMultiply: number = 9;

  loadHighScore() {
    this.highScore = 0;
  }

  private getRandomNumber(min: number, max: number): number {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }

  private getRandomOperator(ops: operator[]): operator {
    return ops[this.getRandomNumber(0, ops.length - 1)];
  }

  /**
   * 生成问题
   */
  generateQuestion(): void {
    let expression: string = "";
    let currentValue: number = this.getRandomNumber(this.minNum, this.maxNum);
    expression += currentValue.toString()
    const opCount = this.getRandomNumber(this.minOps, this.maxOps);
    let usedOps: Set<operator> = new Set();
    let multiplyUsed: boolean = false;

    for (let i = 0; i < opCount; i++) {
      let op: operator = '';
      let nextNum: number = 0;
      let success: boolean = false;
      let availableOps: operator[] = this.operators;
      if (multiplyUsed) {
        availableOps = availableOps.filter(o => o !== '*');
      }

      const currentAvailableOps = availableOps.filter(o => !usedOps.has(o));
      while (!success) {
        if (availableOps.length > 0 && usedOps.size < 2 && i > 0) {
          op = this.getRandomOperator(currentAvailableOps);
        } else {
          op = this.getRandomOperator(availableOps);
        }

        // 限制第二操作数的范围
        if (op === '*') {
          nextNum = this.getRandomNumber(this.minMultiply, this.maxMultiply);
        } else {
          nextNum = this.getRandomNumber(this.minNum, this.maxAddSubNum);
        }

        // 不允许出现负数
        if (op === '-') {
          if (currentValue >= nextNum) {
            success = true;
          }
        } else {
          success = true;
        }
      }

      if (success) {
        expression += ` ${op} ${nextNum}`;
        usedOps.add(op);
        if (op === '*') {
          multiplyUsed = true;
        }
      }

      try {
        currentValue = parser(expression);
        if (currentValue >= 100 || currentValue < 0) {
          return this.generateQuestion();
        }
      } catch (e) {
        return this.generateQuestion();
      }
    }

    // 设置状态
    this.questionExpression = expression + " = ?";
    this.correctAnswer = parser(expression);
    this.userInput = "";
  }

  handleStart(): void {
    this.currentScore = 0;
    this.isGameActive = true;
    this.gameOverMessage = "";
    this.generateQuestion();
  }

  handleStop(): void {
    if (this.isGameActive) {
      this.endGame(false);
    }
  }

  handleInput(value: string): void {
    const cleanedValue = value.replace(/[^\d]/g, '');
    if (this.gameOverMessage && cleanedValue.length > 0) {
      this.gameOverMessage = "";
    }
    this.userInput = cleanedValue;
  }

  handleSubmit() {
    if (!this.isGameActive) {
      return;
    }
    const answer = parseInt(this.userInput);

    if (isNaN(answer) || this.userInput.length === 0) {
      this.gameOverMessage = MESSAGE.INVALID_INPUT();
      return;
    }

    if (answer === this.correctAnswer) {
      this.currentScore++;
      this.gameOverMessage = MESSAGE.CORRECT();
      this.generateQuestion();
    } else {
      this.gameOverMessage = MESSAGE.WRONG(this.correctAnswer);
      let id = setTimeout(() => {
        this.endGame(false);
        clearTimeout(id);
      }, 1500);
    }
  }

  endGame(wasMistake: boolean): void {
    this.isGameActive = false;
    let message = MESSAGE.END_GAME_BASE(this.currentScore);

    if (this.currentScore > this.highScore) {
      this.highScore = this.currentScore;
      message += MESSAGE.HIGH_SCORE_BREAK(this.highScore);
    } else {
      message += MESSAGE.HIGH_SCORE_KEPT(this.highScore);
    }

    this.gameOverMessage = message;
    this.questionExpression = MESSAGE.RESTART();
    this.userInput = "";
  }
}

export default ArithmeticService;
