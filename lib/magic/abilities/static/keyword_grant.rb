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

        # The keywords for one permanent; override for grants that depend on it
        # ("hexproof from each of its colors").
        def keyword_grants_for(_permanent)
          keyword_grants
        end

        def applies_to?(target)
          applicable_targets.include?(target)
        end
      end
    end
  end
end
