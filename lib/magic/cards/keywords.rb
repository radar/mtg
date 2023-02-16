module Magic
  module Cards
    module Keywords
      class Keyword
      end

      DEATHTOUCH = Class.new(Keyword)
      DEFENDER = Class.new(Keyword)
      DOUBLE_STRIKE = Class.new(Keyword)
      FIRST_STRIKE = Class.new(Keyword)
      FLYING = Class.new(Keyword)
      HASTE = Class.new(Keyword)
      HEXPROOF = Class.new(Keyword)
      INDESTRUCTIBLE = Class.new(Keyword)
      LIFELINK = Class.new(Keyword)
      REACH = Class.new(Keyword)
      SKULK = Class.new(Keyword)
      TRAMPLE = Class.new(Keyword)
      VIGILANCE = Class.new(Keyword)

      class Toxic < Keyword
        attr_reader :amount
        def initialize(amount)
          @amount = amount
        end
      end

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
        @keyword_grants = []
      end

      class KeywordGrant
        attr_reader :keyword, :until_eot

        def initialize(keyword:, until_eot:)
          @keyword = keyword
          @until_eot = until_eot
        end

        def until_eot?
          @until_eot
        end
      end

      def grant_keyword(keyword, until_eot: false)
        @keyword_grants << KeywordGrant.new(keyword: keyword, until_eot: until_eot)
      end

      def remove_keyword_grant(grant)
        @keyword_grants.delete(grant)
      end

      def has_keyword?(keyword)
        keywords.any? { |kw| kw.is_a?(keyword) } ||
        keywords.include?(keyword) ||
          keyword_grants.map(&:keyword).include?(keyword) ||
          attachments.flat_map(&:keyword_grants).include?(keyword)
      end

      def hexproof?
        has_keyword?(Keywords::HEXPROOF)
      end

      def flying?
        has_keyword?(Keywords::FLYING)
      end

      def deathtouch?
        has_keyword?(Keywords::DEATHTOUCH)
      end

      def defender?
        has_keyword?(Keywords::DEFENDER)
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

      def trample?
        has_keyword?(Keywords::TRAMPLE)
      end

      def indestructible?
        has_keyword?(Keywords::INDESTRUCTIBLE)
      end
    end
  end
end
