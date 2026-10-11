module Magic
  module Cards
    KeysToTheHouse = Artifact("Keys to the House") do
      cost generic: 1
    end

    class KeysToTheHouse < Artifact
      class BasicLandChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :hand, reveal: true, filter: Filter[:basic_lands])
        end
      end

      # "{1}, {T}, Sacrifice this artifact: Search your library for a basic land card, reveal it, put it into your hand,
      # then shuffle."
      class SearchForBasicLand < Magic::ActivatedAbility
        costs "{1}, {T}, Sacrifice {this}"

        def resolve!
          game.choices.add(BasicLandChoice.new(actor: source))
        end
      end

      # "{3}, {T}, Sacrifice this artifact: Lock or unlock a door of target Room you control. Activate only as a
      # sorcery." The Room is chosen as the ability resolves.
      class LockOrUnlockDoor < Magic::ActivatedAbility
        costs "{3}, {T}, Sacrifice {this}"

        def requirements_met?
          game.can_cast_sorcery?(controller)
        end

        def resolve!
          choice = Magic::Choice::LockOrUnlockDoor.new(actor: source)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def activated_abilities = [SearchForBasicLand, LockOrUnlockDoor]
    end
  end
end
