module Magic
  module Cards
    VitoThornOfTheDuskRose = Creature("Vito, Thorn of the Dusk Rose") do
      cost generic: 2, black: 1
      type "Legendary Creature -- Vampire Cleric"
      power 1
      toughness 3
    end

    class VitoThornOfTheDuskRose < Creature
      class LifeLossChoice < Magic::Choice::Effect
        attr_reader :amount

        def initialize(amount:) = @amount = amount
        def choose(player) = player.lose_life(amount)
      end

      def event_handlers
        {
          Events::LifeGain => -> (receiver, event) do
            return unless event.player == controller

            game.choices << LifeLossChoice.new(amount: event.life)

          end
        }
      end

      class ActivatedAbility < Magic::ActivatedAbility
        def costs
          [
            Costs::Mana.new(generic: 3, black: 2),
          ]
        end

        def resolve!
          source.controller.creatures.each do
            _1.grant_keyword(Keywords::LIFELINK, until_eot: true)
          end
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
