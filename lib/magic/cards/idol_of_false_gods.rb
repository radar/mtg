module Magic
  module Cards
    IdolOfFalseGods = Artifact("Idol Of False Gods") do
      cost generic: 2
      type T::Kindred, T::Artifact, T::Creatures["Eldrazi"]
    end

    class IdolOfFalseGods < Artifact
      # "{1}{C}, {T}: Create a 0/1 colorless Eldrazi Spawn creature token with 'Sacrifice this token: Add {C}.'"
      class SpawnAbility < Magic::ActivatedAbility
        costs "{1}{C}, {T}"

        def resolve!
          create_eldrazi_spawn
        end
      end

      # "Whenever another Eldrazi you control dies, put a +1/+1 counter on this artifact."
      class EldraziDiesTrigger < TriggeredAbility
        def should_perform?
          dying = event.permanent
          dying != actor && dying.controller == controller && dying.type?("Eldrazi")
        end

        def call
          add_counter "+1/+1", to: actor
        end
      end

      # "As long as this artifact has eight or more +1/+1 counters on it, it's a 0/0 creature in addition to its other
      # types and it has annihilator 2." Three static abilities share the condition.
      module EightCounters
        def self.included(base)
          base.conditions { source.counters.of_type(Counters::Plus1Plus1).count >= 8 }
          base.applicable_targets { [source] }
        end
      end

      class BecomesCreature < Abilities::Static::TypeGrant
        include EightCounters
        type_grants T::Creature
      end

      class CreatureStats < Abilities::Static::CharacteristicSetting
        include EightCounters
        sets_base_power_and_toughness 0, 0
      end

      class GainsAnnihilator < Abilities::Static::KeywordGrant
        include EightCounters
        keyword_grants Keywords::Annihilator.new(2)
      end

      def activated_abilities = [SpawnAbility]
      def static_abilities = [BecomesCreature, CreatureStats, GainsAnnihilator]
      def event_handlers
        {
          Events::CreatureDied => EldraziDiesTrigger,
          Events::CreatureAttacked => TriggeredAbility::Annihilator,
        }
      end
    end
  end
end
