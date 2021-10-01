module Magic
  module Cards
    module Keywords
      DEATHTOUCH = "Deathtouch".freeze
      DOUBLE_STRIKE = "Double strike".freeze
      FIRST_STRIKE = "First strike".freeze
      FLYING = "Flying".freeze
      HASTE = "Haste".freeze
      INDESTRUCTIBLE = "Indestructible".freeze
      LIFELINK = "Lifelink".freeze
      REACH = "Reach".freeze
      SKULK = "Skulk".freeze
      TRAMPLE = "Trample".freeze
      VIGILANCE = "Vigilance".freeze

      def self.[](*keywords)
        keywords.map do |keyword|
          const_get(keyword.upcase)
        end
      end

      def self.included(base)
        base.attr_reader :keyword_grants
        base.prepend(self)
      end

      def initialize(...)
        @keywords = self.class::KEYWORDS
        @keyword_grants = []
      end

      class KeywordGrant
        attr_reader :keyword, :until_eot

        def initialize(keyword:, until_eot:)
          @keyword = keyword
          @until_eot = until_eot
        end
      end

      def grant_keyword(keyword, until_eot:)
        @keyword_grants << KeywordGrant.new(keyword: keyword, until_eot: until_eot)
      end

      def has_keyword?(keyword)
        keywords.include?(keyword) || keyword_grants.map(&:keyword).include?(keyword)
      end

      def flying?
        has_keyword?(Keywords::FLYING)
      end

      def deathtouch?
        has_keyword?(Keywords::DEATHTOUCH)
      end

      def first_strike?
        has_keyword?(Keywords::FIRST_STRIKE)
      end

      def double_strike?
        has_keyword?(Keywords::DOUBLE_STRIKE)
      end

      def vigilant?
        has_keyword?(Keywords::VIGILANCE)
      end

      def lifelink?
        has_keyword?(Keywords::LIFELINK)
      end
    end
  end
end
