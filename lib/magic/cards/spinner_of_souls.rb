module Magic
  module Cards
    SpinnerOfSouls = Creature("Spinner of Souls") do
      cost generic: 2, green: 1
      creature_type("Spider Spirit")
      keywords :reach
      power 4
      toughness 3
    end

    class SpinnerOfSouls < Creature
      class CreatureDiesTrigger < TriggeredAbility
        def should_perform?
          you? && event.permanent != actor && !event.permanent.token?
        end

        class MayChoice < Magic::Choice::May
          def resolve!
            library = controller.library
            found = library.find { _1.type?("Creature") }
            revealed = library.take_while { !_1.equal?(found) }
            trigger_effect(:reveal_cards, target: [*revealed, found].compact)
            found&.move_to_hand!
            revealed.shuffle.each do |card|
              library.remove(card)
              library.push(card)
            end
          end
        end

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def event_handlers = super.merge({ Events::CreatureDied => CreatureDiesTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
