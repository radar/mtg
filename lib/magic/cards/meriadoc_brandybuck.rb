module Magic
  module Cards
    MeriadocBrandybuck = Creature("Meriadoc Brandybuck") do
      cost generic: 1, green: 1
      legendary_creature_type "Halfling Citizen"
      power 2
      toughness 2
    end

    class MeriadocBrandybuck < Creature
      # "Whenever one or more Halflings you control attack a player, create a Food token." One Food however many
      # Halflings attack.
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && event.attacks.any? do |attack|
            attack.attacker.controller == controller && attack.attacker.type?("Halfling") && attack.target.player?
          end
        end

        def call
          create_token(token: Tokens::Food)
        end
      end

      def event_handlers = { Events::FinalAttackersDeclared => AttacksTrigger }
    end
  end
end
