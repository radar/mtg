module Magic
  module Cards
    AdamantWill = Instant("Adamant Will") do
      cost generic: 1, white: 1
    end

    class AdamantWill < Instant
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        pump(target, 2, 2)
        trigger_effect(:grant_keyword, target: target, keyword: :indestructible)
      end
    end
  end
end
