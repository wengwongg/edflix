require "logger"
require "sequel"

type = ENV.fetch("APP_ENV", "production")
# type = ENV.fetch("APP_ENV", "test")

# finding path to database file
db_path = File.dirname(__FILE__)
db = "#{db_path}/#{type}.db"

# find the path to the log
log_path = "#{File.dirname(__FILE__)}/../log/"
log = "#{log_path}/#{type}.log"

# create log directory if it does not exist
FileUtils.mkdir_p(log_path)

# set up the Sequel database instance
DB = Sequel.sqlite(db, logger: Logger.new(log))
