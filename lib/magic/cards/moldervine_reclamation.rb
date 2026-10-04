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
          actor.trigger_effect(:gain_life, target: controller, life: 1)
          actor.trigger_effect(:draw_card, player: controller)
        end
      end

      def event_handlers
        { Events::CreatureDied => CreatureDiedTrigger }
      end
    end
  end
end
