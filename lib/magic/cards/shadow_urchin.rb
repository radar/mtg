module Magic
  module Cards
    class ShadowUrchin < Creature
      card_name "Shadow Urchin"
      cost "{2}{B/R}"
      creature_type "Ouphe"
      power 3
      toughness 4

      # "Whenever this creature attacks, blight 1."
      class AttacksTrigger < TriggeredAbility
        def should_perform? = event.attacker == actor

        def call
          game.choices.add(Magic::Choice::Blight.new(actor:, amount: 1)) if Magic::Choice::Blight.possible?(controller, game)
        end
      end

      # "Whenever a creature you control with one or more counters on it dies, exile that many cards
      # from the top of your library. Until your next end step, you may play those cards."
      class CreatureDiesTrigger < TriggeredAbility
        def should_perform?
          event.permanent.controller == controller && event.permanent.counters.any?
        end

        def call
          controller.library.first(event.permanent.counters.count).each do |card|
            trigger_effect(:exile, target: card)
            game.play_permissions.grant_until_next_end_step(card:, player: controller)
          end
        end
      end

      def event_handlers
        { Events::CreatureAttacked => AttacksTrigger, Events::CreatureDied => CreatureDiesTrigger }
      end
    end
  end
end
