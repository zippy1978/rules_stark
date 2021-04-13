module math

func add(a: int, b: int): int {
    return a + b
}

func sub(a: int, b: int): int {
    return a - b
}

func pow(base: double ,power: int): double {
    
    if (power == 0) {
        return 1.0
    }
    
    res := base
    i := 1
    while (i < power) {
        res = res * base
        i = i + 1
    }
    return res
}