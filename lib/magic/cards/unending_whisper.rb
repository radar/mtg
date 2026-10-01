module Magic
  module Cards
    UnendingWhisper = Sorcery("Unending Whisper") do
      cost blue: 1
      harmonize Costs::Mana.new(generic: 5, blue: 1)
    end

    class UnendingWhisper < Sorcery
      def resolve!
        trigger_effect(:draw_card)
      end
    end
  end
end
