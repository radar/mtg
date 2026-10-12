module Magic
  module Cards
    BilboLuckwearer = Creature("Bilbo, Luckwearer") do
      cost generic: 1, blue: 1
      legendary_creature_type("Halfling Rogue")
      power 1
      toughness 1
    end

    class BilboLuckwearer < Creature
      # "Bilbo can't be blocked."
      def can_be_blocked?(_blocker) = false

      # "Whenever Bilbo deals combat damage to a player, draw a card, then discard a card."
      class CombatDamageTrigger < TriggeredAbility
        def should_perform?
          event.combat? && event.source == actor && event.target.player?
        end

        def call
          trigger_effect(:draw_cards, number_to_draw: 1)
          game.add_choice(Magic::Choice::Discard.new(player: controller, actor: actor)) if controller.hand.any?
        end
      end

      def event_handlers = { Events::DamageDealt => CombatDamageTrigger }

      # Burglar's Plot {4}{U}, Sorcery -- Adventure: "Exchange control of two target nonland permanents that share a
      # card type."
      adventure generic: 4, blue: 1

      def number_of_targets(_x = 0) = 2

      def distinct_targets? = true

      def target_choices = game.battlefield.permanents.nonland

      def adventure_resolve!(targets:, **)
        first, second = targets
        shared = %w[Artifact Creature Enchantment Planeswalker Battle].select { first.type?(_1) && second.type?(_1) }
        return if shared.empty? || first.controller == second.controller

        first_controller = first.controller
        second_controller = second.controller
        first.controller = second_controller
        second.controller = first_controller
      end
    end
  end
end
