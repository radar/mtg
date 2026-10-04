module Magic
  module Cards
    GateColossus = Creature("Gate Colossus") do
      cost generic: 8
      artifact_creature_type("Construct")
      power 8
      toughness 8
    end

    class GateColossus < Creature
      def self_mana_cost_adjustment
        controller = self.controller || owner
        { generic: -> { -controller.permanents.by_type("Gate").count } }
      end

      def can_be_blocked?(blocker) = blocker.power > 2

      class GateEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def self.works_from_graveyard? = true

        def should_perform?
          actor.zone&.graveyard? && (under_your_control? && event.permanent.type?("Gate"))
        end

        class MayChoice < Magic::Choice::May
          def resolve!
            actor.move_zone!(to: actor.owner.library) if actor.zone&.graveyard?
          end
        end

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def event_handlers = super.merge({ Events::EnteredTheBattlefield => GateEntersTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
