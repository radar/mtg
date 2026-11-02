module Magic
  module Cards
    UglkOfTheWhiteHand = Creature("Uglúk of the White Hand") do
      cost generic: 2, black: 1, red: 1
      legendary_creature_type "Orc Soldier"
      power 3
      toughness 3
    end

    class UglkOfTheWhiteHand < Creature
      # "Whenever another creature you control dies, put a +1/+1 counter on Uglúk. If that creature was a Goblin or
      # Orc, put two +1/+1 counters on Uglúk instead."
      class CreatureDiedTrigger < TriggeredAbility
        def should_perform?
          event.permanent != actor && event.controller == controller
        end

        def call
          dead = event.permanent
          amount = dead.type?("Goblin") || dead.type?("Orc") ? 2 : 1
          actor.add_counter("+1/+1", amount: amount)
        end
      end

      def event_handlers = { Events::CreatureDied => CreatureDiedTrigger }
    end
  end
end
