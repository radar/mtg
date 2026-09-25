module Magic
  module Cards
    RooftopPercher = Creature("Rooftop Percher") do
      type T::Creature, T::Creatures["Shapeshifter"]
      cost generic: 5
      power 3
      toughness 3
      keywords :flying, :changeling
    end

    class RooftopPercher < Creature
      class ExileChoice < Magic::Choice
        def choices
          game.graveyard_cards
        end

        def resolve!(targets:)
          raise ArgumentError, "at most two cards may be chosen" if targets.size > 2

          targets.each { |target| trigger_effect(:exile, target: target) }
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          choice = RooftopPercher::ExileChoice.new(actor: actor)
          game.choices.add(choice) if choice.choices.any?
          actor.trigger_effect(:gain_life, life: 3)
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
