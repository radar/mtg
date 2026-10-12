module Magic
  module Cards
    # Séance Board: the accent drops out of the constant name (the Card helper and arena strip non-letters).
    SanceBoard = Artifact("Séance Board") do
      cost generic: 2
    end

    class SanceBoard < Artifact
      # "Morbid -- At the beginning of each end step, if a creature died this turn, put a soul counter on this artifact."
      class EndStepTrigger < TriggeredAbility
        def should_perform?
          game.current_turn.events.any? { _1.is_a?(Events::CreatureDied) }
        end

        def call
          add_counter("soul", to: actor)
        end
      end

      # "{T}: Add X mana of any one color, where X is the number of soul counters on this artifact. Spend this mana only to
      # cast instant, sorcery, Demon, and Spirit spells."
      class ManaAbility < Magic::TapManaAbility
        choices :all

        def mana_produced = { choice => source.counters.of_type(Counters::Soul).count }

        def requirements_met? = source.counters.of_type(Counters::Soul).any?

        def mana_restriction = ManaRestriction::InstantSorceryDemonOrSpirit.new
      end

      def activated_abilities = [ManaAbility]
      def event_handlers = { Events::BeginningOfEndStep => EndStepTrigger }
    end
  end
end
