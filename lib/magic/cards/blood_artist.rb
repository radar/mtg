module Magic
  module Cards
    BloodArtist = Creature("Blood Artist") do
      cost generic: 1, black: 1
      creature_type "Vampire"
      power 0
      toughness 1
    end

    class BloodArtist < Creature
      class LoseLifeChoice < Magic::Choice::Targeted
        def prompt = "Choose target player. They lose 1 life and you gain 1 life."

        def choices = game.players

        def choice_amount = 1

        def resolve!(target:)
          lose_life(target, 1)
          gain_life(1)
        end
      end

      # "Whenever this creature or another creature dies, target player loses 1 life and you gain 1 life."
      class CreatureDiedTrigger < TriggeredAbility
        def call
          game.add_choice(LoseLifeChoice.new(actor: actor))
        end
      end

      def event_handlers = { Events::CreatureDied => CreatureDiedTrigger }
    end
  end
end
