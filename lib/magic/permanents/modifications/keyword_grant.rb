module Magic
  module Permanents
    module Modifications
      class KeywordGrant
        attr_reader :keyword_grant, :until_eot

        def initialize(keyword_grant:, until_eot:)
          @keyword_grant = keyword_grant
          @until_eot = until_eot
        end

        def until_eot?
          @until_eot
        end
      end
    end
  end
end
