module Magic
  module Cards
    CrashThrough = Sorcery("Crash Through") do
      cost red: 1
    end

    class CrashThrough < Sorcery
      def resolve!
        controller.creatures.each(&:grant_trample!)
        trigger_effect(:draw_cards, number_to_draw: 1)

        super
      end
    end
  end
end
