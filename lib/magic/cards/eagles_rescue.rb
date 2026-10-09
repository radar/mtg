module Magic
  module Cards
    EaglesRescue = Aura("Eagle's Rescue") do
      cost generic: 2, blue_or_white: 2
    end

    class EaglesRescue < Aura
      enchant "Creature"

      def target_choices
        battlefield.creatures
      end

      class EnchantedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 2
        applies_to_target
      end

      class EnchantedCreatureKeywords < Abilities::Static::KeywordGrant
        keyword_grants Keywords::FLYING
        applies_to_target
      end

      def static_abilities = [EnchantedCreatureBuff, EnchantedCreatureKeywords]

      # "{2}{W/U}{W/U}: Return this card from your graveyard to the battlefield attached to target creature you
      # control with power 1 or less. Activate only as a sorcery."
      class GraveyardAbility < Magic::ActivatedAbility
        costs "{2}{W/U}{W/U}"

        def requirements_met?
          source.zone&.graveyard? && source.owner == controller && game.can_cast_sorcery?(controller)
        end

        def target_choices
          battlefield.controlled_by(controller).creatures.select { _1.power <= 1 }
        end

        def resolve!(target:)
          source.resolve!(attach_to: target)
        end
      end

      def graveyard_abilities = [GraveyardAbility.new(source: self)]
    end
  end
end
