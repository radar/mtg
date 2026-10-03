module Magic
  module Cards
    SearslicerGoblin = Creature("Searslicer Goblin") do
      cost generic: 1, red: 1
      creature_type("Goblin Warrior")
      power 2
      toughness 1
    end

    class SearslicerGoblin < Creature
      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          controllers_end_step? && (game.current_turn.events.any? { |e| e.is_a?(Events::CreatureAttacked) && e.attacker.controller == controller })
        end

        GoblinToken = Token.create "Goblin" do
          creature_type "Goblin"
          power 1
          toughness 1
          colors :red
        end

        def call
          trigger_effect(:create_token, token_class: GoblinToken)
        end
      end

      def event_handlers = super.merge({ Events::BeginningOfEndStep => EndStepTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
