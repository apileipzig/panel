class RequestLog < ActiveRecord::Base

  def self.all_tables
    RequestLog.all.map{|l| l.model}.uniq
  end
  
  def self.table_stats
    log = RequestLog.all
    stats = Array.new
    tables = log.map{|l| l.model}.uniq
    tables.each do |table|
      bar = Hash.new
      bar['name'] = table
      bar['data'] = [log.select{|l| l.model == table}.length.to_s]
      stats << bar
    end
  end

end

