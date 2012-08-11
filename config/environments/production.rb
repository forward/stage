puts "production mode"

app_log = File.new("#{APP_ROOT}/log/app.log", "a+")
$stdout.reopen(app_log)
$stderr.reopen(app_log)