# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # What an Aura or Equipment stops the creature it's attached to from doing:
      #
      #   Enchanted creature can't attack or block.
      #   Enchanted creature can't become untapped and can't have counters put on it.
      #   Enchanted creature doesn't untap during its controller's untap step.
      #
      # Each clause is a method on the Attachment card, which Permanent checks.
      class AttachedRestriction < Data.define(:subject, :methods)
        include Rule

        CLAUSES = {
          "can't attack" => ["def can_attack? = false"],
          "can't block" => ["def can_block?(_) = false"],
          "can't attack or block" => ["def can_attack? = false", "def can_block?(_) = false"],
          "can't become untapped" => ["def prevents_untapping? = true"],
          "doesn't untap during its controller's untap step" => ["def does_not_untap_during_untap_step? = true"],
          "can't have counters put on it" => ["def prevents_counters? = true"],
          "its activated abilities can't be activated" => ["def can_activate_ability?(_) = false"]
        }.freeze
        LINE = /\A(?<subject>Enchanted|Equipped) creature (?<clauses>.+?)\.?\z/

        def self.parse(line)
          return unless (m = LINE.match(line))

          methods = m[:clauses].split(/,? and (?=can't|doesn't|its )|, /).map { CLAUSES[_1] }
          new(subject: m[:subject].downcase, methods: methods.flatten) if methods.none?(&:nil?)
        end

        def kinds = subject == "enchanted" ? %i[aura] : %i[equipment]
        def body_source = methods.join("\n")
      end
    end
  end
end
