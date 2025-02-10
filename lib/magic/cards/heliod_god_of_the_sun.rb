module Magic
  module Cards
    HeliodGodOfTheSun = Creature("Heliod, God of the Sun") do
      type T::Super::Legendary, T::Enchantment, T::Creature, "God"
      cost "{3}{W}"
      keywords :indestructible
      power 5
      toughness 6
    end

    class HeliodGodOfTheSun < Creature
      ClericToken = Token.create "Cleric" do
        type T::Enchantment, T::Creature, T::Creatures["Cleric"]
        power 2
        toughness 1
        colors :white
      end

      class ActivatedAbility < Magic::ActivatedAbility
        def costs = [Costs::Mana.new(generic: 2, white: 2)]

        def resolve!
          source.create_token(token_class: ClericToken)
        end
      end

      def activated_abilities
        [ActivatedAbility]
      end

      class TypeModification < Abilities::Static::TypeRemoval
        def initialize(source:)
          @source = source
        end

        def type_removal
          [
            T::Creature
          ]
        end

        def applicable_targets
          if controller.devotion(:white) >= 5
            []
          else
            [source]
          end
        end
      end

      class VigilanceGrant < Abilities::Static::KeywordGrant
        def keyword_grants
          [Keywords::VIGILANCE]
        end

        def applicable_targets
          controller.creatures - [source]
        end
      end

      def static_abilities
        [
          TypeModification,
          VigilanceGrant,
        ]
      end
    end
  end
end
