module Magic
  module Cards
    WosePathfinder = Creature("Wose Pathfinder") do
      cost generic: 1, green: 1
      creature_type "Human Shaman"
      power 1
      toughness 1
    end

    class WosePathfinder < Creature
      # "{T}: Add one mana of any color."
      class ManaAbility < Magic::TapManaAbility
        choices :all
      end

      # "{6}{G}, {T}: Another target creature gets +3/+3 and gains trample until end of turn."
      class PumpAbility < Magic::ActivatedAbility
        costs "{6}{G}, {T}"

        def single_target? = true

        def target_choices = battlefield.creatures.reject { _1 == source }

        def resolve!(target:)
          pump(target, 3, 3)
          give_keyword(target, :trample)
        end
      end

      def activated_abilities = [ManaAbility, PumpAbility]
    end
  end
end
