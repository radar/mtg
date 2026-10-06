module Magic
  module Cards
    FuriousRise = Enchantment("Furious Rise") do
      cost generic: 2, red: 1
    end

    class FuriousRise < Enchantment
      # "At the beginning of your end step, if you control a creature with power 4 or greater, exile the top card
      # of your library. You may play that card until you exile another card with this enchantment."
      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          controllers_end_step? && controller.creatures.any? { |creature| creature.power >= 4 }
        end

        def call
          card = controller.library.first
          return unless card

          trigger_effect(:exile, target: card)
          actor.exiled_cards.clear
          actor.exiled_cards << card
        end
      end

      # Only the latest card exiled with this enchantment can be played.
      class ExiledCardPermission < StaticAbility
        def permits_casting_from_exile?(card)
          card.owner == controller && @source.exiled_cards.last == card
        end
      end

      def static_abilities = [ExiledCardPermission]

      def event_handlers = { Events::BeginningOfEndStep => EndStepTrigger }
    end
  end
end
