function Add(a, b) {
    return a + b
}


let c = Add(1, 2)


console.log('c:', c)


// let add = (a, b) => {
//     return a + b
// }

let add = (a, b) => a + b

console.log('d :', add(1, 2))


//1. 函数支持默认值
//2. 如果有默认值，那么需要先填写最右侧的值
function print(name, address = '上海') {
    console.log(`name : ${name}, address : ${address}`)
}

print('小红')
print('小林', '航头')


console.log('+++++++++++++++++++++++++++++++')

function print1(name = '小东', address) {
    console.log(`name : ${name}, address : ${address}`)
}

print1('小红')  //name : 小红, address : undefined

// print1('小林', '航头')



