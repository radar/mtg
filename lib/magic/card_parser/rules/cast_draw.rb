# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "Whenever you cast a creature spell, draw a card." The spell type can be a
      # card type ("creature", "artifact") or a subtype ("Elf", "Wizard").
      class CastDraw < Data.define(:spell_type)
        include Rule

        LINE = /\AWhenever you cast an? (?<type>[\w-]+) spell, draw a card\.?\z/i

        def self.parse(line)
          return unless (m = LINE.match(line))

          new(spell_type: m[:type].capitalize)
        end

        def hook = :event_handlers
        def class_base_name = "SpellCastTrigger"
        def handled_event = "Events::SpellCast"

        def class_source(name)
          <<~RUBY
            class #{name} < TriggeredAbility::SpellCast
              def should_perform?
                spell.type?(#{spell_type.inspect}) && you?
              end

              def call
                actor.trigger_effect(:draw_cards)
              end
            end
          RUBY
        end
      end
    end
  end
end
