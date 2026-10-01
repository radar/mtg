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
        trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 1)
        trigger_effect(:grant_keyword, target: target, keyword: :flying)
        trigger_effect(:grant_keyword, target: target, keyword: :indestructible)
      end
    end
  end
end
