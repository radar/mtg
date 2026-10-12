module Magic
  module Cards
    class SinisterMonolith < Artifact
      card_name "Sinister Monolith"
      cost generic: 3, black: 1

      # At the beginning of combat on your turn, each opponent loses 1 life and you gain 1 life.
      class CombatTrigger < TriggeredAbility
        def should_perform? = controllers_turn?

        def call
          opponents.each { |opponent| trigger_effect(:lose_life, target: opponent, life: 1) }
          trigger_effect(:gain_life, life: 1)
        end
      end

      def event_handlers = super.merge(Events::BeginningOfCombat => CombatTrigger)

      # {T}, Pay 2 life, Sacrifice this artifact: Draw two cards. Activate only as a sorcery.
      class DrawAbility < Magic::ActivatedAbility
        costs "{T}, Pay 2 life, Sacrifice {this}"
        activate_only_as_sorcery

        def resolve!
          trigger_effect(:draw_cards, number_to_draw: 2)
        end
      end

      def activated_abilities = [DrawAbility]
    end
  end
end
