var BigNumber = require('bignumber.js');

console.log('====相等?====')
x = new BigNumber(123.4567);
y = new BigNumber(123456.7e-3);
z = new BigNumber(x);
console.log(x.eq(y))

console.log('====加法====')
m = new BigNumber(10101, 2);
n = new BigNumber("ABCD", 16);
console.log(m.plus(n))

console.log(m.plus(n).toString())

console.log('====减法====')
x = new BigNumber(0.5)
y = new BigNumber(0.4)
console.log(0.5 - 0.4)
console.log(x.minus(y).toString())

console.log('====乘法====')
x = new BigNumber('2222222222222222222222222222222222')
y = new BigNumber('7777777777777777777777777777777777', 16)
console.log(x.times(y).toString())

console.log('====除法====')
console.log(x.div(y).toString())
console.log(x.div(y))
console.log(x.div(y).toFixed(6).toString())

console.log('==== x = -123.456====')
x = new BigNumber(-123.456)

console.log(x)

console.log("尾数x.c：", x.c)
console.log("指数x.e：", x.e)
console.log("符号x.s：", x.s)
