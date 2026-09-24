# frozen_string_literal: true

module Magic
  class CardParser
    # "target creature", "target artifact an opponent controls", "another target
    # creature you control", "target attacking Goblin you control", ... -> the Ruby
    # expression for the permanents that phrase can target ("another" leaves out
    # Effect::THIS). A capitalised creature type ("target Elf you control") is a creature
    # of that type.
    module PermanentTarget
      KINDS = { "creature" => "creatures", "artifact" => "artifacts", "enchantment" => "enchantments", "land" => "lands",
                "nonland permanent" => "nonland" }.freeze
      CONTROLLERS = {
        nil => "battlefield",
        "you control" => "battlefield.controlled_by(controller)",
        "an opponent controls" => "battlefield.not_controlled_by(controller)",
        "you don't control" => "battlefield.not_controlled_by(controller)"
      }.freeze
      # Every creature type the engine knows, longest first so "Elemental" beats "Elf".
      CREATURE_TYPES = Magic::Types::Creatures.values.sort_by { -_1.size }.join("|").freeze
      PATTERN = /(?<another>another )?target (?<attacking>attacking )?(?<kind>#{KINDS.keys.join('|')}|(?-i:(?:#{CREATURE_TYPES})\b))(?: (?<controller>#{CONTROLLERS.keys.compact.join('|')}))?/i

      # Whether the match names creatures ("target creature", "target Elf"), not another card type.
      def self.creature?(match) = match[:kind].downcase == "creature" || creature_type?(match)

      def self.creature_type?(match) = !KINDS.key?(match[:kind].downcase)

      def self.choices(match)
        base = CONTROLLERS.fetch(match[:controller]&.downcase)
        permanents = if creature_type?(match)
                       "#{base}.creatures.by_any_type(#{match[:kind].inspect})"
                     else
                       "#{base}.#{KINDS.fetch(match[:kind].downcase)}"
                     end
        permanents += ".attacking" if match[:attacking]
        match[:another] ? "(#{permanents} - [#{Effect::THIS}])" : permanents
      end
    end
  end
end
