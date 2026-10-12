module Magic
  module Events
    # An effect gave +target+ the keyword +keyword+ (a Magic::Cards::Keywords constant; #name is its text).
    class KeywordGranted < Base
      attr_reader :target, :keyword

      def initialize(source:, target:, keyword:)
        @target = target
        @keyword = keyword
        super(source: source)
      end

      def inspect
        "#<Events::KeywordGranted target: #{target.name}, keyword: #{keyword}>"
      end
    end
  end
end
