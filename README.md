# Raspberry Pi 環境

## mongo db
It's running by system installed package.
You can start it by `$ sudo systemctl start mongod`, but it's registered as start-up program.

## metabase
I don't use docker-compose. It's running by system installed package with mysql because I cloudn't docker-compose up the metabase from some reasons.
You can start metabase by `$ sudo systemctl start metabase.service`, but it's registerd as start-up program. If you cannot open metabase in browser, you may need to start mysql by `$ sudo mysql -uroot -p`. I don't know why this command start mysql.

## cron
You can register cron syntax by using below command.
`$ bundle exec whenever --update-crontab`


