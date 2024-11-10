module Magic
  module Abilities
    module Static
      class KeywordGrant < StaticAbility
        attr_reader :source, :applicable_targets

        def self.keyword_grants(*keywords)
          define_method(:keyword_grants) { keywords }
        end

        def apply_to(permanent)
          if applicable_targets.include?(permanent)
            keyword_grants
          else
            []
          end
        end

        def applies_to?(target)
          applicable_targets.include?(target)
        end
      end
    end
  end
end
