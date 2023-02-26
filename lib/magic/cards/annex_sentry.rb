module Magic
  module Cards
    AnnexSentry = Creature("Annex Sentry") do
      type artifact_creature_type("Phyrexian Cleric")
      cost white: 1, generic: 2
      power 1
      toughness 4
    end

    class AnnexSentry < Creature
      KEYWORDS = [Keywords::Toxic.new(1)]

      class ETB < TriggeredAbility::EnterTheBattlefield
        def target_choices
          game.battlefield.not_controlled_by(controller).cmc_lte(3).by_any_type(T::Creature, T::Artifact)
        end

        def perform
          effect = Effects::SingleTargetAndResolve.new(
            source: permanent,
            choices: target_choices,
            resolution: -> (target) {
              exile_effect = Effects::Exile.new(source: permanent).resolve(target: target)
              permanent.exiled_cards << target.card
            }
          )
          game.add_effect(effect)
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
