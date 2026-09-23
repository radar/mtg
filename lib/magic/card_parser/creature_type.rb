# frozen_string_literal: true

module Magic
  class CardParser
    module CreatureType
      # "Elves" => "Elf", "Wolves" => "Wolf", "Goblins" => "Goblin"
      def self.singular(plural)
        candidates = [plural, plural.delete_suffix("s"), plural.delete_suffix("es"),
                      plural.sub(/ves\z/, "f"), plural.sub(/ves\z/, "fe"), plural.sub(/ies\z/, "y")]
        candidates.find { |c| Magic::Types::Creatures.values.include?(c) } or
          raise UnsupportedCard, "unknown creature type: #{plural}"
      end
    end
  end
end
