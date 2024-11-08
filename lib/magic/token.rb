module Magic
  class Token
    include Cards::Shared::Events
    include Cards::Shared::Types

    attr_reader :game, :owner, :name, :type_line, :keywords, :keyword_grants, :protections, :base_power, :base_toughness

    KEYWORDS = []
    PROTECTIONS = []

    class << self
      def create(name, &block)
        token = Class.new(Token, &block)
        token.const_set(:NAME, name)
        token
      end

      def token_name(name)
        const_set(:NAME, name)
      end

      def power(power)
        const_set(:POWER, power)
      end

      def toughness(power)
        const_set(:TOUGHNESS, power)
      end

      def colors(*colors)
        const_set(:COLORS, colors)
      end

      def keywords(*keywords)
        const_set(:KEYWORDS, Keywords.list(*keywords))

        include Cards::KeywordHandlers::Prowess if keywords.include?(:prowess)
      end
    end

    def initialize(game:, owner:, base_power: self.class::POWER, base_toughness: self.class::TOUGHNESS)
      @name = self.class::NAME
      @type_line = self.class::TYPE_LINE
      @keywords = self.class::KEYWORDS
      @keyword_grants = []
      @protections = self.class::PROTECTIONS
      @base_power = base_power
      @base_toughness = base_toughness
      @owner = owner
      @game = game
    end

    def zone=(zone)
      @zone = zone
    end

    def resolve!(**args)
      Permanent.resolve(game: game, card: self, **args)
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

    def enters_tapped?
      false
    end

    def receive_notification(...)
    end

    def static_abilities
      []
    end

    def activated_abilities
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

    def state_triggered_abilities
      []
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
