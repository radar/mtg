module Magic
  class Token
    include Cards::Shared::Events
    include Cards::Shared::Types

    attr_reader :game, :owner, :name, :type_line, :keywords, :keyword_grants, :protections

    KEYWORDS = []
    PROTECTIONS = []

    class << self
      def create(name, &block)
        token = Class.new(Token, &block)
        token.const_set(:NAME, name)
        token
      end

      def power(power)
        const_set(:POWER, power)
      end

      def toughness(power)
        const_set(:TOUGHNESS, power)
      end

      def colors(colors)
        const_set(:COLORS, [*colors])
      end

      def keywords(*keywords)
        const_set(:KEYWORDS, Keywords[*keywords])

        include Cards::KeywordHandlers::Prowess if keywords.include?(:prowess)
      end
    end

    def initialize(game:, owner:)
      @name = self.class::NAME
      @type_line = self.class::TYPE_LINE
      @keywords = self.class::KEYWORDS
      @keyword_grants = []
      @protections = self.class::PROTECTIONS
      @owner = owner
      @game = game
    end

    def zone=(zone)
      @zone = zone
    end

    def resolve!(**args)
      Permanent.resolve(game: game, card: self, **args)
    end

    def base_power
      self.class::POWER
    end

    def base_toughness
      self.class::TOUGHNESS
    end

    def colors
      self.class.const_defined?(:COLORS) ? self.class::COLORS : []
    end

    def multi_colored?
      colors.count > 1
    end

    def colorless?
      colors.count == 0
    end

    def receive_notification(...)
    end

    def static_abilities
      []
    end

    def replacement_effects
      {}
    end

    def etb_triggers
      []
    end

    def ltb_triggers
     []
    end

    def death_triggers
      []
    end

    def types
      type_line.scan(/\w+/)
    end

    def permanent?
      true
    end

    def token?
      true
    end

    def card
      self
    end
  end
end
