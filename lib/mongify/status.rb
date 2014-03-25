module Mongify
  # This class is responsible for generating progress bars with status of mongify
  class Status
    # List of known notifications
    NOTIFICATIONS = ['copy_data', 'copy_embedded', 'copy_polymorphic', 'update_references', 'remove_pre_mongified', 'set_last_updated_at']

    class << self
      #List of all the progress bars.
      def bars
        @bars ||= {}
      end
      #Add a new bar to the list of progress bars
      def add_bar(name, bar)
        self.bars[name] = bar
      end

      # Registers the ActiveSupport::Notifications for Mongify
      def register
        ActiveSupport::Notifications.subscribe(/^mongify\./) do |*args|
          event = ActiveSupport::Notifications::Event.new(*args)

          action_name = event.name.split('.', 2)[1]

          if Status::NOTIFICATIONS.include?(action_name)
            case event.payload[:action]
            when 'add'
              self.add_bar(action_name, ProgressBar.new(event.payload[:name], event.payload[:size]))
            when 'inc'
              self.bars[action_name].try(:inc)
            when 'finish'
              self.bars[action_name].try(:finish)
            else
              UI.warn("Unknown Notification Action #{event.payload[:action]}")
            end
            #puts event.payload.inspect
          else
            UI.warn("Unknown Notification Event #{action_name}")
          end
        end

        # Unregisters from {ActiveSupport::Notifications}
        def unregister
          ActiveSupport::Notifications.unsubscribe(/^mongify\./)
        end

        # Publish an notification event
        # This will publish the event as an mongify.[name]
        # @param [String] name Name of the notification
        # @param [Hash] payload to be sent with the notification
        # @return [nil]
        def publish(name, payload={})
          payload.reverse_merge!(:name => name.humanize, :action => 'inc')
          ActiveSupport::Notifications.instrument("mongify.#{name}", payload)
          nil
        end
      end
    end
  end
end