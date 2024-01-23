module Magic
  module Cards
    HellkitePunisher = Creature("Hellkite Punisher") do
      creature_type("Dragon")
      power 6
      toughness 6
      keywords :flying
    end

    class HellkitePunisher < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        def costs
          [Costs::Mana.new(red: 1)]
        end

        def resolve!
          source.modify_power(1)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
