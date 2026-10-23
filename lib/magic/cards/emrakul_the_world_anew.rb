module Magic
  module Cards
    EmrakulTheWorldAnew = Creature("Emrakul, the World Anew") do
      legendary_creature_type "Eldrazi"
      cost generic: 12
      power 12
      toughness 12
      keywords :flying
    end

    class EmrakulTheWorldAnew < Creature
      # "Protection from spells and from permanents that were cast this turn."
      # A card that is not a permanent is a spell (or being cast as one: it leaves the hand only once cast).
      protections [Protection.new(condition: ->(card) { card.is_a?(Magic::Card) || (card.respond_to?(:cast_this_turn?) && card.cast_this_turn?) })]

      # "Madness--Pay six {C}."
      def madness_cost = { colorless: 6 }

      # "...gain control of all creatures target player controls."
      class TargetChoice < Magic::Choice::Targeted
        def choices = game.players

        def choice_amount = 1

        def resolve!(target:)
          battlefield.creatures.select { _1.controller == target }.each { _1.controller = controller }
        end
      end

      # "When you cast this spell, ..."
      class CastTrigger < TriggeredAbility::CastThisSpell
        def call
          game.add_choice(TargetChoice.new(actor: actor))
        end
      end

      # "When Emrakul leaves the battlefield, sacrifice all creatures you control."
      class LeavesTrigger < TriggeredAbility::LeaveTheBattlefield
        def call
          battlefield.creatures.select { _1.controller == controller }.each(&:sacrifice!)
        end
      end

      def cast_triggers = [CastTrigger]

      def ltb_triggers = [LeavesTrigger]
    end
  end
end
