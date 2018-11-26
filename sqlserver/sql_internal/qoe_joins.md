#JOINS#


##Nested Loop Join##

Two inputs: *outer* and *inner* tables  

```
Inner nested loop join algorithm:
for each row R1 in outer table
  for each row R2 in inner table
    if R1 joins with R2
      return join (R1, R2)
      
Outer nested loop join algorithm:
for each row R1 in outer table
  for each row R2 in inner table
    if R1 joins with R2
      return join (R1, R2)
    else
      return join (R1, NULL)
```

**Best use case**: 
Small inputs. Preferable with index on join key in inner table.  

##Merge Join##  

