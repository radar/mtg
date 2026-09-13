module Magic
  module Cards
    RoamingThrone = Creature("Roaming Throne") do
      artifact_creature_type "Golem"
      cost generic: 4
      power 4
      toughness 4

      ward generic: 2
    end

    class RoamingThrone < Creature
      class CreatureTypeChoice < Magic::Choice::CreatureType
        def resolve!(creature_type:)
          actor.chosen_creature_type = creature_type
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          game.add_choice(CreatureTypeChoice.new(actor: actor))
        end
      end

      # This creature is the chosen type in addition to its other types.
      class TypeModification < Abilities::Static::TypeGrant
        def type_grants
          [source.chosen_creature_type].compact
        end

        def applicable_targets
          [source]
        end
      end

      # If a triggered ability of another creature you control of the chosen
      # type triggers, it triggers an additional time.
      class TriggersAdditionalTime < Abilities::Static::TriggeredAbilityDoubler
        def doubles_trigger_for?(permanent)
          permanent != source &&
            permanent.controller == controller &&
            source.chosen_creature_type &&
            permanent.type?(source.chosen_creature_type)
        end
      end

      def etb_triggers = [ETB]

      def static_abilities = [TypeModification, TriggersAdditionalTime]
    end
  end
end
