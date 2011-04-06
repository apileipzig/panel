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
      c = log.select{|l| l.model == table}.length
      bar['data'] = c
      stats << bar
    end
    return stats
  end
end

