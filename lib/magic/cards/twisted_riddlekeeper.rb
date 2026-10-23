module Magic
  module Cards
    TwistedRiddlekeeper = Creature("Twisted Riddlekeeper") do
      cost generic: 8
      creature_type "Eldrazi Sphinx"
      keywords :flying
      power 5
      toughness 5
    end

    class TwistedRiddlekeeper < Creature
      # Emerge {5}{C}{U}: cast by sacrificing a creature (`Actions::Cast#emerge`).
      def alternative_cost = Costs::Mana.new(generic: 5, colorless: 1, blue: 1)

      def emerge_from = "Creature"

      # When you cast this spell, tap up to two target permanents. Put a stun counter on each of them.
      class StunTrigger < TriggeredAbility::CastThisSpell
        class StunChoice < Magic::Choice::Targeted
          def choices = battlefield.permanents

          def choice_amount = 0..2

          def resolve!(targets:)
            Array(targets).first(2).each do |target|
              tap_permanent(target)
              add_counter("stun", to: target)
            end
          end
        end

        def call
          game.add_choice(StunChoice.new(actor: actor))
        end
      end

      def cast_triggers = [StunTrigger]
    end
  end
end
