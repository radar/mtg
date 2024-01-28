module Magic
  module Cards
    AnnexSentry = Creature("Annex Sentry") do
      artifact_creature_type("Phyrexian Cleric")
      cost white: 1, generic: 2
      power 1
      toughness 4
    end

    class AnnexSentry < Creature
      KEYWORDS = [Keywords::Toxic.new(1)]

      class Effect < Effects::Exile
        def resolve!
          super
          source.exiled_cards << target.card
        end
      end

      class Choice < Magic::Choice
        def choices
          game.battlefield.not_controlled_by(source.controller).cmc_lte(3).by_any_type(T::Creature, T::Artifact)
        end

        def resolve!(target:)
          effect = AnnexSentry::Effect.new(
            source: source,
            target: target,
          )
          game.add_effect(effect)
        end
      end


      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          game.choices.add(Choice.new(source: permanent))
        end
      end

      def etb_triggers = [ETB]

      class LTB < TriggeredAbility::EnterTheBattlefield
        def perform
          permanent.exiled_cards.each { _1.move_zone!(battlefield) }
        end
      end

      def ltb_triggers = [LTB]
    end
  end
end
