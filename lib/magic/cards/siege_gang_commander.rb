module Magic
  module Cards
    SiegeGangCommander = Creature("Siege-Gang Commander") do
      cost generic: 3, red: 2
      creature_type "Goblin"
      power 2
      toughness 2
    end

    class SiegeGangCommander < Creature
      GoblinToken = Token.create "Goblin" do
        creature_type "Goblin"
        power 1
        toughness 1
        colors :red
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          actor.create_token(token_class: GoblinToken, amount: 3)
        end
      end

      # "{1}{R}, Sacrifice a Goblin: This creature deals 2 damage to any target."
      class DamageAbility < Magic::ActivatedAbility
        costs "{1}{R}, Sacrifice a Goblin"

        def target_choices = game.any_target

        def resolve!(target:)
          trigger_effect(:deal_damage, damage: 2, target: target)
        end
      end

      def etb_triggers = [EntersTrigger]
      def activated_abilities = [DamageAbility]
    end
  end
end
