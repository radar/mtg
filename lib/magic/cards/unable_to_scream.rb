module Magic
  module Cards
    UnableToScream = Aura("Unable to Scream") do
      cost blue: 1
    end

    class UnableToScream < Aura
      enchant "Creature"

      def target_choices = battlefield.creatures

      # "Enchanted creature loses all abilities and is a Toy artifact creature with base power and toughness 0/2 in
      # addition to its other types."
      class LosesAbilities < Abilities::Static::CharacteristicSetting
        applies_to_target
        sets_base_power_and_toughness 0, 2
        loses_all_abilities
      end

      class ToyTypes < Abilities::Static::TypeGrant
        type_grants T::Artifact, T::Creature, T::Creatures["Toy"]
        applies_to_target
      end

      # "As long as enchanted creature is face down, it can't be turned face up."
      class CantBeTurnedFaceUp < StaticAbility
        def prevents_turning_face_up?(permanent) = permanent.equal?(@source.attached_to)
      end

      def static_abilities = [LosesAbilities, ToyTypes, CantBeTurnedFaceUp]
    end
  end
end
