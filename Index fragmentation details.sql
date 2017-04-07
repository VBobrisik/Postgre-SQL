-- -3 is for ' MB' change to -6 if you need to work with ' bytes'
SELECT 
    relid::regclass AS table, 
    indexrelid::regclass AS index, 
    CAST ( SUBSTRING ( pg_size_pretty(pg_relation_size(indexrelid::regclass)),
                      1,CHAR_LENGTH (pg_size_pretty(pg_relation_size(indexrelid::regclass)))-3 ) AS integer)AS index_size, 
    idx_tup_read, 
    idx_tup_fetch, 
    idx_tup_read - idx_tup_fetch AS indxDiff,
    --index diff %
    CASE 
      WHEN idx_tup_read = 0 then 0
      WHEN idx_tup_read > 0 then round((100-CAST(idx_tup_fetch AS DECIMAL)/CAST(idx_tup_read AS DECIMAL)*100 ),2)
    END AS indxDiffPrcnt,
    idx_scan
FROM 
    pg_stat_user_indexes 
    JOIN pg_index USING (indexrelid) 
WHERE indisunique IS FALSE AND idx_scan!=0 and (idx_tup_read - idx_tup_fetch) > 500000 
  and round((100-CAST(idx_tup_fetch AS DECIMAL)/CAST(idx_tup_read AS DECIMAL)*100 ),2) > 5
  AND (pg_size_pretty(pg_relation_size(indexrelid::regclass)) LIKE '%MB')
ORDER BY idx_scan DESC ,indxDiffPrcnt DESC
