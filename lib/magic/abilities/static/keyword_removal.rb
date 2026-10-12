module Magic
  module Abilities
    module Static
      # "Equipped creature ... loses flying": removes keywords from its targets (applied after every grant).
      class KeywordRemoval < StaticAbility
        layer 6

        attr_reader :source, :applicable_targets

        def self.keyword_removals(*keywords)
          define_method(:keyword_removals) { keywords }
        end

        def applies_to?(target)
          applicable_targets.include?(target)
        end
      end
    end
  end
end
