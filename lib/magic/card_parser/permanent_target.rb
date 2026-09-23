# frozen_string_literal: true

module Magic
  class CardParser
    # "target creature", "target artifact an opponent controls", ... -> the Ruby
    # expression for the permanents that phrase can target.
    module PermanentTarget
      KINDS = { "creature" => "creatures", "artifact" => "artifacts", "enchantment" => "enchantments", "land" => "lands" }.freeze
      CONTROLLERS = {
        nil => "battlefield",
        "you control" => "battlefield.controlled_by(controller)",
        "an opponent controls" => "battlefield.not_controlled_by(controller)",
        "you don't control" => "battlefield.not_controlled_by(controller)"
      }.freeze
      PATTERN = /target (?<kind>#{KINDS.keys.join('|')})(?: (?<controller>#{CONTROLLERS.keys.compact.join('|')}))?/i

      def self.choices(match)
        "#{CONTROLLERS.fetch(match[:controller]&.downcase)}.#{KINDS.fetch(match[:kind].downcase)}"
      end
    end
  end
end
