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


# db 直接操作
```
> use bitbank_auto;
switched to db bitbank_auto
> db.histories.find({price: 5195197.006999999})
{ "_id" : ObjectId("603e5d4aac07029f418d44e3"), "side" : "sell", "pair" : "btc_jpy", "amount" : 0.00058424, "price" : 5195197.006999999, "type" : "limit", "created_at" : ISODate("2021-03-02T15:44:10.130Z") }
> db.histories.remove({price: 5195197.006999999})
WriteResult({ "nRemoved" : 1 })
```

Firebase からも直接削除

# test
Mongodb にある tickers を使用して、ロジックの検証を行います

`$ bundle exec ruby test /simulation.rb`


