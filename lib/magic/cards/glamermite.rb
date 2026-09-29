module Magic
  module Cards
    Glamermite = Creature("Glamermite") do
      cost generic: 2, blue: 1
      creature_type("Faerie Rogue")
      power 2
      toughness 2
      keywords :flash, :flying
    end

    class Glamermite < Creature
      # When this creature enters, choose one — Tap target creature. / Untap target creature.
      class TargetChoice < Magic::Choice::Targeted
        def initialize(actor:, mode:)
          @mode = mode
          super(actor: actor)
        end

        def choices = battlefield.creatures

        def choice_amount = 1

        def resolve!(target:)
          @mode == ModeChoice::TAP ? trigger_effect(:tap, target: target) : target.untap!
        end
      end

      class ModeChoice < Magic::Choice
        TAP = :tap
        UNTAP = :untap

        def resolve!(mode:)
          raise ArgumentError, "unknown mode #{mode.inspect}" unless [TAP, UNTAP].include?(mode)

          choice = TargetChoice.new(actor: actor, mode: mode)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(ModeChoice.new(actor: actor))
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
