module Magic
  module Permanents
    module Modifications
      class KeywordGrant < ContinuousEffect
        layer 6

        attr_reader :keyword_grant

        def initialize(keyword_grant:, until_eot:)
          @keyword_grant = keyword_grant
          super(until_eot: until_eot)
        end
      end
    end
  end
end
