module Mongify
  # This class is responsible for generating progress bars with status of mongify
  class Status
    class << self
      # Registers the ActiveSupport::Notifications for Mongify
      def register
        @bars = {}
        ActiveSupport::Notifications.subscribe(/^mongify\./) do |*args|
          event = ActiveSupport::Notifications::Event.new(*args)
          # puts event.name
          mongify, name, action = event.name.split('.', 3)
          case action
          when 'start'
            @bars[name] = ProgressBar.new(name.humanize, event.payload[:size] || 0)
          when 'inc'
            @bars[name].try(:inc)
          when 'finish'
            @bars[name].try(:finish)
          else
            UI.warn("Unknown Notification Event #{event.name}")
          end
        end
      end
    end
  end 
end