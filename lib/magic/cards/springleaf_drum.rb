module Magic
  module Cards
    class SpringleafDrum < Artifact
      card_name "Springleaf Drum"
      cost generic: 1

      # "{T}, Tap an untapped creature you control: Add one mana of any color."
      class ManaAbility < Magic::ManaAbility
        choices :all

        def costs
          [Costs::SelfTap.new(source), Costs::MultiTap.new(1) { controller.creatures.untapped }]
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
