module Magic
  module Cards
    class ContainmentPriest < Creature
      card_name "Containment Priest"
      cost generic: 1, white: 1
      creature_type("Human Cleric")
      keywords :flash
      power 2
      toughness 2
    end

    class ContainmentPriest < Creature
      class ExileEffect < ReplacementEffect
        def applies?(effect)
          permanent = effect.permanent
          effect.to.battlefield? &&
            permanent.creature? &&
            !permanent.token? &&
            !permanent.cast?
        end

        def call(effect)
          Effects::ExilePermanent.new(
            source: receiver,
            target: effect.permanent,
          )
        end
      end

      def replacement_effects
        {
          Effects::MovePermanentZone => ExileEffect
        }
      end
    end
  end
end
