x = 1 + 1
print("1 + 1 ->", x)

c = 10 - 25
print("10 - 25 ->", c)

z = 2 + 2 * 2
print("2 + 2 * 3 ->", z)

v = 3 + 3 + 4/2
print("3 + 3 + 4/2 ->", v)

b = true or false
print("true or false ->", b)

n = true and false
print("true and false ->", n)

m = -5 > 7
print("-5 > 7 ->", m)

a = 7 < 10
print("7 < 10 ->", a)

s = true != false
print("true != false ->", s)

d = 10 == 10
print("10 == 10 ->", d)

z = 5 <= 5
print("5 <= 5 ->", z)

z = 4 <= 5
print("4 <= 5 ->", z)

z = 6 <= 5
print("6 <= 5 ->", z)

x = 1
if(2 < 3){print("if(2 < 3){1 + 1}->", 1+1)}
print("----------------------------")
if(true == false){f = 3}
else{
f = 4, print("if(true == false){f = 3} else{f = 4}->", f)
}

print("----------------------------")
print("
t = 1
while(t < 7){
  print('t ->', t)
  t = t + 1
}")
t = 1
while(t < 7){
  print("t ->", t)
  t = t + 1
}

print("----------------------------")

print("
wordone = 'Ckaft'
wordtwo = 'tfakC'
for(c in wordone){
for(s in wordtwo){
print('->',c, s)
}
}")
wordone = "Ckaft"
wordtwo = "tfakC"
for(c in wordone){
for(s in wordtwo){
print("->",c, s)
}
}

print("----------------------------")
print("
def plusett(x){
  h = x + 1
  print(h)
}
plusett(2)")

def plusett(x){
  h = x + 1
  print("->", h)
}
plusett(2)
