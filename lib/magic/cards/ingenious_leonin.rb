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
          add_counter("+1/+1", to: target)
          if target.type?("Cat")
            give_keyword(target, :first_strike)
          end
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
