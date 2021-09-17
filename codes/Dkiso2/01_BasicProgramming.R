# 基本操作

## 代入

a <- 1
b <- 2
a + b
a <- 3
a + b

## 反復その1
a <- 0
for (i in 1:4) {
  a <- a + 1
  print(a)
}

## 反復その2
a <- 0
for (i in c(1, 3, 5, 15, 12)) {
  print(paste(a, "に", i, "を加えます"))
  a <- a + i
  print(a)
  i <- 12
}

## 反復その3
A <- matrix(1:15, ncol = 3, nrow = 5)
A
for (i in 1:5) {
  for (j in 1:3) {
    A[i, j] <- A[i, j] + i * j
  }
}
A

## 条件分岐その1
egg <- 250
if (egg < 200) {
  print("卵を買います")
} else {
  print("卵を買いません")
}

