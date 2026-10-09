module Magic
  module Cards
    HeadOfTheHunt = Creature("Head of the Hunt") do
      cost generic: 2, black: 2
      creature_type "Wolf"
      keywords :flash
      power 4
      toughness 3
    end

    class HeadOfTheHunt < Creature
      WolfToken = Token.create "Wolf" do
        creature_type "Wolf"
        power 2
        toughness 2
        colors :green
      end

      # "If a creature an opponent controls would die, exile it instead. When you do, create a 2/2 green Wolf creature
      # token."
      class ExileInsteadReplacement < ReplacementEffect
        def applies?(effect)
          !!effect.from&.battlefield? && effect.to.graveyard? && effect.target.creature? && effect.target.controller != receiver.controller
        end

        def call(effect)
          receiver.trigger_effect(:create_token, token_class: WolfToken)
          Effects::ExilePermanent.new(source: receiver, target: effect.target)
        end
      end

      def replacement_effects
        { Effects::MovePermanentZone => ExileInsteadReplacement }
      end
    end
  end
end
