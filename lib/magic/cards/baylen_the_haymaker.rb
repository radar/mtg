module Magic
  module Cards
    BaylenTheHaymaker = Creature("Baylen, the Haymaker") do
      legendary_creature_type "Rabbit Warrior"
      cost red: 1, green: 1, white: 1
      power 4
      toughness 3
    end

    class BaylenTheHaymaker < Creature
      # Tap two untapped tokens you control: Add one mana of any color.
      class ManaAbility < Magic::ManaAbility
        choices :all

        def costs = [Costs::MultiTap.new(2) { controller.permanents.select(&:token?).reject(&:tapped?) }]
      end

      # Tap three untapped tokens you control: Draw a card.
      class DrawAbility < Magic::ActivatedAbility
        def costs = [Costs::MultiTap.new(3) { controller.permanents.select(&:token?).reject(&:tapped?) }]

        def resolve!
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      # Tap four untapped tokens you control: Put three +1/+1 counters on Baylen. It gains trample until end of
      # turn.
      class GrowAbility < Magic::ActivatedAbility
        def costs = [Costs::MultiTap.new(4) { controller.permanents.select(&:token?).reject(&:tapped?) }]

        def resolve!
          trigger_effect(:add_counter, counter_type: "+1/+1", target: source, amount: 3)
          trigger_effect(:grant_keyword, target: source, keyword: :trample)
        end
      end

      def activated_abilities = [ManaAbility, DrawAbility, GrowAbility]
    end
  end
end
