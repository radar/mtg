module Magic
  module Cards
    RazorkinHordecaller = Creature("Razorkin Hordecaller") do
      cost generic: 4, red: 1
      creature_type("Human Clown Berserker")
      keywords :haste
      power 4
      toughness 4
    end

    class RazorkinHordecaller < Creature
      class YouAttackTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && event.attacks.any?
        end

        GremlinToken = Token.create "Gremlin" do
          creature_type "Gremlin"
          power 1
          toughness 1
          colors :red
        end

        def call
          trigger_effect(:create_token, token_class: GremlinToken)
        end
      end

      def event_handlers = super.merge({ Events::FinalAttackersDeclared => YouAttackTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
