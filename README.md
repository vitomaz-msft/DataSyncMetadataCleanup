# SQL Data Sync Cleanup scripts

Use cases:

Use 'Data Sync complete cleanup.sql' only when:
- Exporting a database that is/was used as SQL Data Sync metadata database(more details at https://blogs.msdn.microsoft.com/azuresqldbsupport/2018/08/11/exporting-a-database-that-is-was-used-as-sql-data-sync-metadata-database/)
- Advised by the support team during a support request

Use 'Data Sync cleanup hub or member.sql' only when:
- You need to delete everything related to all the sync groups from the database (this will keep sync metadata DB related objects in case the database is also the sync metadata DB).

Use ‘cleanup data sync object V2.sql' to:
-Generate cleanup scripts for a specific table (also supports generating for all the tables but will not clean scope and provision marker information).

In case you have multiple sync groups and do not want to remove everything or are unsure about what you should remove, please run https://github.com/vitomaz-msft/DataSyncHealthChecker and share the results with the support team.
