module Magic
  module Cards
    FoundFootage = Artifact("Found Footage") do
      type T::Artifact, "Clue"
      cost generic: 1
    end

    class FoundFootage < Artifact
      # "{2}, Sacrifice this artifact: Surveil 2, then draw a card."
      class SurveilThenDraw < Magic::Choice::Surveil
        def resolve!(**)
          super
          chooser.draw!
        end

        def decline!
          chooser.draw!
        end
      end

      class SurveilAbility < Magic::ActivatedAbility
        costs "{2}, Sacrifice {this}"

        def resolve!
          game.add_choice(SurveilThenDraw.new(actor: source, amount: 2))
        end
      end

      # "You may look at face-down creatures your opponents control any time." The engine has no face-down
      # permanents, so there is nothing to implement for it yet.

      def activated_abilities = [SurveilAbility]
    end
  end
end
