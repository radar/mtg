module Magic
  module Cards
    KudoKingAmongBears = Creature("Kudo, King Among Bears") do
      legendary_creature_type "Bear"
      cost green: 1, white: 1
      power 2
      toughness 2
    end

    class KudoKingAmongBears < Creature
      # "Other creatures have base power and toughness 2/2..."
      class BaseTwoTwo < Abilities::Static::CharacteristicSetting
        sets_base_power_and_toughness 2, 2

        def applicable_targets = battlefield.creatures.to_a - [source]
      end

      # "...and are Bears in addition to their other types."
      class BearTypes < Abilities::Static::TypeGrant
        type_grants "Bear"

        def applicable_targets = battlefield.creatures.to_a - [source]
      end

      def static_abilities = [BaseTwoTwo, BearTypes]
    end
  end
end
