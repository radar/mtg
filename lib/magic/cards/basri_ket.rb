module Magic
  module Cards
    class BasriKet < Planeswalker
      NAME = "Basri Ket"
      TYPE_LINE = "Legendary Planeswalker -- Basri"
      BASE_LOYALTY = 3

      class Emblem < Magic::Emblem
        def receive_event(event)
          case event
          when Events::BeginningOfCombat
            return unless event.active_player == controller
            game = controller.game

            token = Tokens::Soldier.new(game: game, controller: controller)
            token.resolve!

            game.battlefield.creatures.controlled_by(controller).each do |creature|
              creature.add_counter(power: 1, toughness: 1)
            end
          end
        end
      end

      def loyalty_abilities
        [
          LoyaltyAbility.new(loyalty_change: 1, ability: -> {
            game.add_effect(
              Effects::SingleTargetAndResolve.new(
                choices: game.battlefield.creatures,
                targets: 1,
                resolution: -> (target) {
                  target.add_counter(power: 1, toughness: 1)
                  target.grant_keyword(Keywords::INDESTRUCTIBLE, until_eot: true)
                }
              )
            )
          }),
          LoyaltyAbility.new(loyalty_change: -2, ability: -> {
            game.current_turn.after_attackers_declared(method(:after_attackers_declared))
          }),
          LoyaltyAbility.new(loyalty_change: -6, ability: -> {
            game.add_emblem(Emblem.new(controller: controller))
          }),
        ]
      end

      def after_attackers_declared
        attackers = game.current_turn.attacks.count

        attackers.times do
          token = Tokens::Soldier.new(game: game, controller: controller)
          token.cast!
          token.tap!

          game.current_turn.declare_attacker(token)
        end
      end
    end
  end
end
