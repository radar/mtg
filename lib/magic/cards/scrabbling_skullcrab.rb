module Magic
  module Cards
    ScrabblingSkullcrab = Creature("Scrabbling Skullcrab") do
      cost blue: 1
      creature_type "Crab Skeleton"
      power 0
      toughness 3
    end

    class ScrabblingSkullcrab < Creature
      class MillChoice < Magic::Choice::Targeted
        def choices = game.players

        def choice_amount = 1

        def resolve!(target:)
          target.mill(2)
        end
      end

      # "Eerie -- Whenever an enchantment you control enters and whenever you fully unlock a Room, target player mills
      # two cards."
      class EerieTrigger < TriggeredAbility::Eerie
        def call
          game.add_choice(MillChoice.new(actor: actor))
        end
      end

      def event_handlers = EerieTrigger.handlers
    end
  end
end
