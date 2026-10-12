module Magic
  module Effects
    class GrantKeyword < TargetedEffect
      attr_reader :keyword

      def initialize(keyword:, **args)
        super(**args)
        @keyword = keyword
      end


      def resolve!
        granted = Keywords.one(keyword)
        target.grant_keyword(granted)
        game.notify!(Events::KeywordGranted.new(source: source, target: target, keyword: granted))
      end
    end
  end
end
