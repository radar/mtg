module Magic
  module Cards
    IngeniousLeonin = Creature("Ingenious Leonin") do
      cost generic: 4, white: 1
      creature_type("Cat Soldier")
      power 4
      toughness 4
    end

    class IngeniousLeonin < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{3}{W}"

        def target_choices
          (battlefield.controlled_by(controller).creatures.attacking - [source])
        end

        def resolve!(target:)
          trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 1)
          if target.type?("Cat")
            trigger_effect(:grant_keyword, target: target, keyword: :first_strike)
          end
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
