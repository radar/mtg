module Magic
  module Cards
    FearOfTheDark = Creature("Fear of the Dark") do
      cost generic: 4, black: 1
      enchantment_creature_type "Nightmare"
      power 5
      toughness 5
    end

    class FearOfTheDark < Creature
      # "Whenever this creature attacks, if defending player controls no Glimmer creatures, it gains menace and
      # deathtouch until end of turn."
      class AttacksTrigger < TriggeredAbility
        def attack = event.attacks.find { _1.attacker == actor }

        def defending_player
          target = attack.target
          target.respond_to?(:controller) ? target.controller : target
        end

        def should_perform?
          attack && defending_player.creatures.none? { _1.type?("Glimmer") }
        end

        def call
          give_keyword(actor, :menace)
          give_keyword(actor, :deathtouch)
        end
      end

      def event_handlers = { Events::FinalAttackersDeclared => AttacksTrigger }
    end
  end
end
