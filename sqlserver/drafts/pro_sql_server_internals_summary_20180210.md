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

## **INDEX FRAGMENTATION** ##
### **Summary** ###

There are two types of index fragmentation in SQL Server. **External fragmentation** occurs when logically subsequent data pages are not located in the **same or adjacent extents**. Such fragmentation affects the performance of **scan operations** that require physical I/O reads.  

External fragmentation has a much lesser effect on the performance of index seek operations when just a handful of rows and data pages need to be read. Moreover, it does not affect performance when data pages are cached in the buffer pool.  

**Internal fragmentation** occurs when **leaf-level data** pages in the index **have free space**. As a result, the index uses more data pages to store data on disk and in memory. Internal fragmentation negatively affects the performance of **scan operations**, even when data pages are cached, due to the extra data pages that need to be processed.  

A small degree of internal fragmentation can **speed up insert and update** operations and reduce the number of page splits. You can reserve some space in leaf-level index pages during index creation or index rebuild by specifying the **FILLFACTOR** property. It is recommended that you fine-tune FILLFACTOR by gradually decreasing its value and monitoring how it affects fragmentation in the system. You can also monitor page split operations with Extended Events if you are using SQL Server 2012 or above.  

The sys.dm_db_index_physical_stats data management function allows you to monitor both internal and external fragmentation. There are two ways to reduce index fragmentation. The ALTER INDEX **REORGANIZE** command **reorders index leaf pages**. This is an **online** operation that can be cancelled at any time without losing its progress. The ALTER INDEX **REBUILD** command replaces an **old fragmented index with a new copy**. By default, it is an **offline** operation, although the Enterprise Edition of SQL Server can rebuild indexes online.

You must consider multiple factors when designing index maintenance strategies, such as system workload and availability, the version and edition of SQL Server being used, and any High Availability technologies used in the system. You should also analyze how fragmentation affects the system. Index maintenance is **very resource-intensive**, and, in some cases, the overhead it introduces exceeds the benefits it provides.  

The best way to minimize fragmentation, however, is by eliminating its root cause. Consider avoiding situations where the row size increases during updates, and do not shrink data files, do not use AFTER triggers, and avoid indexes on the uniqueidentifier or hashbyte columns that are populated with random values.

## **DESIGNING AND TUNING THE INDEXES** ##
### **Summary** ###

An **ideal clustered** index is **narrow**, **static**, and **unique**. Moreover, it optimizes the most important queries against the table and reduces fragmentation. It is often impossible to design a clustered index that satisfies all of the five design guidelines provided in this chapter. You should analyze the system, business requirements, and workload and choose the most efficient clustered indexes—even when they violate some of those guidelines.  

**Ever-increasing** clustered indexes usually have low fragmentation because the data is inserted at the end of the table. A good example of such indexes are **identities**, **sequences**, and **ever-incrementing date/time** values. While such indexes may be a good choice for catalog entities with thousands or even millions of rows, you should consider other options in the case of huge tables with a high rate of inserts. **Uniqueidentifier** columns with **random** values are rarely good candidates for indexes due to their high fragmentation. You should generate the key values with the NEWSEQUENTIALID() function if indexes on
the uniqueidentifier data type are required.  

SQL Server rarely uses index intersection, especially in an OLTP workload. It is usually beneficial to have a **small set of wide**, **composite**, **nonclustered** indexes with **included columns** rather than a large **set of narrow one-column** indexes.

In OLTP systems, you should create a **minimally required** set of indexes to avoid index update overhead. In data warehouse systems, the **number of indexes** greatly depends on the **data-refresh strategy**. You should also consider using **columnstore** indexes in dedicated data warehouse databases.

It is important to **drop unused and inefficient** indexes and perform index consolidation before adding new indexes to the system. This simplifies the optimization process and reduces data modification overhead. SQL Server provides index usage statistics with the sys.dm_db_index_usage_stats and sys.dm_db_index_operation_stats DMOs.

You can use SQL Server Profiler, Extended Events, and DMVs, such as sys.dm_exec_query_stats and sys.dm_exec_procedure_stats , to detect inefficient queries. Moreover, there are plenty of tools that can help with monitoring and index tuning. With all that being said, you should always consider query and database schema refactoring as an option. It often leads to much better performance improvements when compared to index tuning by itself.

## **DATA PARTITIONING** ##
### **Summary** ###

Management of a large amount of data is a challenging task, especially when the data is not partitioned. Keeping a large amount of data in the same place is not efficient for several different reasons. It increases storage costs and introduces overhead due to the different workload and index management requirements for the various parts of the data. Moreover, it prevents piecemeal database restore, which complicates availability SLA compliance.  

There are two main data partitioning techniques available in SQL Server. **Partitioned tables** are available in the Enterprise Edition of SQL Server. They allow you to partition table data into separate internal **tables/partitions**, which are **transparent** to client applications. Each partition can be placed in its **own filegroup** and have its **own data compression**. However, the database schema, indexes, and statistics are the same across all partitions.  

Alternatively, you can partition the data by **separating it between multiple tables**, combining all of them through a **partitioned view** using the union all operator. Every table can have its own schema and set of indexes and maintain its own statistics. Partitioned views are supported in all editions of SQL Server. 

Although partitioned views are **more flexible**, such an implementation requires code re-factoring and increases the system maintenance cost because of the large number of tables involved. You can reduce that cost by **combining partitioned tables and views together**.  

Data partitioning helps reduce storage subsystem cost by implementing **tiered storage**. With such
an approach, you can place active operational data on a fast disk array while keeping old, rarely accessed
historical data on cheaper disks. You should design a strategy that allows you to move data between different
disk arrays when needed. Different versions and editions of SQL Server require different implementation
approaches for this task.

You should be careful moving a large amount of data when transaction log – based High Availability technologies are in use. A large amount of transaction log records leads to a REDO process backlog on secondary nodes and can increase system downtime in case of a failover. Moreover, you should prevent queries from accessing readable secondaries in case of a backlog.

You can use data partitioning to improve the performance and concurrency of **data import and purge** operations. Make sure to keep the rightmost partition empty when you are implementing a sliding window scenario in the system.  

Finally, data partitioning comes at a cost. In the case of partitioned tables, a **partition column must be included in the clustered index**, which increases the size of nonclustered index rows. Moreover, indexes are sorted within individual partitions. This can lead to suboptimal execution plans and regressions after partitioning has been implemented. The $PARTITION function can be used to access data in individual partitions, and this can help with optimization.
