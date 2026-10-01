module Magic
  module Counters
    def self.[](counter_type)
      return counter_type if counter_type.is_a?(Class)

      case counter_type
      when "+1/+1" then Plus1Plus1
      when "-1/-1" then Minus1Minus1
      when "lore" then Lore
      when "incarnation" then Incarnation
      when "page" then Page
      when "poison" then Poison
      when "blessing" then Blessing
      when "stun" then Stun
      when "hatchling" then Hatchling
      when "time" then Time
      when "quest" then Quest
      when "flying" then Flying
      when "first strike" then FirstStrike
      when "lifelink" then Lifelink
      when "reach" then Reach
      when "trample" then Trample
      when "deathtouch" then Deathtouch
      else
        named(counter_type)
      end
    end

    # Generated card code names these as constants (Counters::Spore), and a card file loaded in
    # a fresh process hasn't asked for the type yet, so a missing constant creates it too.
    def self.const_missing(const)
      named(const.to_s.downcase)
    rescue RuntimeError
      super
    end

    # Any other single-word counter ("spore", "age", "verse") has no rules of its own: only
    # cards that count them care. It gets a class (Counters::Spore) the first time it's asked for.
    def self.named(counter_type)
      name = counter_type.to_s
      raise "Unknown counter type: #{counter_type}" unless name.match?(/\A[a-z]+\z/)

      @named ||= {}
      @named[name] ||= begin
        const = name.capitalize
        raise "Unknown counter type: #{counter_type}" if const_defined?(const, false)

        const_set(const, Class.new do
          def power_modification = 0
          def toughness_modification = 0
        end)
      end
    end
  end
end
