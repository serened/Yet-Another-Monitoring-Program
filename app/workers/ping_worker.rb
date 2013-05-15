class PingWorker
  include Sidekiq::Worker
  include WorkerTemplate
  sidekiq_options :retry => false
  # This is derpy
  MonitorResult = Struct.new(:successful, :return_object, :duration)

  def perform(monitor_id)
    @monitor = find_monitor(monitor_id)
    if @monitor.nil?
      nil
    else
      do_monitor(@monitor)
    end
  end

  def do_monitor(monitor=@monitor)
    ping = Net::Ping::External.new(monitor.hostname)
    ping.ping # >8U
    if ping.exception
      result = MonitorResult.new(successful: false)
    else
      result = MonitorResult.new(successful: false, duration: ping.duration)
    end
    create_result(result)
    save_result(@p)
  end

  def create_result(result)
    if result.successful
      @p = PingResult.new(
        successful: result.successful,
        duration: result.duration
      )
      # create_alert
    else
      @p = PingResult.new(
        successful: result.successful,
        duration: result.duration
      )
    end
  end

  def save_result(result)
    result.save
  end

  def find_monitor(monitor_id)
    monitor = PingMonitor.find_by_id(monitor_id)
    if monitor
      monitor
    else
      nil
    end
  end

end
