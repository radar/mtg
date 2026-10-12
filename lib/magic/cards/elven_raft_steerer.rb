module Magic
  module Cards
    ElvenRaftSteerer = Creature("Elven Raft-Steerer") do
      cost generic: 2, blue: 1
      creature_type("Elf Pilot")
      power 3
      toughness 2
    end

    class ElvenRaftSteerer < Creature
      # Landfall -- Whenever a land you control enters, choose one --
      # Tap target creature an opponent controls. / Untap target creature you control.
      class TargetChoice < Magic::Choice::Targeted
        def initialize(actor:, mode:)
          @mode = mode
          super(actor: actor)
        end

        def choices
          @mode == ModeChoice::TAP ? battlefield.not_controlled_by(controller).creatures : battlefield.controlled_by(controller).creatures
        end

        def choice_amount = 1

        def resolve!(target:)
          @mode == ModeChoice::TAP ? trigger_effect(:tap, target: target) : target.untap!
        end
      end

      class ModeChoice < Magic::Choice
        TAP = :tap
        UNTAP = :untap

        def modes = { TAP => "Tap target creature an opponent controls", UNTAP => "Untap target creature you control" }

        def resolve!(mode:)
          raise ArgumentError, "unknown mode #{mode.inspect}" unless [TAP, UNTAP].include?(mode)

          choice = TargetChoice.new(actor: actor, mode: mode)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform? = you?

        def call
          game.choices.add(ModeChoice.new(actor: actor))
        end
      end

      def event_handlers = super.merge(Events::Landfall => LandfallTrigger)
    end
  end
end
