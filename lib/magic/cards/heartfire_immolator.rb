module Magic
  module Cards
    HeartfireImmolator = Creature("Heartfire Immolator") do
      cost generic: 1, red: 1
      creature_type("Human Wizard")
      keywords :prowess
      power 2
      toughness 2
    end

    class HeartfireImmolator < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{R}, Sacrifice {this}"

        def target_choices
          battlefield.creatures + battlefield.planeswalkers
        end

        def resolve!(target:)
          deal_damage source.power, to: target, source: source
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
