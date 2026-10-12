module Magic
  module Cards
    AleshasLegacy = Instant("Alesha's Legacy") do
      cost generic: 1, black: 1
    end

    class AleshasLegacy < Instant
      def target_choices
        battlefield.controlled_by(controller).creatures
      end

      def resolve!(target:)
        give_keyword(target, :deathtouch)
        give_keyword(target, :indestructible)
      end
    end
  end
end
