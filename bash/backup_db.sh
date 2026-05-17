# backup all files
mupip backup -newjnlfiles "*" /backup/
# verify
mupip integ /backup/yottadb.dat
# -> journal files may be removed if integ is ok