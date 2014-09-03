class CompleteInterval
  @queue = :time_intervals_queue

  def self.perform(interval_id)
    begin
      @interval = TimeInterval.find(interval_id)
      if (Time.new.to_i - @interval.end_time) > 280 #if its been almost 5 minutes or more
        @interval.complete
      else
        Resque.enqueue_in 5.minutes, CompleteInterval, interval_id
      end
    rescue
      #it doesnt exist. This is good.
    end
  end
end