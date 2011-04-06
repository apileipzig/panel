class RequestLog < ActiveRecord::Base

  def self.simple_stats
    Rails.logger.info RequestLog.all.inspect
  end

end

