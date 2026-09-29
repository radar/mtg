module Magic
  module Cards
    class SpinerockTyrant < Creature
      card_name "Spinerock Tyrant"
      cost generic: 3, red: 2
      creature_type "Dragon"
      power 6
      toughness 6
      keywords :flying, :wither

      class MayCopyChoice < Magic::Choice::May
        def initialize(actor:, spell:, targets:)
          super(actor:)
          @spell = spell
          @targets = targets
        end

        # "... you may copy it. If you do, those spells gain wither. You may choose new targets for the
        # copy."
        def resolve!
          @spell.gain_keyword_as_spell!(Keywords::WITHER)
          Magic::CopyEffect.resolve_with_choice!(actor:, receiver: @spell, targets: @targets, copies: 1)
        end
      end

      # "Whenever you cast an instant or sorcery spell with a single target, you may copy it."
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && (spell.instant? || spell.sorcery?) && event.targets.size == 1
        end

        def call
          game.choices.add(MayCopyChoice.new(actor:, spell:, targets: event.targets))
        end
      end

      def event_handlers = { Events::SpellCast => SpellCastTrigger }
    end
  end
end
