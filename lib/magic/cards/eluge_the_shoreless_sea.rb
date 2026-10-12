module Magic
  module Cards
    ElugeTheShorelessSea = Creature("Eluge, the Shoreless Sea") do
      legendary_creature_type "Elemental Fish"
      cost generic: 1, blue: 3
      power 0
      toughness 0
    end

    class ElugeTheShorelessSea < Creature
      # Eluge's power and toughness are each equal to the number of Islands you control.
      class IslandCount < Abilities::Static::CharacteristicSetting
        def applicable_targets = [source]

        def islands = source.controller.lands.count { _1.type?("Island") }

        def set_base_power = islands

        def set_base_toughness = islands
      end

      # Lands with a flood counter on them are Islands in addition to their other types.
      class FloodedIslands < Abilities::Static::TypeGrant
        type_grants "Island"

        def applicable_targets = battlefield.lands.select { _1.counters.of_type(Counters["flood"]).any? }
      end

      # The first instant or sorcery spell you cast each turn costs {U} less to cast for each land you control
      # with a flood counter on it.
      class FloodDiscount < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          @source = source
          @adjustment = { blue: -> { -[flooded, @card.cost.cost[:blue].to_i].min } }
        end

        def flooded = source.controller.lands.count { _1.counters.of_type(Counters["flood"]).any? }

        def applies_to?(card)
          return false unless card.controller == source.controller && (card.instant? || card.sorcery?) && flooded.positive?
          return false unless card.cost.cost[:blue].to_i.positive?

          @card = card
          source.game.current_turn.spells_cast.none? do |cast|
            cast.player == source.controller && (cast.spell.instant? || cast.spell.sorcery?)
          end
        end
      end

      def static_abilities = [IslandCount, FloodedIslands, FloodDiscount]

      # Whenever Eluge enters or attacks, put a flood counter on target land. It's an Island in addition to its
      # other types for as long as it has a flood counter on it.
      module Flooding
        class LandChoice < Magic::Choice::Targeted
          def choices = battlefield.lands

          def choice_amount = 1

          def resolve!(target:)
            add_counter("flood", to: target)
          end
        end

        def flood_a_land
          choice = LandChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        include Flooding

        def call = flood_a_land
      end

      class AttacksTrigger < TriggeredAbility
        include Flooding

        def should_perform? = event.attacks.any? { _1.attacker == actor }

        def call = flood_a_land
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers = super.merge(Events::FinalAttackersDeclared => AttacksTrigger)
    end
  end
end
