module Magic
  module Cards
    class FabledPassage < Land
      NAME = "Fabled Passage"

      def target_choices(receiver)
        receiver.controller.library.basic_lands
      end

      class Choice < Magic::Choice::SearchLibraryForBasicLand
        def initialize(source:)
          super(source: source, enters_tapped: true)
        end

        def choices
          controller.library.basic_lands
        end

        def resolve!(target:)
          land = super
          if source.controller.lands.count >= 4
            land.untap!
          end
        end
      end

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{T}, Sacrifice {this}"

        def resolve!
          game.choices.add(Choice.new(source: source))
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
