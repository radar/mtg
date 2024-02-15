module Magic
  module Cards
    class IgneousCur < Creature
      cost "{1}{R}"
      creature_type "Elemental Dog"
      power 1
      toughness 2

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{1}{R}"

        def resolve!
          source.modify_power(2)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
