module Magic
  module Cards
    SylvanLibrary = Enchantment("Sylvan Library") do
      cost generic: 1, green: 1
    end

    class SylvanLibrary < Enchantment
      class DrawTrigger < TriggeredAbility
        def should_perform?
          event.is_a?(Events::DrawStep) && event.player == controller
        end

        def call
          2.times { controller.draw! }
        end
      end

      def event_handlers
        { Events::DrawStep => DrawTrigger }
      end
    end
  end
end