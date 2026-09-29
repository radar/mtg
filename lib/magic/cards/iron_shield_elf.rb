module Magic
  module Cards
    class IronShieldElf < Creature
      card_name "Iron-Shield Elf"
      cost generic: 1, black: 1
      creature_type "Elf Warrior"
      power 3
      toughness 1

      # "Discard a card: This creature gains indestructible until end of turn. Tap it."
      class ProtectAbility < Magic::ActivatedAbility
        costs "Discard a card"

        def resolve!
          source.grant_indestructible!
          source.tap!
        end
      end

      def activated_abilities = [ProtectAbility]
    end
  end
end
