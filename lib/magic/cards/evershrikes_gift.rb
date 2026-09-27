module Magic
  module Cards
    EvershrikesGift = Aura("Evershrike's Gift") do
      cost white: 1
    end

    class EvershrikesGift < Aura
      enchant "Creature"

      def target_choices
        battlefield.creatures
      end

      class EnchantedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 0
        applies_to_target
      end

      class EnchantedCreatureKeywords < Abilities::Static::KeywordGrant
        keyword_grants Keywords::FLYING
        applies_to_target
      end

      def static_abilities = [EnchantedCreatureBuff, EnchantedCreatureKeywords]

      # "{1}{W}, Blight 2: Return this card from your graveyard to your hand. Activate
      # only as a sorcery." -- an ability the card itself has while sitting in the
      # graveyard, not a Permanent's activated_abilities (there's no permanent; this
      # card isn't on the battlefield). Actions::ActivateAbility's own illegal_reason
      # already covers "you control the source" generically (Card#controller, same as
      # Permanent#controller) and doesn't otherwise assume a battlefield source, so
      # #requirements_met? alone is enough to gate this on being in the graveyard at
      # sorcery speed -- no new Action class needed.
      class GraveyardAbility < Magic::ActivatedAbility
        costs "{1}{W}, Blight 2"

        def requirements_met?
          source.zone&.graveyard? && source.owner == controller && game.can_cast_sorcery?(controller)
        end

        def resolve!
          source.move_to_hand!(controller)
        end
      end

      def graveyard_abilities
        [GraveyardAbility.new(source: self)]
      end
    end
  end
end
