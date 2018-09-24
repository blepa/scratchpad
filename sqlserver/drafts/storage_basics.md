## GAM Interval ##
SQL Server uses several page types to catalog the state of all the pages in a database file. Each database is logically split into pages of 8192 bytes. All pages are organized in extents.
An extent is a group of eight consecutive pages. The page-state tracking page types are GAM, SGAM, IAM, DIFF, ML and PFS pages. All but PFS pages track the state using a bitmap that associates each extent in a GAM interval with a single bit in that bitmap. (PFS pages track status information for single pages not extents.) That means that all those page types need to be present once for each GAM interval.
GAM pages track if an extent is in use. SGAM pages indicate if an extent is a shared extent. DIFF pages mark extents that have changed since the last full backup and ML pages keep track of pages that were affected by minimally logged operations in bulked-logged recovery mode. IAM pages finally link extents to allocation units. (See The Index Allocation Map.)

## GAM Extent ##
IAM Pages are on demand pages and are associated with an allocation unit. As such, they do not have a fixed position within the database file. GAM, SGAM, DIFF and ML pages on the other hand all live in a special extent, the GAM extent. The GAM extent is always the first extent of a GAM interval. The GAM extent for the first GAM interval in each database file contains two additional pages. Page 0 in every file is always a File Header Page. Page 1 is always the first PFS page. All other GAM extents contain only the before mentioned four pages. The remaining pages in a GAM extent are unused as of SQL Server 2012.


https://www.red-gate.com/simple-talk/sql/learn-sql-server/effective-clustered-indexes/
