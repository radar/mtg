module Magic
  module Cards
    class WaltzOfRage < Sorcery
      card_name "Waltz of Rage"
      cost generic: 3, red: 2

      # "Until end of turn, whenever a creature you control dies, exile the top card of your library. You may play it until
      # the end of your next turn."
      class CreatureDiedTrigger < TriggeredAbility
        def should_perform?
          event.controller == controller
        end

        def call
          card = controller.library.first
          return unless card

          card.exile!
          game.play_permissions.grant_until_end_of_next_turn(card: card, player: controller)
        end
      end

      def single_target? = true

      def target_choices
        battlefield.controlled_by(controller).creatures
      end

      # "Target creature you control deals damage equal to its power to each other creature."
      def resolve!(target:)
        damage = target.power
        battlefield.creatures.reject { _1 == target }.each do |creature|
          target.deal_damage damage, to: creature
        end
        game.add_delayed_trigger(source: self, event_class: Events::CreatureDied, trigger_class: CreatureDiedTrigger)
      end
    end
  end
end
