module Magic
  module Cards
    DakmorSalvage = Card("Dakmor Salvage") do
      type "Land"
      enters_tapped
    end

    class DakmorSalvage < Card
      class DredgeEffect < Effect
        def initialize(source:)
          super
        end

        def resolve!
          source.controller.mill(2)
          source.move_to_hand!
        end
      end

      class DredgeReplacement < ReplacementEffect
        def applies?(effect)
          effect.player == receiver.owner && receiver.zone&.graveyard? && effect.is_a?(Effects::DrawCards)
        end

        def call(_effect)
          DredgeEffect.new(source: receiver)
        end
      end

      class ManaAbility < Magic::TapManaAbility
        choices :black
      end

      def activated_abilities = [ManaAbility]

      def replacement_effects
        { Effects::DrawCards => DredgeReplacement }
      end
    end
  end
end