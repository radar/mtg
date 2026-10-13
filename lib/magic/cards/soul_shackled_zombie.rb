module Magic
  module Cards
    SoulShackledZombie = Creature("Soul-Shackled Zombie") do
      cost generic: 3, black: 1
      creature_type("Zombie")
      power 4
      toughness 2
    end

    class SoulShackledZombie < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            game.graveyard_cards
          end

          def choice_amount = 0..2

          def resolve!(targets:)
            raise ArgumentError, "targets must all be in a single graveyard" unless targets.map(&:zone).uniq.size <= 1
            exiled = targets.uniq
            targets.uniq.each { exile_target(_1) }
            if exiled.any?(&:creature?)
              game.opponents(controller).each { lose_life(_1, 2) }
              gain_life(2)
            end
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
