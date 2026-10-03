module Magic
  module Cards
    AffectionateIndrik = Creature("Affectionate Indrik") do
      cost generic: 5, green: 1
      creature_type("Beast")
      power 4
      toughness 4
    end

    class AffectionateIndrik < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class MayChoice < Magic::Choice::May
          class TargetChoice < Magic::Choice::Targeted
            def choices
              battlefield.not_controlled_by(controller).creatures
            end

            def choice_amount = 1

            def resolve!(target:)
              actor.fights!(target)
            end
          end

          def resolve!
            choice = TargetChoice.new(actor: actor)
            game.add_choice(choice) if choice.choices.any?
          end
        end

        def call
          return if battlefield.not_controlled_by(controller).creatures.none?
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
