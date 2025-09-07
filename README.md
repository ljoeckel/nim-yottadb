# nim-yottadb
NIM Language implementation for the YottaDB database
### This project was started to learn NIM (https://nim-lang.org)
I'm truly impressed by the simplicity, power, and flexibility of Nim. The possibilities offered by macros and templates, in particular, make Nim a powerful tool. Developing software is finally fun again.


For the project's architecture details look at https://deepwiki.com/ljoeckel/nim-yottadb/1-overview

This project adds NIM as another language to access the YottaDB (https://yottadb.com) NoSQL database. Beside API-Access to the 'Simple-API', a DSL allows direct access to "Global" variables directly in code.

```nim
    var amount = get: ^CUST(4711, "ACT1234").float
    amount += 1500.50
    set: ^CUST(4711, "ACT1234") = amount
```

YottaDB is a proven Multi-Language NoSQL database engine whose code base has decades of maturity and continuous investment. It is currently in production at some of the largest real-time core banking applications and electronic health record deployments.

