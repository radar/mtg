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
        give_keyword(target, :deathtouch)
        give_keyword(target, :indestructible)
      end
    end
  end
end
