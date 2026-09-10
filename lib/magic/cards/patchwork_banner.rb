module Magic
  module Cards
    PatchworkBanner = Artifact("Patchwork Banner") do
      cost generic: 3
    end

    class PatchworkBanner < Artifact
      attr_accessor :chosen_creature_type

      class CreatureTypeChoice < Magic::Choice::CreatureType
        def resolve!(creature_type:)
          actor.card.chosen_creature_type = creature_type
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(PatchworkBanner::CreatureTypeChoice.new(actor: actor))
        end
      end

      def etb_triggers = [ETB]

      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1

        def applicable_targets
          source.controller.creatures.by_type(source.card.chosen_creature_type)
        end
      end

      def static_abilities = [PowerAndToughnessModification]

      class ManaAbility < Magic::TapManaAbility
        choices :all
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
