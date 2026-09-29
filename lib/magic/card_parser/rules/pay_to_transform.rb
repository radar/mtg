# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "At the beginning of your first main phase, you may pay {B}. If you do, transform ~." on
      # either face of a double-faced card -> a `TriggeredAbility::PayToTransform` subclass with
      # `pay black: 1`, listed under `Events::FirstMainPhase`.
      class PayToTransform < Data.define(:mana)
        include Rule

        LINE = /\AAt the beginning of your first main phase, you may pay (?<cost>(?:\{[^}]+\})+)\. If you do, transform ~\.?\z/i

        def self.parse(line)
          new(mana: ManaCost.parse($~[:cost])) if LINE.match(line)
        end

        def kinds = %i[creature planeswalker]
        def hook = :event_handlers
        def class_base_name = "PayToTransformTrigger"
        def handled_event = "Events::FirstMainPhase"

        def class_source(name)
          args = mana.map { |color, amount| "#{color}: #{amount}" }.join(", ")
          "class #{name} < TriggeredAbility::PayToTransform\n  pay #{args}\nend\n"
        end
      end
    end
  end
end
