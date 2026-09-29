# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Target creature gains 'Whenever this creature deals combat damage to a player or
      # planeswalker, draw a card' until end of turn." -- a delayed trigger registered on the
      # creature for the rest of the turn (`register_turn_trigger`).
      class GrantDamageTrigger < Data.define(:reference, :effect_list)
        include Effect

        LINE = /\A#{PermanentTarget::REFERENCE} gains "Whenever ~ deals combat damage to a player or planeswalker, (?<effects>[^"]+?)\.?" until end of turn\.?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text))

          effect_list = EffectList.parse(m[:effects]) or return
          new(reference: PermanentTarget.reference(m), effect_list:)
        end

        def target_choices = reference.choices
        def earlier_target? = !!reference.earlier_target?

        def definitions
          body = "def should_perform?\n  event.source == actor && (event.target.is_a?(Magic::Player) || event.target.planeswalker?)\nend\n\n#{effect_list.trigger_source}"
          "class GrantedDamageTrigger < TriggeredAbility\n#{body.gsub(/^(?=.)/, '  ')}end\n"
        end

        def resolve_call = "#{reference.object}.register_turn_trigger(Events::CombatDamageDealt, GrantedDamageTrigger)"
      end
    end
  end
end
