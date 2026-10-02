# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Until end of turn, ~ becomes a Dragon in addition to its other types and gains flying." /
      # "~ becomes a Dragon in addition to its other types until end of turn." (`Permanent#add_types`,
      # plus a keyword grant per keyword; both last until end of turn.)
      class BecomeTypeInAddition < Data.define(:type, :keywords)
        include Effect

        LINE = /\A(?:Until end of turn, )?~ becomes an? (?<type>[A-Z][\w-]*) in addition to its other types(?: and gains (?<keywords>[\w ,]+?))?(?: until end of turn)?\.?\z/

        def self.parse(text)
          return unless (m = LINE.match(text)) && Types::Creatures.values.include?(m[:type])

          keywords = m[:keywords] ? Rules::Keywords.phrase(m[:keywords]) : []
          new(type: m[:type], keywords:) if keywords
        end

        def resolve_call
          lines = ["#{THIS}.add_types(T::Creatures[#{type.inspect}])"]
          keywords.each { lines << "trigger_effect(:grant_keyword, target: #{THIS}, keyword: #{_1.inspect})" }
          lines.join("\n")
        end
      end
    end
  end
end
