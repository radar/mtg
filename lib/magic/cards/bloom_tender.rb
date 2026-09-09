module Magic
  module Cards
    BloomTender = Creature("Bloom Tender") do
      cost generic: 1, green: 1
      creature_type "Elf Druid"
      power 1
      toughness 1
    end

    class BloomTender < Creature
      class ManaAbility < Magic::TapManaAbility
        def resolve!
          colors = controller.permanents.flat_map(&:colors).uniq
          controller.add_mana(colors.to_h { |color| [color, 1] })
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end