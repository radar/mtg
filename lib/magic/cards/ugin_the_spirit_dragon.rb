module Magic
  module Cards
    class UginTheSpiritDragon < Planeswalker
      NAME = "Ugin, the Spirit Dragon"
      TYPE_LINE = "Legendary Planeswalker -- Ugin"
      BASE_LOYALTY = 7

      class LoyaltyAbility1 < Magic::LoyaltyAbility
        def loyalty_change = 2
        def target_choices = battlefield.cards + game.players
        def single_target? = true

        def resolve!(target:)
          target.take_damage(source: source, damage: 3)
        end
      end

      class LoyaltyAbility2 < Magic::LoyaltyAbility
        def loyalty_change = :X

        def resolve!(value_for_x:)
          permanents = game.battlefield.permanents.select do |permanent|
            permanent.cmc <= value_for_x &&
            !permanent.colorless?
          end

          permanents.each do |permanent|
            trigger_effect(:exile, source: source, target: permanent)
          end
        end
      end

      class LoyaltyAbility3 < Magic::LoyaltyAbility
        def loyalty_change = -7

        def resolve!
          controller = source.controller
          controller.gain_life(7)
          7.times { controller.draw! }

          game.choices.add(UginTheSpiritDragon::Choice.new(source: source))
        end
      end

      class Choice < Magic::Choice::MoveToBattlefield
        def choices
          Magic::Targets::Choices.new(
            amount: 0..7,
            choices: source.controller.hand,
          )
        end
      end

      def loyalty_abilities
        [
          LoyaltyAbility1,
          LoyaltyAbility2,
          LoyaltyAbility3,
        ]
      end
    end
  end
end
