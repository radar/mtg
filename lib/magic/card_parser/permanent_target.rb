# frozen_string_literal: true

module Magic
  class CardParser
    # "target creature", "target artifact an opponent controls", "another target
    # creature you control", ... -> the Ruby expression for the permanents that
    # phrase can target ("another" leaves out Effect::THIS).
    module PermanentTarget
      KINDS = { "creature" => "creatures", "artifact" => "artifacts", "enchantment" => "enchantments", "land" => "lands",
                "nonland permanent" => "nonland", "permanent" => "permanents" }.freeze
      CONTROLLERS = {
        nil => "battlefield",
        "you control" => "battlefield.controlled_by(controller)",
        "an opponent controls" => "battlefield.not_controlled_by(controller)",
        "you don't control" => "battlefield.not_controlled_by(controller)"
      }.freeze
      PATTERN = /(?<another>another )?target (?<kind>#{KINDS.keys.join('|')})(?: (?<controller>#{CONTROLLERS.keys.compact.join('|')}))?/i

      def self.choices(match)
        permanents = "#{CONTROLLERS.fetch(match[:controller]&.downcase)}.#{KINDS.fetch(match[:kind].downcase)}"
        match[:another] ? "(#{permanents} - [#{Effect::THIS}])" : permanents
      end
    end
  end
end
