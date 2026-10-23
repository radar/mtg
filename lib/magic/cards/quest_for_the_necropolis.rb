module Magic
  module Cards
    QuestForTheNecropolis = Enchantment("Quest for the Necropolis") do
      cost black: 1
    end

    class QuestForTheNecropolis < Enchantment
      # "Landfall — Whenever a land you control enters, put a quest counter on this enchantment."
      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform? = you?

        def call
          add_counter("quest", to: actor)
        end
      end

      def event_handlers = { Events::Landfall => LandfallTrigger }

      # "{5}{B}, Sacrifice this enchantment: Put target creature card from a graveyard onto the battlefield under your
      # control. This ability costs {1} less to activate for each quest counter on this enchantment. Activate only as a
      # sorcery."
      class ReanimateAbility < Magic::ActivatedAbility
        activate_only_as_sorcery

        def costs
          generic = [5 - source.counters.of_type(Counters["quest"]).count, 0].max
          Costs::Parser.parse(source:, costs: "#{"{#{generic}}" if generic.positive?}{B}, Sacrifice {this}")
        end

        def target_choices = game.players.flat_map { _1.graveyard.creatures }

        def resolve!(target:)
          reanimate target, controller: controller
        end
      end

      def activated_abilities = [ReanimateAbility]
    end
  end
end
