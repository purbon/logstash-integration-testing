require 'lsit/reporter'

module LSit
  module Executor
    class Suite

      attr_reader :definition, :install_path, :runner

      def initialize(definition, install_path, runner = Runner)
        @definition   = definition
        @install_path = install_path
        @runner       = runner
      end

      def execute(debug=false)
        tests    = eval(IO.read(definition))
        lines    = ["name, #{runner.headers.join(',')}"]
        reporter = Reporter.new.start
        tests.each do |test|
          events  = test[:events].to_i
          time    = test[:time].to_i
          manager = runner.new(test[:config], debug, install_path)
          metrics = manager.run(events, time, manager.read_input_file(test[:input]))
          lines << formatter(test[:name], metrics)
        end
        puts lines
        lines
      ensure
        reporter.stop if reporter
      end

      private

      def formatter(test_name, args={})
        p      =   args[:p]
        params = [ test_name, args[:start_time], args[:elapsed], args[:events_count],
                   args[:events_count] / args[:elapsed], p.last, p.reduce(:+) / p.size ]
        "%s, %.2f, %2.f, %0.f, %.0f, %2.f, %0.f" % params
      end

    end
  end
end
