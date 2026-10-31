module Magic
  module Cards
    BillThePony = Creature("Bill the Pony") do
      cost generic: 3, white: 1
      legendary_creature_type "Horse"
      power 1
      toughness 4
    end

    class BillThePony < Creature
      # "When Bill the Pony enters, create two Food tokens."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          create_token(token: Tokens::Food, amount: 2)
        end
      end

      # "Sacrifice a Food: Until end of turn, target creature you control assigns combat damage equal to its toughness
      # rather than its power."
      class ToughnessDamageAbility < Magic::ActivatedAbility
        costs "Sacrifice a Food"

        def single_target? = true

        def target_choices = controller.creatures

        def resolve!(target:)
          target.assign_toughness_damage_this_turn!
        end
      end

      def etb_triggers = [EntersTrigger]

      def activated_abilities = [ToughnessDamageAbility]
    end
  end
end
