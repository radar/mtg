module Magic
  module Cards
    WitherAndBloom = Instant("Wither and Bloom") do
      cost generic: 1, black: 1
    end

    class WitherAndBloom < Instant
      # Target creature gets -3/-3 until end of turn.
      def target_choices = battlefield.creatures

      def resolve!(target:)
        pump target, -3, -3
      end

      # {1}{B}, Exile this card from your graveyard: Put a +1/+1 counter on target creature you control. Activate
      # only as a sorcery.
      class GraveyardAbility < Magic::ActivatedAbility
        costs "{1}{B}, Exile {this}"

        activate_from_graveyard_as_sorcery

        def target_choices = controller.creatures

        def resolve!(target:)
          add_counter("+1/+1", to: target)
        end
      end

      def graveyard_abilities = [GraveyardAbility.new(source: self)]
    end
  end
end
