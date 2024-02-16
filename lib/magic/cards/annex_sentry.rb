module Magic
  module Cards
    AnnexSentry = Creature("Annex Sentry") do
      artifact_creature_type("Phyrexian Cleric")
      cost "{2}{W}"
      power 1
      toughness 4
    end

    class AnnexSentry < Creature
      KEYWORDS = [Keywords::Toxic.new(1)]

      class Effect < Effects::ExilePermanent
        def resolve!
          super
          source.exiled_cards << target.card
        end
      end

      class Choice < Magic::Choice
        def choices
          game.battlefield.not_controlled_by(actor.controller).cmc_lte(3).by_any_type(T::Creature, T::Artifact)
        end

        def resolve!(target:)
          effect = AnnexSentry::Effect.new(
            source: actor,
            target: target,
          )
          game.add_effect(effect)
        end
      end


      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          game.choices.add(Choice.new(actor: actor))
        end
      end

      def etb_triggers = [ETB]

      class LTB < TriggeredAbility::EnterTheBattlefield
        def perform
          actor.exiled_cards.each { _1.resolve! }
        end
      end

      def ltb_triggers = [LTB]
    end
  end
end
