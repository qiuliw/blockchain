class Person {
    constructor(name, age) {
        this.name = name
        this.age = age
    }

    say() {
        console.log(`大家好,我是: ${this.name}, 年龄: ${this.age}`)
    }
}


let p1 = new Person("渣渣辉", 45)
p1.say()


class XiaoDi extends Person {
    //需要先构造父类

    constructor(name, age) {
        super(name, age)
        this.name = name
        this.age = age
    }

    say() {
        console.log('人狠话又多!')
    }
}

let X1 = new XiaoDi('航头冬哥', 26)
X1.say()
