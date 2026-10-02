module Magic
  module Cards
    FanaticalFirebrand = Creature("Fanatical Firebrand") do
      cost red: 1
      creature_type("Goblin Pirate")
      keywords :haste
      power 1
      toughness 1
    end

    class FanaticalFirebrand < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{T}, Sacrifice {this}"

        def target_choices
          game.any_target
        end

        def resolve!(target:)
          trigger_effect(:deal_damage, target: target, damage: 1)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
