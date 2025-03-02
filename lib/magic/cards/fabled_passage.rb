module Magic
  module Cards
    class FabledPassage < Land
      NAME = "Fabled Passage"

      def target_choices(receiver)
        receiver.controller.library.basic_lands
      end

      class Choice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :battlefield, filter: Filter[:basic_lands], upto: 1, enters_tapped: true)
        end

        def resolve!(target:)
          land = super
          if actor.controller.lands.count >= 4
            land.untap!
          end
        end
      end

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{T}, Sacrifice {this}"

        def resolve!
          game.choices.add(Choice.new(actor: source))
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
