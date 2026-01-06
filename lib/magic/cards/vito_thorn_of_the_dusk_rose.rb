module Magic
  module Cards
    VitoThornOfTheDuskRose = Creature("Vito, Thorn of the Dusk Rose") do
      cost generic: 2, black: 1
      type "Legendary Creature -- Vampire Cleric"
      power 1
      toughness 3
    end

    class VitoThornOfTheDuskRose < Creature
      class LifeLossChoice < Magic::Choice
        attr_reader :amount

        def initialize(amount:) = @amount = amount
        def choose(player) = player.lose_life(amount)
      end

      class LifeGainTrigger < TriggeredAbility
        def should_perform?
          event.player == controller
        end

        def call
          game.choices << LifeLossChoice.new(amount: event.life)
        end
      end

      def event_handlers
        {
          Events::LifeGain => LifeGainTrigger
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
