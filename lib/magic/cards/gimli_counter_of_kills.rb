module Magic
  module Cards
    GimliCounterOfKills = Creature("Gimli, Counter of Kills") do
      cost generic: 3, red: 1
      legendary_creature_type "Dwarf Warrior"
      keywords :trample
      power 4
      toughness 3
    end

    class GimliCounterOfKills < Creature
      # "Whenever a creature an opponent controls dies, Gimli deals 1 damage to that creature's controller."
      class CreatureDiedTrigger < TriggeredAbility
        def should_perform? = event.controller != controller

        def call
          deal_damage(1, to: event.controller)
        end
      end

      def event_handlers = { Events::CreatureDied => CreatureDiedTrigger }
    end
  end
end
