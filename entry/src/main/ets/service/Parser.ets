interface ValueToken {
  type: 'Value';
  v: number;
}

interface SimpleToken {
  type: 'Plus' | 'Minus' | 'Multiply' | 'Divide' | 'Lparen' | 'Rparen' | 'End';
}

type Token = ValueToken | SimpleToken;

const PLUS: SimpleToken = { type: 'Plus' };
const MINUS: SimpleToken = { type: 'Minus' };
const MULTIPLY: SimpleToken = { type: 'Multiply' };
const DIVIDE: SimpleToken = { type: 'Divide' };
const LPAREN: SimpleToken = { type: 'Lparen' };
const RPAREN: SimpleToken = { type: 'Rparen' };
const END: SimpleToken = { type: 'End' };

function tokenize(expression: string): Array<Token> {
  const tokens: Array<Token> = [];
  const regex = /(\d+|[+\-*/()])|(\s)/g;
  let match: RegExpExecArray | null;
  while ((match = regex.exec(expression)) !== null) {
    const tokenStr = match[1];
    if (!tokenStr) {
      continue;
    }
    if (/\d+/.test(tokenStr)) {
      tokens.push({ type: 'Value', v: Number(tokenStr) })
    } else {
      switch (tokenStr) {
        case '+':
          tokens.push(PLUS);
          break;
        case '-':
          tokens.push(MINUS);
          break;
        case '*':
          tokens.push(MULTIPLY);
          break;
        case '/':
          tokens.push(DIVIDE);
          break;
        case '(':
          tokens.push(LPAREN);
          break;
        case ')':
          tokens.push(RPAREN);
          break;
        default:
          throw new Error(`Lexer Error: Unknown symbol '${tokenStr}'`);
      }
    }
  }
  tokens.push(END);
  return tokens;
}

class Parser {
  private tokens: Array<Token>;
  private currentToken: Token = { type: 'End' };
  private index: number = 0;

  constructor(tokens: Array<Token>) {
    this.tokens = tokens;
  }

  private matched_nextToken(expected: Token) {
    if (this.currentToken.type === expected.type) {
      this.currentToken = this.nextToken();
    } else {
      throw new Error('Mismatched token!');
    }
  }

  private nextToken(): Token {
    if (this.index < this.tokens.length) {
      this.currentToken = this.tokens[this.index];
      this.index++;
    }
    return this.currentToken;
  }

  public eval(): number {
    this.nextToken();
    return this.expression();
  }

  /**
   * 处理加减运算
   * @returns
   */
  private expression(): number {
    let left = this.term();
    while (this.currentToken.type === 'Plus' || this.currentToken.type === 'Minus') {
      switch (this.currentToken.type) {
        case 'Plus': {
          this.matched_nextToken(PLUS);
          let right = this.term();
          left += right;
          break;
        }
        case 'Minus': {
          this.matched_nextToken(MINUS);
          let right = this.term();
          left -= right;
          break;
        }
      }
    }
    return left;
  }

  /**
   * 处理乘除运算
   * @return
   */
  private term(): number {
    let left = this.atomic();
    while (this.currentToken.type === 'Multiply' || this.currentToken.type === 'Divide') {
      switch (this.currentToken.type) {
        case 'Multiply': {
          this.matched_nextToken(MULTIPLY);
          let right = this.atomic();
          left *= right;
          break;
        }
        case 'Divide': {
          this.matched_nextToken(DIVIDE);
          let right = this.atomic();
          left /= right;
          break;
        }
      }
    }
    return left;
  }

  /**
   * 处理原子项
   * @return
   */
  private atomic(): number {
    switch (this.currentToken.type) {
      case 'Value':
        const v = this.currentToken.v;
        this.matched_nextToken({ type: 'Value', v: v });
        return v;
      case 'Lparen':
        this.matched_nextToken(LPAREN);
        const x = this.expression();
        this.matched_nextToken(RPAREN);
        return x;
      default:
        throw new Error('Unexpected symbol!');
    }
  }
}

/**
 * 根据表达式字符串求值
 * @param expression 表达式字符串
 * @returns 表达式的值
 */
function parser(expression: string): number {
  return new Parser(tokenize(expression)).eval()
}

export default parser;
