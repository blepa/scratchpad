# **PART 1: TABLES AND INDEXES** #
## **DATA STORAGE INTERNALS** ##
### **Summary** ###


SQL Server stores data in databases that consist of **one or more transaction log files** and **one or more data files**. Data files are combined into filegroups. Filegroups abstract the database file structure from database objects, which are logically stored in the filegroups rather than in database files. You should consider creating multiple data files for any filegroups that store volatile data.
       
SQL Server always zeros out transaction logs during a database restore and log file auto-growth. By
default, it also zeros out data files unless instant file initialization is enabled. Instant file initialization
significantly decreases database restore time and makes data file auto-growth instant. However, there is a
small security risk associated with instant file initialization, as the uninitialized part of the database may
contain data from previously deleted OS files. Nevertheless, it is recommended that you enable instant file
initialization if such a risk is acceptable.   
    
SQL Server stores information on **8,000 data pages combined into extents**. There are two types of
extents. **Mixed extents** store data from different objects. **Uniform extents** store data that belongs to a single
object. SQL Server stores the first eight object pages in mixed extents. After that, only uniform extents are
used during object space allocation. You should consider enabling trace flag T1118 to prevent mixed extents
space allocation and reduce allocation map pages contention.   
    
SQL Server uses special map pages to track allocations in the file. There are several allocation map
types. **GAM pages** track which extents are allocated. **SGAM pages** track available mixed extents. **IAM pages** track
extents that are used by the **allocation units** on the **object (partition)** level. **PFS** stores several page attributes,
including **free space available** on the page, in **heap tables** and in **row-overflow** and **LOB** pages.
