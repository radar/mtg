module Magic
  module Cards
    BoggartCursecrafter = Creature("Boggart Cursecrafter") do
      cost black: 1, red: 1
      creature_type("Goblin Warlock")
      keywords :deathtouch
      power 2
      toughness 3
    end

    class BoggartCursecrafter < Creature
      class TribalDiesTrigger < TriggeredAbility
        def should_perform?
          you? && event.permanent != actor && event.permanent.type?("Goblin")
        end

        def call
          game.opponents(controller).each { trigger_effect(:deal_damage, target: _1, damage: 1) }
        end
      end

      def event_handlers = { Events::CreatureDied => TribalDiesTrigger }
    end
  end
end
