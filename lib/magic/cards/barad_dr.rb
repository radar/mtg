module Magic
  module Cards
    BaradDr = Card("Barad-dûr") do
      type T::Super::Legendary, T::Land
    end

    class BaradDr < Card
      # "This land enters tapped unless you control a legendary creature."
      def enters_tapped? = controller.creatures.none?(&:legendary?)

      # "{T}: Add {B}."
      class ManaAbility < Magic::TapManaAbility
        choices :black
      end

      # "{X}{X}{B}, {T}: Amass Orcs X. Activate only if a creature died this turn."
      class AmassAbility < Magic::ActivatedAbility
        costs "{X}{X}{B}, {T}"

        def requirements_met? = creature_died_this_turn?

        def resolve!(x:)
          Magic::Amass.call(source: source, controller: controller, amount: x, subtype: "Orc")
        end
      end

      def activated_abilities = [ManaAbility, AmassAbility]
    end
  end
end
