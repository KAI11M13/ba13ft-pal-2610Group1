-- ================================================================
-- PAL | Iowa Liquor Sales | Step 00: allow loading local files
-- ================================================================
-- Run once per MySQL server start (the setting resets when the server restarts).
--
-- Loading local files must be allowed on BOTH sides:
--   Server side : the statement below
--   Client side : MySQL Workbench > Home > right-click the connection > Edit Connection >
--                 Advanced > add OPT_LOCAL_INFILE=1 in "Others" > close the connection tab
--                 and reconnect. Without it, LOAD DATA fails with Error Code 2068.
-- Also recommended: Edit > Preferences > SQL Editor > DBMS connection read timeout = 3600,
-- so large files finish loading without a lost connection.
-- ================================================================

SET GLOBAL local_infile = 1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';   -- expect ON
