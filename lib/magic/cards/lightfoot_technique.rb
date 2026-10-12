module Magic
  module Cards
    LightfootTechnique = Instant("Lightfoot Technique") do
      cost generic: 1, white: 1
    end

    class LightfootTechnique < Instant
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        add_counter("+1/+1", to: target)
        trigger_effect(:grant_keyword, target: target, keyword: :flying)
        trigger_effect(:grant_keyword, target: target, keyword: :indestructible)
      end
    end
  end
end
