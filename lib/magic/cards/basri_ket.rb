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
              creature.add_counter(Counters::Plus1Plus1)
            end
          end
        end
      end

      def loyalty_abilities
        [
          LoyaltyAbility.new(loyalty_change: 1, ability: -> {
            add_effect(
              "SingleTargetAndResolve",
              choices: battlefield.creatures,
              resolution: -> (target) {
                target.add_counter(Counters::Plus1Plus1)
                target.grant_keyword(Keywords::INDESTRUCTIBLE, until_eot: true)
              }
            )
          }),
          LoyaltyAbility.new(loyalty_change: -2, ability: -> {
            delayed_response(
              turn: game.current_turn,
              event_type: Events::AttackersDeclared,
              response: -> {
                attackers = game.current_turn.attacks.count

                attackers.times do
                  token = Tokens::Soldier.new(game: game, controller: controller)
                  token.play!
                  token.tap!

                  game.current_turn.declare_attacker(token)
                end
              }
            )
          }),
          LoyaltyAbility.new(loyalty_change: -6, ability: -> {
            game.add_emblem(Emblem.new(controller: controller))
          }),
        ]
      end
    end
  end
end
