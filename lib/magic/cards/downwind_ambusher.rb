module Magic
  module Cards
    DownwindAmbusher = Creature("Downwind Ambusher") do
      cost generic: 3, black: 1
      creature_type("Skunk Assassin")
      keywords :flash
      power 4
      toughness 2
    end

    class DownwindAmbusher < Creature
      # When this creature enters, choose one -- target creature an opponent controls gets -1/-1 until end of
      # turn; or destroy target creature an opponent controls that was dealt damage this turn.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def initialize(actor:, mode:)
            @mode = mode
            super(actor: actor)
          end

          def choices
            opposing = battlefield.not_controlled_by(controller).creatures
            return opposing unless @mode == :destroy

            damaged = game.current_turn.events.select { _1.is_a?(Events::DamageDealt) }.map(&:target)
            opposing.select { damaged.include?(_1) }
          end

          def choice_amount = 1

          def resolve!(target:)
            if @mode == :shrink
              pump(target, -1, -1)
            else
              trigger_effect(:destroy_target, target: target)
            end
          end
        end

        class ModeChoice < Magic::Choice
          def choices = %i[shrink destroy]

          def resolve!(mode:)
            raise ArgumentError, "choose :shrink or :destroy" unless choices.include?(mode)

            choice = TargetChoice.new(actor: actor, mode: mode)
            game.add_choice(choice) if choice.choices.any?
          end
        end

        def call
          game.choices.add(ModeChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
