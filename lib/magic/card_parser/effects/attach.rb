# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Attach it to target Pirate you control." / "Attach ~ to target creature you control." --
      # an Equipment (or Aura) attaching itself as its enters trigger resolves. "It" is the permanent
      # itself, not an earlier target (`Permanent#attach_to!`).
      class Attach < Data.define(:reference)
        include Effect

        LINE = /\AAttach (?:it|~) to #{PermanentTarget::PATTERN}\.?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text)) && PermanentTarget.creature?(m)

          new(reference: PermanentTarget.reference(m))
        end

        def target_choices = reference.choices
        def optional_target? = reference.optional
        def resolve_call = "#{THIS}.attach_to!(target)"
      end
    end
  end
end
