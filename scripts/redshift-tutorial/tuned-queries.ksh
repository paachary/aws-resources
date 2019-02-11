#!/bin/ksh

. ./settings

. ./exec_sql.ksh disable-result-cache.sql

. ./exec_sql.ksh create-tables-with-keys.sql

. ./exec_sql.ksh insert-records-with-compression.sql

. ./exec_sql.ksh count-sql.sql

. ./exec_sql.ksh query-stv-blocklist.sql

. ./exec_sql.ksh query-data-distribution.sql

. ./exec_sql.ksh query-restriction-1.sql

. ./exec_sql.ksh query-restriction-1.sql

. ./exec_sql.ksh query-restriction-2.sql

. ./exec_sql.ksh query-restriction-2.sql

. ./exec_sql.ksh query-restriction-one-month.sql

. ./exec_sql.ksh query-restriction-one-month.sql

. ./exec_sql.ksh query-plan-restriction-2.sql


