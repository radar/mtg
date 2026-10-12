module Magic
  module Cards
    MomentOfGlory = Sorcery("Moment of Glory") do
      cost white: 1
      flashback Costs::Mana.new(generic: 4, white: 1)
    end

    class MomentOfGlory < Sorcery
      def target_choices
        battlefield.creatures.controlled_by(controller)
      end

      # "Put a +1/+1 counter on target creature you control. If this spell was cast from a graveyard,
      # also put a +1/+1 counter on each other creature you control."
      def resolve!(target:, flashback: false)
        add_counter("+1/+1", to: target)
        return unless flashback

        battlefield.creatures.controlled_by(controller).each do |creature|
          next if creature == target

          add_counter("+1/+1", to: creature)
        end
      end
    end
  end
end
