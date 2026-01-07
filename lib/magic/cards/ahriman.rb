module Magic
  module Cards
    Ahriman = Creature("Ahriman") do
      cost generic: 2, black: 1
      power 2
      toughness 2
      keywords :deathtouch, :flying
      creature_type "Eye Horror"
    end

    class Ahriman < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        # {3}, Sacrifice another creature or artifact: Draw a card.
        def costs
          other_creatures_or_artifacts = controller.permanents.by_any_type("Creature", "Artifact").except(source)
          [Costs::Mana.new("{3}"), Costs::Sacrifice.new(source, other_creatures_or_artifacts)]
        end

        def resolve!
          trigger_effect(:draw_card)
        end
      end

      def activated_abilities
        [ActivatedAbility]
      end
    end
  end
end
