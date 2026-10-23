module Magic
  module Cards
    SpymastersVault = Card("Spymaster's Vault") do
      type T::Land
    end

    class SpymastersVault < Card
      # "This land enters tapped unless you control a Swamp."
      def enters_tapped? = controller.permanents.by_any_type("Swamp").none?

      class ManaAbility < Magic::TapManaAbility
        choices :black
      end

      # "{B}, {T}: Target creature you control connives X, where X is the number of creatures that died this turn."
      class ConniveAbility < Magic::ActivatedAbility
        def costs = [Costs::Mana.new(black: 1), *Costs::Parser.parse(source: source, costs: "{T}")]

        def target_choices = controller.creatures

        def resolve!(target:)
          connive(target, amount: game.current_turn.events.count { _1.is_a?(Events::CreatureDied) })
        end
      end

      def activated_abilities = [ManaAbility, ConniveAbility]
    end
  end
end
