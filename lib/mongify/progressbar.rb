#
# Ruby/ProgressBar - a text progress bar library
#
# Copyright (C) 2001-2005 Satoru Takabayashi <satoru@namazu.org>
#     All rights reserved.
#     This is free software with ABSOLUTELY NO WARRANTY.
#
# You can redistribute it and/or modify it under the terms
# of Ruby's license.
#
# This has been modified by
#   Andrew Kalek
#   Anlek Consulting
#   http://anlek.com

module Mongify
  # Progress bar used to display results
  class ProgressBar
    #Progress bar version
    VERSION = "0.9.1"

    def initialize (title, total)
      @title = title
      @total = total
      @out = Mongify::Configuration.out_stream
      @terminal_width = 80
      @bar_mark = "o"
      @current = 0
      @previous = 0
      @finished_p = false
      @start_time = Time.now
      @previous_time = @start_time
      @title_width = 37
      @format = "%-#{@title_width}s %s %3d%% %s %s"
      @format_arguments = [:title, :count, :percentage, :bar, :stat]
      clear
      show
    end
    attr_reader   :title
    attr_reader   :current
    attr_reader   :total
    attr_accessor :start_time

    #######
    private
    #######

    # Formatting for the actual bar
    def fmt_bar
      bar_width = do_percentage * @terminal_width / 100
      sprintf("|%s%s|",
              @bar_mark * bar_width,
              " " *  (@terminal_width - bar_width))
    end

    # Formatting for the percentage
    def fmt_percentage
      do_percentage
    end

    # Formatting for the stat (time left or time taken to complete)
    def fmt_stat
      if @finished_p then elapsed else eta end
    end

    # Formatting for file transfer
    def fmt_stat_for_file_transfer
      if @finished_p then
        sprintf("%s %s %s", bytes, transfer_rate, elapsed)
      else
        sprintf("%s %s %s", bytes, transfer_rate, eta)
      end
    end

    # Formatting for title
    def fmt_title
      @title[0,(@title_width - 1)] + ":"
    end

    # Formatting for count (x/y)
    def fmt_count
      sprintf('%13s', "(#{@current}/#{@total})")
    end

    # Converts bytes to kb, mb or gb
    def convert_bytes (bytes)
      if bytes < 1024
        sprintf("%6dB", bytes)
      elsif bytes < 1024 * 1000 # 1000kb
        sprintf("%5.1fKB", bytes.to_f / 1024)
      elsif bytes < 1024 * 1024 * 1000  # 1000mb
        sprintf("%5.1fMB", bytes.to_f / 1024 / 1024)
      else
        sprintf("%5.1fGB", bytes.to_f / 1024 / 1024 / 1024)
      end
    end

    # Returns the transfer rate
    # works only with file transfer
    def transfer_rate
      bytes_per_second = @current.to_f / (Time.now - @start_time)
      sprintf("%s/s", convert_bytes(bytes_per_second))
    end

    # Gets current byte count
    def bytes
      convert_bytes(@current)
    end

    # Gets formatting for time
    def format_time (t)
      t = t.to_i
      sec = t % 60
      min  = (t / 60) % 60
      hour = t / 3600
      sprintf("%02d:%02d:%02d", hour, min, sec);
    end

    # ETA stands for Estimated Time of Arrival.
    def eta
      if @current == 0
        "ETA:  --:--:--"
      else
        elapsed = Time.now - @start_time
        eta = elapsed * @total / @current - elapsed;
        sprintf("ETA:  %s", format_time(eta))
      end
    end

    # Returns elapsed time
    def elapsed
      elapsed = Time.now - @start_time
      sprintf("Time: %s", format_time(elapsed))
    end

    # Returns end of line
    # @return [String] "\n" or "\r"
    def eol
      if @finished_p then "\n" else "\r" end
    end

    # Calculates percentage
    # @return [Number] the percentage
    def do_percentage
      if @total.zero?
        100
      else
        @current  * 100 / @total
      end
    end

    # Gets the width of the terminal window
    def get_width
      UI.terminal_helper.output_cols
    end

    # Draws the bar
    def show
      return unless @out
      arguments = @format_arguments.map {|method|
        method = sprintf("fmt_%s", method)
        send(method)
      }
      line = sprintf(@format, *arguments)

      width = get_width
      if line.length == width - 1
        @out.print(line + eol)
        @out.flush
      elsif line.length >= width
        @terminal_width = [@terminal_width - (line.length - width + 1), 0].max
        if @terminal_width == 0 then @out.print(line + eol) else show end
      else # line.length < width - 1
        @terminal_width += width - line.length + 1
        show
      end
      @previous_time = Time.now
    end

    # Checks if it's needed, shows if it's so
    def show_if_needed
      if @total.zero?
        cur_percentage = 100
        prev_percentage = 0
      else
        cur_percentage  = (@current  * 100 / @total).to_i
        prev_percentage = (@previous * 100 / @total).to_i
      end

      # Use "!=" instead of ">" to support negative changes
      if cur_percentage != prev_percentage ||
          Time.now - @previous_time >= 1 || @finished_p
        show
      end
    end

    public
    # Clear's line
    def clear
      return unless @out
      @out.print "\r"
      @out.print(" " * (get_width - 1))
      @out.print "\r"
    end

    # Marks finished
    def finish
      @current = @total
      @finished_p = true
      show
    end

    # Returns if the bar is finished
    def finished?
      @finished_p
    end

    # Sets bar to file trasfer mode
    def file_transfer_mode
      @format_arguments = [:title, :percentage, :bar, :stat_for_file_transfer]
    end

    # Allows format to be re/defined
    def format= (format)
      @format = format
    end

    # Allows to change the arguments of items that are shown
    def format_arguments= (arguments)
      @format_arguments = arguments
    end

    # halts drawing of bar
    def halt
      @finished_p = true
      show
    end

    # Incremets bar
    # @return [Integer] current bar frame
    def inc (step = 1)
      @current += step
      @current = @total if @current > @total
      show_if_needed
      @previous = @current
    end

    # Allows you to set bar frame
    # @return [Integer] current bar frame
    def set (count)
      if count < 0 || count > @total
        raise "invalid count: #{count} (total: #{@total})"
      end
      @current = count
      show_if_needed
      @previous = @current
    end

    # Returns string representation of this object
    def inspect
      "#<ProgressBar:#{@current}/#{@total}>"
    end
  end

  # Same as progress bar but this counts the progress backwards from 100% to 0
  class ReversedProgressBar < ProgressBar
    # Calculates the percentage
    def do_percentage
      100 - super
    end
  end
end
