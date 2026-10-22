module Magic
  module Cards
    PetrifyingMeddler = Creature("Petrifying Meddler") do
      cost generic: 4, blue: 1
      creature_type "Eldrazi"
      power 4
      toughness 5
      keywords :devoid, :reach
    end

    class PetrifyingMeddler < Creature
      # "...tap up to one target creature and put a stun counter on it."
      class TargetChoice < Magic::Choice::Targeted
        def choices = battlefield.creatures

        def choice_amount = 0..1

        def resolve!(target:)
          tap_permanent(target)
          add_counter("stun", to: target)
        end
      end

      # "When you cast this spell, ..."
      class CastTrigger < TriggeredAbility::CastThisSpell
        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def cast_triggers = [CastTrigger]
    end
  end
end
