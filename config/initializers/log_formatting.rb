# https://stackoverflow.com/questions/18176447/undefined-method-tagged-for-formatter-error-after-rails-4-upgrade/18258936
Rails.logger = ActiveSupport::Logger.new "log/mylog.log"
Rails.logger.formatter = proc{|severity,datetime,progname,msg|
    "[#{datetime.strftime("%Y-%m-%d %H:%M:%S")}] [#{severity}]: #{msg}\n"
}
