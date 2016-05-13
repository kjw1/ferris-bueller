require 'thor'
require 'slog'


module FerrisBueller

  # Thor's hammer! Like Thor with better logging
  class Mjolnir < Thor

    # Common options for Thor commands
    COMMON_OPTIONS = {
      log: {
        type: :string,
        aliases: %w[ -l ],
        desc: 'Log to file instead of STDOUT',
        default: ENV['FERRIS_BUELLER_LOG'] || nil
      },
      debug: {
        type: :boolean,
        aliases: %w[ -v ],
        desc: 'Enable DEBUG-level logging',
        default: ENV['FERRIS_BUELLER_DEBUG'] || false
      },
      trace: {
        type: :boolean,
        aliases: %w[ -z ],
        desc: 'Enable TRACE-level logging (overrides DEBUG)',
        default: ENV['FERRIS_BUELLER_TRACE'] || false
      }
    }

    # Decorate Thor commands with the options above
    def self.include_common_options
      COMMON_OPTIONS.each do |name, spec|
        option name, spec
      end
    end


    no_commands do

      # Construct a Logger given the command-line options
      def log
        return @logger if defined? @logger
        device = options.log || $stdout
        colorize, prettify = false, false
        colorize, prettify = true, true if device.tty? rescue false
        @logger = Slog.new \
          out: device, colorize: colorize, prettify: prettify
        @logger.level = :debug if options.debug?
        @logger.level = :trace if options.trace?
        @logger
      end

    end
  end
end