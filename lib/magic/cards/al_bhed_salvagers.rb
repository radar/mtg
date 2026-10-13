# Al Bhed Salvagers {2}{B}
# Creature — Human Artificer Warrior
# Whenever this creature or another creature or artifact you control dies, target opponent loses 1 life and you gain 1 life.
# 2/3

module Magic
  module Cards
    AlBhedSalvagers = Creature("Al Bhed Salvagers") do
      power 2
      toughness 3
      cost generic: 2, black: 1
      creature_type "Human Artificer Warrior"
    end

    class AlBhedSalvagers < Creature
      class Choice < Magic::Choice
        def choices
          Magic::Targets::Choices.new(
            choices: game.opponents(controller),
            amount: 1,
          )
        end

        def resolve!(target:)
          lose_life target, 1
        end
      end

      class DeathTriggeredAbility < TriggeredAbility
        def should_perform?
          this? || (you? && (type?(T::Creature) || type?(T::Artifact)))
        end

        def call
          game.add_choice(AlBhedSalvagers::Choice.new(actor: actor))

          actor.gain_life(1)
        end
      end

      def event_handlers
        {
          Events::CreatureDied => DeathTriggeredAbility
        }
      end

    end
  end
end
