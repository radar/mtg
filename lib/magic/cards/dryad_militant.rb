module Magic
  module Cards
    DryadMilitant = Creature("Dryad Militant") do
      cost green_or_white: 1
      creature_type("Dryad Soldier")
      power 2
      toughness 1
    end

    class DryadMilitant < Creature
      class ExileInsteadOfGraveyard < ReplacementEffect
        def applies?(effect)
          effect.to.graveyard? && effect.target.respond_to?(:any_type?) && effect.target.any_type?("Instant", "Sorcery")
        end

        def call(effect) = Effects::ExileCard.new(source: receiver, target: effect.target)
      end

      def replacement_effects = { Effects::MoveCardZone => ExileInsteadOfGraveyard }
    end
  end
end
