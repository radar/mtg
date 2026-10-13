module Magic
  module Cards
    FearOfImmobility = Creature("Fear of Immobility") do
      enchantment_creature_type "Nightmare"
      cost generic: 4, white: 1
      power 4
      toughness 4
    end

    class FearOfImmobility < Creature
      # "When this creature enters, tap up to one target creature. If an opponent controls that creature, put a
      # stun counter on it."
      class TapChoice < Magic::Choice::Targeted
        def choices = battlefield.creatures

        def choice_amount = 1

        def resolve!(target:)
          tap_permanent(target)
          return if target.controller == controller

          add_counter("stun", to: target)
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          choice = TapChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
