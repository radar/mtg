module Magic
  module Cards
    MoldervineReclamation = Enchantment("Moldervine Reclamation") do
      cost "{3}{B}{G}"
    end

    class MoldervineReclamation < Enchantment
      class CreatureDiedTrigger < TriggeredAbility
        def should_perform?
          event.controller == controller
        end

        def call
          actor.gain_life(1)
          draw_card
        end
      end

      def event_handlers
        { Events::CreatureDied => CreatureDiedTrigger }
      end
    end
  end
end
