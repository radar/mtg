module Magic
  module Cards
    class EyeblightMassacre < Sorcery
      card_name "Eyeblight Massacre"
      cost generic: 2, black: 2

      def resolve!
        creatures.excluding_type("Elf").each do |creature|
          trigger_effect(:modify_power_toughness, power: -2, toughness: -2, target: creature, until_eot: true)
        end
      end
    end
  end
end
