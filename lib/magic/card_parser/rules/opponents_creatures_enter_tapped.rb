# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "Creatures your opponents control enter tapped." (Authority of the Consuls): a static ability
      # answering `forces_creature_to_enter_tapped?(card, player)`, which `Permanent.resolve` checks.
      class OpponentsCreaturesEnterTapped < Data.define
        include Rule

        LINE = /\ACreatures your opponents control enter tapped\.?\z/

        def self.parse(line) = (new if LINE.match?(line))

        def kinds = PERMANENT_KINDS
        def hook = :static_abilities
        def class_base_name = "OpponentsCreaturesEnterTapped"

        def class_source(name)
          <<~RUBY
            class #{name} < StaticAbility
              def forces_creature_to_enter_tapped?(_card, player) = player != controller
            end
          RUBY
        end
      end
    end
  end
end
