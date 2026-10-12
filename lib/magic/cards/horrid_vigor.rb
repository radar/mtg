module Magic
  module Cards
    HorridVigor = Instant("Horrid Vigor") do
      cost generic: 1, green: 1
    end

    class HorridVigor < Instant
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        trigger_effect(:grant_keyword, target: target, keyword: :deathtouch)
        trigger_effect(:grant_keyword, target: target, keyword: :indestructible)
      end
    end
  end
end
