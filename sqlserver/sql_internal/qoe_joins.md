# JOINS

## Nested Loop Join

Two inputs: *outer* and *inner* tables  

```
/* Inner nested loop join algorithm: */
for each row R1 in outer table
  for each row R2 in inner table
    if R1 joins with R2
      return join (R1, R2)
      
/* Outer nested loop join algorithm: */
for each row R1 in outer table
  for each row R2 in inner table
    if R1 joins with R2
      return join (R1, R2)
    else
      return join (R1, NULL)
```

**Best use case**: 
Small inputs. Preferable with index on join key in inner table.  

## Merge Join  

The *merge join* works two sorted inputs. It compares two rows, one at time, and return thier join to the client id they are equal.

```
/* Pre-requirements: Inputs I1 and I2 are sorted */
get first row R1 from input I1
get first row R2 from input I2
while not end of either input
begin
  if R1 joins with R2
  begin
    return join (R1, R2)
    get next row R2 from I2
  end
  else if R1 < R2
    get next row R1 from I1
   else /* R1 > R2 */
    get next row R2 from I2
end
```  

## Hash Join  

*Hash join* is designed to handle large, unsorted inputs. The hash join algorithm consists of two diffrent phases.

```
/* Build Phase - usually the smaller one input */
for each row R1 in input I1
begin
  calculate hash value on R1 join key
  insert hash value to appropriate bucket in hash table
end

/* Probe Phase */
for each row R2 in input I2
begin
  calculate hash value on R2 join key
  for each row R1 in hash table bucket
    if R1 joins with R2 /* avoid hash collision */
      return join (R1, R2)
end
```

  When the memory estimation is incorrect, the *hash join* stores some hash table buckets in tempdb , which can greatly reduce the performance of the operator.  
  The number of times this happens is called the recursion level . SQL Server tracks it and eventually
switches to a special bailout algorithm, which is less efficient, although it’s guaranteed to complete at some
point.  
