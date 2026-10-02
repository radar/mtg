module Magic
  module Cards
    AnthemOfChampions = Enchantment("Anthem of Champions") do
      cost green: 1, white: 1
    end

    class AnthemOfChampions < Enchantment
      class CreaturesYouControlBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        applicable_targets { source.controller.creatures }
      end

      def static_abilities = [CreaturesYouControlBuff]
    end
  end
end
