# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Untap target Merfolk you control." / "Untap target creature." / "Untap ~." /
      # "Untap each other Merfolk you control."
      class Untap < Data.define(:who, :targets)
        include Effect

        LINE = /\AUntap (?:(?<self>~)|each other (?<type>(?-i:#{PermanentTarget::CREATURE_TYPES})) you control|#{PermanentTarget::PATTERN})\.?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text))

          if m[:self] then new(who: :self, targets: nil)
          elsif m[:type] then new(who: :each, targets: "(battlefield.controlled_by(controller).creatures.by_any_type(#{m[:type].inspect}) - [#{THIS}])")
          else new(who: :target, targets: PermanentTarget.choices(m))
          end
        end

        def target_choices = who == :target ? targets : nil

        def resolve_call
          case who
          when :self then "#{THIS}.untap!"
          when :each then "#{targets}.each(&:untap!)"
          else "target.untap!"
          end
        end
      end
    end
  end
end
