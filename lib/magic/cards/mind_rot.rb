module Magic
  module Cards
    MindRot = Sorcery("Mind Rot") do
      cost generic: 2, black: 1
    end

    class MindRot < Sorcery
      def target_choices
        game.players
      end

      def resolve!(target:)
        2.times { game.add_choice(Magic::Choice::Discard.new(player: target)) }
      end
    end
  end
end
