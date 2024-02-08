module Magic
  module Effects
    class GrantKeyword < TargetedEffect
      attr_reader :keyword

      def initialize(keyword:, **args)
        super(**args)
        @keyword = keyword
      end


      def resolve!
        target.grant_keyword(Keywords.one(keyword))
      end
    end
  end
end
