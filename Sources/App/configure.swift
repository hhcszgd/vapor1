import FluentSQLite
import Vapor
import FluentMySQL
/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentSQLiteProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    /*
    // Configure a SQLite database
    let sqlite = try SQLiteDatabase(storage: .memory)

    // Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Todo.self, database: .sqlite)
    services.register(migrations)
    */
    var mysqlHost : String = "localhost"
    var mysqlPort : Int = 3306
    var mysqlDB : String = "mysql"
    var mysqlUser : String = "root"
    var mysqlPasscode : String = ""
    if env == .development || env == .testing {
         mysqlHost  = "localhost"
         mysqlPort  = 3306
         mysqlDB  = "hhcszgd"
          mysqlUser  = "root"
         mysqlPasscode = ""
    }else{
        mysqlHost  = Environment.get("MYSQL_HOST") ?? "none"
        mysqlPort  = 3306
        mysqlDB  =  Environment.get("MYSQL_DB") ?? "none"
        mysqlUser  =  Environment.get("MYSQL_USER") ?? "none"
        mysqlPasscode =  Environment.get("MYSQL_PASS") ?? "none"
    }
    var databases = DatabasesConfig()
    let mysqlConfig = MySQLDatabaseConfig(
        hostname: mysqlHost,
        port: mysqlPort,
        username: mysqlUser,
        password: mysqlPasscode,
        database: mysqlDB,
//        capabilities: <#T##MySQLCapabilities#>,
//        characterSet: MySQLCharacterSet.utf8_general_ci,
        transport: MySQLTransportConfig.unverifiedTLS)
    let mysql = MySQLDatabase(config: mysqlConfig)
    databases.add(database: mysql , as: .mysql)
    services.register(databases)
    // Configure migrations
    var migrations = MigrationConfig()
    //创建表的方式1 , 使用migration
//    migrations.add(migration: CreateBookTable.self, database: .mysql)
    //创建表的方式2 , 使用Model , 此时,Model要遵守Migration协议,并且指定这个Model类的数据库类型Book.defaultDatabase = .mysql
    //Migration的协议方法可按需求重写,没有特殊需求,可不重写
    Book.defaultDatabase = .mysql
    migrations.add(model: Book.self, database:  .mysql)
    ///创建数据库测试数据
    //第一步 定义CreateBookRecoder类并注册到服务中
    //第二步(base) wy:vapor1 wy$ vapor build
    //第三步(base) wy:vapor1 wy$ vapor run migrate
    //删除表命令 vapor run revert -all，就会先把book表清空(提示Are you sure you want to revert the last batch of migrations?  )-all清除所有的migration , 不加-all清除最后一个
    migrations.add(migration: CreateBookRecoder.self , database: .mysql)
    
    services.register(migrations)
    
    
    //Configure the rest of your application here
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)
}
