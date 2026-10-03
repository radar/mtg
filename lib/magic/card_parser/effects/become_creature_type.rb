# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "~ becomes a Werewolf." (Mild-Mannered Librarian): its creature types are replaced by this one, for good
      # (`Permanent#become_creature_type!`). Not the "in addition to its other types" or "until end of turn" forms.
      class BecomeCreatureType < Data.define(:type)
        include Effect

        LINE = /\A~ becomes an? (?<type>[A-Z][\w-]*)\.?\z/

        def self.parse(text)
          new(type: $~[:type]) if (m = LINE.match(text)) && Types::Creatures.values.include?(m[:type])
        end

        def resolve_call = "#{THIS}.become_creature_type!(T::Creatures[#{type.inspect}])"
      end
    end
  end
end
