module RetryHarder
  class RetryResult

    attr_accessor :success

    def initialize(options)
      self.success = options[:success]
    end

    def on_failure(&block)
      if !success
        block.call
      end

      self
    end

    def on_success(&block)
      if success
        block.call
      end

      self
    end

  end

  module InstanceMethods
    def retry_harder(options, &block)
      times_to_run = options.delete(:times) || 1
      wait_time = options.delete(:wait_time) || 0.5

      times_to_run.times do
        begin 
          block.call
          @success = true
          break
        rescue => e
          sleep wait_time
          @success = false
        end
      end

      ::RetryHarder::RetryResult.new(:success => @success)
    end
  end

  def self.initialize
    Object.send(:include, RetryHarder::InstanceMethods)
  end

end

__END__
# Example
RetryHarder.initialize

puts "BEGIN"

retry_harder(:times => 4) do
  puts "harder!"

  #raise

end.on_failure do
  puts "fail"
end.on_success do
  puts "winning"
end

puts "DONE"
