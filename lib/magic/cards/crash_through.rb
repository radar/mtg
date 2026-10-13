module Magic
  module Cards
    CrashThrough = Sorcery("Crash Through") do
      cost red: 1
    end

    class CrashThrough < Sorcery
      def resolve!
        controller.creatures.each(&:grant_trample!)
        draw_card

        super
      end
    end
  end
end
