module Magic
  module Cards
    class EyeblightMassacre < Sorcery
      card_name "Eyeblight Massacre"
      cost generic: 2, black: 2

      def resolve!
        creatures.excluding_type("Elf").each do |creature|
          pump(creature, -2, -2)
        end
      end
    end
  end
end
