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

      # "it" / "that creature": whatever an earlier effect of the same ability targeted.
      PRONOUN = /(?<pronoun>it|that creature|that permanent)/i
      # "enchanted creature" / "equipped creature": what the Aura or Equipment is attached to.
      ATTACHED = /(?<attached>enchanted|equipped) creature/i
      # A permanent an effect acts on: a new target, an earlier target or the attached creature.
      REFERENCE = /(?:#{PATTERN}|#{PRONOUN}|#{ATTACHED})/i

      # What a REFERENCE match refers to: `choices` (Ruby for the legal targets, or nil
      # when nothing new is targeted) and `object` (Ruby for the permanent itself).
      Reference = Data.define(:choices, :object) do
        # Refers to what an earlier effect targeted; EffectList checks there is one.
        def earlier_target? = choices.nil? && object == "target"
      end

      def self.reference(match)
        if match[:pronoun] then Reference.new(choices: nil, object: "target")
        elsif match[:attached] then Reference.new(choices: nil, object: "#{Effect::THIS}.attached_to")
        else Reference.new(choices: choices(match), object: "target")
        end
      end

      def self.choices(match)
        permanents = "#{CONTROLLERS.fetch(match[:controller]&.downcase)}.#{KINDS.fetch(match[:kind].downcase)}"
        match[:another] ? "(#{permanents} - [#{Effect::THIS}])" : permanents
      end
    end
  end
end
