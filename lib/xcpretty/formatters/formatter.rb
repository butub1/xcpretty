require 'xcpretty/ansi'
require 'xcpretty/parser'

module XCPretty

  # Making a new formatter is easy.
  # Just make a subclass of Formatter, and override any of these methods.
  module FormatMethods
    EMPTY = ''.freeze

    def format_analyze(file_name, file_path);                EMPTY; end
    def format_build_target(target, project, configuration); EMPTY; end
    def format_check_dependencies;                           EMPTY; end
    def format_clean(project, target, configuration);        EMPTY; end
    def format_clean_target(target, project, configuration); EMPTY; end
    def format_clean_remove;                                 EMPTY; end
    def format_compile(file_name, file_path);                EMPTY; end
    def format_compile_xib(file_name, file_path);            EMPTY; end
    def format_copy_strings_file(file_name);                 EMPTY; end
    def format_cpresource(file);                             EMPTY; end
    def format_generate_dsym(dsym);                          EMPTY; end
    def format_linking(file, build_variant, arch);           EMPTY; end
    def format_libtool(library);                             EMPTY; end
    def format_passing_test(suite, test, time);              EMPTY; end
    def format_failing_test(suite, test, time, file_path);   EMPTY; end
    def format_process_pch(file);                            EMPTY; end
    def format_phase_script_execution(script_name);          EMPTY; end
    def format_process_info_plist(file_name, file_path);     EMPTY; end
    def format_codesign(file);                               EMPTY; end
    def format_preprocess(file);                             EMPTY; end
    def format_pbxcp(file);                                  EMPTY; end
    def format_test_run_started(name);                       EMPTY; end
    def format_test_run_finished(name, time);                EMPTY; end
    def format_test_suite_started(name);                     EMPTY; end
    def format_test_summary(message, failures_per_suite);    EMPTY; end

    # COMPILER / LINKER ERRORS
    def format_compile_error(file_name, file_path, reason, line, cursor); EMPTY; end
    def format_error(message);                               EMPTY; end
    def format_linker_failure(message, symbol, reference);   EMPTY; end
  end

  class Formatter

    include ANSI
    include FormatMethods

    attr_reader :parser

    def initialize(use_unicode, colorize)
      @use_unicode = use_unicode
      @colorize = colorize
      @parser = Parser.new(self)
    end

    # Override if you want to catch something specific with your regex
    def pretty_format(text)
      parser.parse(text)
    end

    # If you want to print inline, override #optional_newline with ''
    def optional_newline
      "\n"
    end

    def use_unicode?
      !!@use_unicode
    end

    # Will be printed by default. Override with '' if you don't want summary
    def format_test_summary(executed_message, failures_per_suite)
      failures = format_failures(failures_per_suite)
      final_message = failures.empty? ? green(executed_message) : red(executed_message)

      text = [failures, final_message].join("\n\n\n").strip
      "\n\n#{text}"
    end

    def format_linker_failure(message, symbol, reference)
      "#{red(message)}\n> Symbol: #{symbol}\n> Referenced from: #{reference}"
    end


    private

    def format_failures(failures_per_suite)
      failures_per_suite.map do |suite, failures|
        formatted_failures = failures.map do |f|
          "  #{f[:test_case]}, #{red(f[:reason])}\n  #{cyan(f[:file])}"
        end.join("\n\n")

        "\n#{suite}\n#{formatted_failures}"
      end.join("\n")
    end

  end
end

