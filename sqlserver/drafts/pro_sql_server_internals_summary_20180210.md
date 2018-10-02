# **PART 1: TABLES AND INDEXES** #
## **DATA STORAGE INTERNALS** ##
### **Summary** ###

SQL Server stores data in databases that consist of **one or more transaction log files** and **one or more data files**. Data files are combined into filegroups. Filegroups abstract the database file structure from database objects, which are logically stored in the filegroups rather than in database files. You should consider creating multiple data files for any filegroups that store volatile data.
       
SQL Server always zeros out transaction logs during a database restore and log file auto-growth. By default, it also zeros out data files unless instant file initialization is enabled. Instant file initialization significantly decreases database restore time and makes data file auto-growth instant. However, there is a small security risk associated with instant file initialization, as the uninitialized part of the database may contain data from previously deleted OS files. Nevertheless, it is recommended that you enable instant file initialization if such a risk is acceptable.   
    
SQL Server stores information on **8,000 data pages combined into extents**. There are two types of extents. **Mixed extents** store data from different objects. **Uniform extents** store data that belongs to a single object. SQL Server stores the first eight object pages in mixed extents. After that, only uniform extents are used during object space allocation. You should consider enabling trace flag T1118 to prevent mixed extents space allocation and reduce allocation map pages contention.   
    
SQL Server uses special map pages to track allocations in the file. There are several allocation map types. **GAM pages** track which extents are allocated. **SGAM pages** track available mixed extents. **IAM pages** track extents that are used by the **allocation units** on the **object (partition)** level. **PFS** stores several page attributes, including **free space available** on the page, in **heap tables** and in **row-overflow** and **LOB** pages.

## **TABLES AND INDEXES: INTERNAL STRUCTURE AND ACCESS METHOD** ##
### **Summary** ###

**Clustered indexes** define the **sorting order** for data in a table. **Nonclustered indexes** store a **copy of the data** for a subset of table columns sorted in the order in which the key columns are defined. Both clustered and nonclustered indexes are stored in a **multiple-level tree-like** structure called a **B-Tree**. Data pages on each level are linked in a **double-linked list**.

The **leaf level** of the **clustered index** stores the **actual table data**. The **intermediate-level** and **root-level pages** store one row per page from the next level. Every row includes the **physical address** and **minimum value of the key** from the page that it references.

The **leaf level** of a **nonclustered index** stores the data from the **index columns** and **row-id**. For tables with a clustered index, **row-id is the clustered key** value of the row. Then intermediate and root levels of a nonclustered index are **similar** to those of a **clustered index**, although when the index is not unique, those rows store row-id in addition to the minimum index key value. It is **beneficial** to define indexes as **unique**, as it makes the intermediate and root levels more **compact**. Moreover, **uniqueness** helps Query Optimizer generate more **efficient execution plans**.

SQL Server needs to traverse the clustered index tree to obtain any data from the columns that are not part of the nonclustered index. Those operations, called key lookups , are expensive in terms of I/O. SQL Server does not use nonclustered indexes if it expects that a large number of key or RID lookup operations will be required.  

Tables with a clustered index usually outperform heap tables. It is thus beneficial to define a clustered index on tables in most cases.

SQL Server can utilize indexes in two separate ways. The first way is an **index scan operation**, where it reads **every page** from the index. The second one is an index **seek operation**, where SQL Server processes just a **subset of the index pages**. It is beneficial to use **SARGable** predicates in queries, which allows SQL Server to perform **index seek** operations by **exactly matching** the row or range of rows in the index.  

## **STATISTICS** ##
### **Summary** ###

Correct **cardinality estimation** is one of the **most important** factors that allows the Query Optimizer to generate **efficient execution plans**. Cardinality estimation affects the choice of indexes, join strategies, and other parameters.  

SQL Server uses **statistics to perform cardinality estimations**. The vital part of statistics is the **histogram**, which stores information about **data distribution** in the **leftmost statistics column**. Every step in the histogram contains a **sample statistics-column value** and information about what happens in the histogram step, such as **how many rows are in the interval**, **how many unique key values there are**, and so on. SQL Server creates statistics for **every index** defined in the system. In **addition**, you can create **columnlevel** statistics on individual or **multiple columns** in the table. SQL Server creates column-level statistics automatically if the database has the **Auto Create Statistics** option enabled.

Statistics have a few **limitations**. There are at most **200 steps** (key value intervals) stored in the histogram. As a result, the histogram’s steps cover larger key value intervals as the table grows. This leads to larger approximations within the intervals and less accurate cardinality estimations on tables with millions or billions of rows. Moreover, the histogram stores information about data distribution for the **leftmost statistics column only**. There is no information about other columns in the statistics or index aside from multi-column density.  

SQL Server tracks the number of changes made in statistics columns. By default, SQL Server outdates and updates statistics after that number exceeds about **20 percent** of the total number of rows in the table. As a result, statistics are rarely updated automatically on large tables. You need to consider updating statistics on large tables manually based on a schedule.  

In SQL Server 2016, with database compatibility level 130, the statistics update threshold is dynamic and based on the size of the table, which makes statistics on large tables more accurate. You can use trace flag T2371 in previous versions of SQL Server, or with database compatibility level lower than 130. It is recommended that you set this trace flag in the majority of systems. 
You should also update statistics on ever-increasing or ever-decreasing indexes more often, as SQL Server tends to underestimate the number of rows when the parameters are outside of the histogram, unless you are using the new cardinality estimation model introduced in SQL Server 2014.  

The new cardinality estimation model is enabled in SQL Server 2014 and 2016 for databases with a compatibility level of 120 or 130. This model addresses a few common issues, such as estimations for everincreasing indexes when statistics are not up to date; however, it may introduce plan regressions in some cases. You should carefully test existing systems before enabling the new cardinality estimation model after upgrading SQL Server.  

## **SPECIAL INDEXING AND STORAGE FEATURES** ##
### **Summary** ##

SQL Server does **not use nonclustered indexes** in cases where it expects a **large number of key or RID lookup** operations to be required. You can eliminate these operations by adding columns to the index and making it covering for the queries. This approach is a great optimization technique that can dramatically improve the performance of the system.

Adding **included columns** to the index, however, **increases the size of leaf-level** rows, which would negatively affect the performance of the queries that scan data. It would also introduce additional **indexmaintenance overhead**, **slow down data-modification** operations, and **increase locking** in the system. **Filtered indexes** allow you to **reduce index storage size** and maintenance costs by indexing just a subset of the data. SQL Server has a few design limitations associated with filtered indexes. Even though it is not a requirement, you should make all columns from the filters part of the leaf-level index rows so as to prevent the generation of suboptimal execution plans.

Modifications of the columns from the filter do not increment the statistics column modification counter, which can make the statistics inaccurate. You need to factor that behavior into your statistics maintenance strategy for the system.

Filtered statistics allow you to **improve cardinality** estimations in the case of highly correlated predicates in the queries. They have all of the limitations of filtered indexes, however.  

The Enterprise Edition of SQL Server supports two different data compression methods. **Row compression** reduces data row size by removing unused storage space from rows. **Page compression** removes duplicated sequences of bytes from data pages.

Data compression can significantly **reduce table storage** space at the cost of **extra CPU load**, especially when data is **modified**. However, compressed data uses **less space in the buffer pool** and requires **fewer I/O operations**, which can improve the performance of the system. Row compression could be a good choice even with volatile data on **non-heavily-CPU-bound** systems. Page compression is a good choice for **static data**.  

**Sparse** columns allow you to reduce row size when some columns store **primarily NULL** values. Sparse columns do not use storage space while storing NULL values at the cost of the **extra storage** space required for **NOT NULL values**.

Although sparse columns allow the creation of wide tables with thousands of columns, you should be careful with them. There is still the 8,060-byte in-row data size limit, which can prevent you from inserting or updating some rows. Moreover, wide tables usually introduce development and administrative overhead when frequent schema alteration is required.

Finally, you should monitor the data stored in sparse columns, making sure that the percentage of NOT NULL data is not increasing, which would make sparse storage less efficient than nonsparse storage.
