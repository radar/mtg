module Magic
  module Permanents
    module Modifications
      # "That permanent loses <keyword> until end of turn" (Soul Sear). Applied in layer 6 after the keywords are
      # gathered, so it removes the keyword wherever it came from.
      class KeywordRemoval < ContinuousEffect
        layer 6

        attr_reader :keyword_removal

        def initialize(keyword_removal:, until_eot:)
          @keyword_removal = keyword_removal
          super(until_eot: until_eot)
        end
      end
    end
  end
end
