<?php
header('Content-Type: text/plain');
echo <<<TXT
# leftover deploy config — do not commit
APP_HOST=172.28.20.12
DC_HOST=172.28.20.13
DC_USER=northwind_admin
DC_PASS=NorthwindDA!
TXT;
