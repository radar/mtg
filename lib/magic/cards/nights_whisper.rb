module Magic
  module Cards
    class NightsWhisper < Sorcery
      card_name "Night's Whisper"
      cost generic: 1, black: 1

      def resolve!
        2.times { controller.draw! }
        controller.lose_life(2)
      end
    end
  end
end