//1. 对数组进行解构
let arr1 = [0, 1, 2, 3, 4, 5]

console.log('arr1[0]', arr1[0], 'sdasdf', arr1[0])


let [a, b, c, d] = arr1
console.log(a, b, c, d)


//2. 对对象进行解构

const person = {
    name: 'lily',
    age: 18,
    address: '深圳'
}


//如果想自动推导，一定要写成同名的，否则要自己指定
let {name, age, address} = person
console.log(name, age, address)


let {address: address1, name: name1, age: age1} = person

console.log(name1, age1, address1)


//3. 当对象作为函数参数时，也可以解构

const person1 = {name: '小明', age: 11}

function printPerson({name, age}) { // 函数参数可以解构一个对象
    console.log(`姓名：${name} 年龄：${age}`);
}

printPerson(person1) // 姓名：小明 年龄：11
