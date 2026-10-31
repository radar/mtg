module Magic
  module Cards
    WargRider = Creature("Warg Rider") do
      cost generic: 4, black: 1
      creature_type "Orc Warrior"
      keywords :menace
      power 4
      toughness 3
    end

    class WargRider < Creature
      # "Other Orcs and Goblins you control have menace."
      class OrcsAndGoblinsMenace < Abilities::Static::KeywordGrant
        keyword_grants Keywords::MENACE
        applicable_targets do
          source.controller.creatures.select { _1 != source && (_1.type?("Orc") || _1.type?("Goblin")) }
        end
      end

      # "At the beginning of combat on your turn, amass Orcs 2."
      class CombatTrigger < TriggeredAbility
        def should_perform? = event.active_player == controller

        def call
          Magic::Amass.call(source: actor, controller: controller, amount: 2, subtype: "Orc")
        end
      end

      def static_abilities = [OrcsAndGoblinsMenace]

      def event_handlers = { Events::BeginningOfCombat => CombatTrigger }
    end
  end
end
