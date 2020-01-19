a = [2,3]
c = a.size()
print(c)
d = a.at(1)
print(d)

a.push_back(5)
a.push_front(99)
print(a)
a.remove_at(1)
print(a)

a.push_back("hej")
print(a)
print(a.size())

print(" ")
for(ele in a){
  print(ele)
}

print("-------------------")
print("Recursion magic lul")
print("-------------------")

def plusett(x){
  if(x ==4){
  print("hej")
  }
  else{
  print("Nej")
  plusett(x+1)
  }
}
plusett(1)


print("normal below")

def plus(e){
  h = e + 1
  print("->", h)
}
plus(6)
