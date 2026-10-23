module Magic
  module Cards
    KozileksCommand = Instant("Kozilek's Command") do
      cost x: 1, colorless: 2
      type T::Kindred, T::Instant, T::Creatures["Eldrazi"]
    end

    class KozileksCommand < Instant
      # Cast#choose_mode hands each mode the spell's X (`x_value`).
      class Spawn < Mode
        def target_choices = game.players

        def resolve!(target:)
          create_token(token: Tokens::EldraziSpawn, controller: target, amount: x_value.to_i)
        end
      end

      # "Target player scries X, then draws a card." The scrying player is the target, not the spell's controller.
      class ScryChoice < Magic::Choice::Scry
        def initialize(actor:, amount:, player:)
          super(actor: actor, amount: amount)
          @player = player
        end

        def chooser = @player

        def resolve!(top: [], bottom: [])
          super
          chooser.draw!
        end

        # Scrying nothing still draws.
        def decline!
          chooser.draw!
        end
      end

      class ScryThenDraw < Mode
        def target_choices = game.players

        def resolve!(target:)
          amount = x_value.to_i
          if amount.positive? && target.library.any?
            game.choices.add(ScryChoice.new(actor: card, amount: amount, player: target))
          else
            target.draw!
          end
        end
      end

      class ExileCreature < Mode
        def target_choices
          return battlefield.creatures if x_value.nil?

          battlefield.creatures.select { _1.mana_value <= x_value }
        end

        def resolve!(target:)
          exile_target(target) if target_choices.include?(target)
        end
      end

      class ExileFromGraveyards < Mode
        def target_choices = game.graveyard_cards.to_a

        def resolve!(targets:)
          targets.first(x_value.to_i).each { exile_target(_1) }
        end
      end

      modes Spawn, ScryThenDraw, ExileCreature, ExileFromGraveyards
      choose_modes 2
    end
  end
end
