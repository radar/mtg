module Magic
  module Cards
    class SeasonOfLoss < Sorcery
      card_name "Season of Loss"
      cost generic: 3, black: 2

      # {P} -- Each player sacrifices a creature of their choice.
      class Edict < Mode
        points 1

        class SacrificeChoice < Magic::Choice::Targeted
          def initialize(actor:, player:)
            @player = player
            super(actor: actor)
          end

          def controller = @player

          def choices = @player.creatures

          def choice_amount = 1

          def resolve!(target:)
            target.sacrifice!
          end
        end

        def resolve!
          game.players.each do |player|
            choice = SacrificeChoice.new(actor: card, player: player)
            game.add_choice(choice) if choice.choices.any?
          end
        end
      end

      # {P}{P} -- Draw a card for each creature that died under your control this turn.
      class DrawForDeaths < Mode
        points 2

        def resolve!
          count = game.current_turn.events.count { _1.is_a?(Events::CreatureDied) && _1.controller == controller }
          trigger_effect(:draw_cards, number_to_draw: count) if count.positive?
        end
      end

      # {P}{P}{P} -- Each opponent loses X life, where X is the number of creature cards in your graveyard.
      class DrainOpponents < Mode
        points 3

        def resolve!
          x = controller.graveyard.creatures.count
          game.opponents(controller).each { |opponent| trigger_effect(:lose_life, target: opponent, life: x) } if x.positive?
        end
      end

      modes Edict, DrawForDeaths, DrainOpponents
      modes_budget 5
    end
  end
end
