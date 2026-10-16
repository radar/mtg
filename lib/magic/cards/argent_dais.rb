module Magic
  module Cards
    ArgentDais = Card("Argent Dais") do
      type "Artifact"
      cost generic: 1, white: 1
    end

    class ArgentDais < Card
      # "This artifact enters with two oil counters on it."
      enters_with_counters "oil", 2

      # "Whenever two or more creatures attack, put an oil counter on this artifact." Any player's creatures count.
      class AttackTrigger < TriggeredAbility
        def should_perform? = event.attacks.size >= 2

        def call
          add_counter("oil", to: actor)
        end
      end

      # "{2}, {T}, Remove two oil counters from this artifact: Exile another target nonland permanent. Its controller
      # draws two cards."
      class ExileAbility < Magic::ActivatedAbility
        def costs
          [
            Costs::Mana.new(generic: 2),
            Costs::SelfTap.new(source),
            Costs::RemoveCounter.new(source, Counters["oil"], amount: 2)
          ]
        end

        def requirements_met? = source.counters.of_type(Counters["oil"]).count >= 2

        def target_choices = game.battlefield.nonland.reject { _1 == source }

        def resolve!(target:)
          owner_of_control = target.controller
          exile_target(target)
          draw_cards(2, player: owner_of_control)
        end
      end

      def activated_abilities = [ExileAbility]

      def event_handlers = { Events::FinalAttackersDeclared => AttackTrigger }
    end
  end
end
