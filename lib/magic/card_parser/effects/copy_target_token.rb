# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Create a token that's a copy of target Kithkin you control."
      # "Create a token that's a copy of ~." (a trigger or ability on a permanent: copies the permanent)
      # "Create a token that's a copy of target creature you control, except it has haste and "At the
      # beginning of the end step, sacrifice this token."" (Electroduplicate)
      class CopyTargetToken < Data.define(:targets, :haste_and_sacrifice)
        include Effect

        EXCEPT = %(, except it has haste and "At the beginning of the end step, sacrifice this token.")
        LINE = /\ACreate a token that's a copy of (?:(?<self>~)|#{PermanentTarget::PATTERN})(?<except>#{Regexp.escape(EXCEPT)})?\.?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text))

          new(targets: m[:self] ? nil : PermanentTarget.choices(m), haste_and_sacrifice: !m[:except].nil?)
        end

        def target_choices = targets

        def definitions
          return unless haste_and_sacrifice

          "class SacrificeTokenTrigger < TriggeredAbility::BeginningOfEndStep\n  def call = actor.sacrifice!\nend\n"
        end

        def resolve_call
          source = targets ? "target" : THIS
          call = "Permanent.resolve(game: game, owner: controller, card: #{source}.copiable_card, token: true, copy: true, cast: false)"
          return call unless haste_and_sacrifice

          "copy = #{call}\ncopy.grant_haste!\ncopy.register_turn_trigger(Events::BeginningOfEndStep, SacrificeTokenTrigger)"
        end
      end
    end
  end
end
