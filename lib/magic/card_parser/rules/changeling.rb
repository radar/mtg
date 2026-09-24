# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "Changeling" (this object is every creature type). The engine models it as
      # Abilities::Static::Changeling, which Card#types consults in every zone, so the card
      # lists that class itself rather than a subclass.
      class Changeling < Data.define
        include Rule

        def self.parse(line)
          new if line.match?(/\AChangeling\z/i)
        end

        def hook = :static_abilities
        def class_reference = "Abilities::Static::Changeling"
      end
    end
  end
end
