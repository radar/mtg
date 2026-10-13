module Magic
  module Cards
    BastionOfRemembrance = Enchantment("Bastion of Remembrance") do
      cost generic: 2, black: 1
    end

    class BastionOfRemembrance < Enchantment
      HumanSoldierToken = Token.create("Human Soldier") do
        creature_type "Human Soldier"
        power 1
        toughness 1
        colors :white
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          create_token(token:HumanSoldierToken)
        end
      end

      class CreatureDiedTrigger < TriggeredAbility
        def should_perform?
          event.controller == controller
        end

        def call
          opponents.each { |opponent| lose_life opponent, 1 }
          actor.gain_life(1)
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers
        { Events::CreatureDied => CreatureDiedTrigger }
      end
    end
  end
end