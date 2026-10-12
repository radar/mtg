module Magic
  module Cards
    HandThatFeeds = Creature("Hand That Feeds") do
      cost generic: 1, red: 1
      creature_type "Mutant"
      power 2
      toughness 2
    end

    class HandThatFeeds < Creature
      # "Delirium — Whenever this creature attacks while there are four or more card types among cards in your
      # graveyard, it gets +2/+0 and gains menace until end of turn."
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor } && controller.graveyard.delirium?
        end

        def call
          pump(actor, 2, 0)
          trigger_effect(:grant_keyword, target: actor, keyword: :menace)
        end
      end

      def event_handlers = { Events::FinalAttackersDeclared => AttacksTrigger }
    end
  end
end
