module Magic
  module Cards
    TurnInsideOut = Instant("Turn Inside Out") do
      cost red: 1
    end

    class TurnInsideOut < Instant
      # "When it dies this turn, manifest dread." The spell's controller manifests dread, not the creature's.
      class DiesTrigger < TriggeredAbility
        def should_perform?
          this?
        end

        def call
          Magic::Choice::ManifestDread.perform(actor: actor, player: actor.state.delete(:turn_inside_out_player))
        end
      end

      def single_target? = true

      def target_choices
        battlefield.creatures
      end

      # "Target creature gets +3/+0 until end of turn. When it dies this turn, manifest dread."
      def resolve!(target:)
        pump(target, 3, 0)
        target.state[:turn_inside_out_player] = controller
        target.register_turn_trigger(Events::CreatureDied, DiesTrigger)
      end
    end
  end
end
