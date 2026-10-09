module Magic
  module Cards
    StoneGiantOfHighPass = Creature("Stone-Giant of High Pass") do
      cost generic: 5, red: 2
      creature_type("Giant")
      power 7
      toughness 7
    end

    class StoneGiantOfHighPass < Creature
      StoneBoulderToken = Token.create "Stone Boulder" do
        type T::Artifact, T::Creature, T::Creatures["Wall"]
        power 3
        toughness 1
        keywords :defender
      end

      # "Whenever this creature enters or attacks, create a 3/1 colorless Wall artifact creature token with defender
      # named Stone Boulder."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:create_token, token_class: StoneBoulderToken)
        end
      end

      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        def call
          trigger_effect(:create_token, token_class: StoneBoulderToken)
        end
      end

      # "{2}{R}, Sacrifice an artifact: This creature deals 4 damage to any target."
      class DamageAbility < Magic::ActivatedAbility
        def costs
          [Costs::Mana.new("{2}{R}"), Costs::Sacrifice.new(source, controller.permanents.artifacts)]
        end

        def target_choices = game.any_target

        def resolve!(target:)
          trigger_effect(:deal_damage, target: target, damage: 4)
        end
      end

      def etb_triggers = [EntersTrigger]
      def activated_abilities = [DamageAbility]

      def event_handlers = super.merge({ Events::FinalAttackersDeclared => AttacksTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
