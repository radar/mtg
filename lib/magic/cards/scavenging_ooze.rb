module Magic
  module Cards
    ScavengingOoze = Creature("Scavenging Ooze") do
      cost generic: 1, green: 1
      creature_type "Ooze"
    end

    class ScavengingOoze < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        def costs = [Costs::Mana.new(green: 1)]

        def single_target?
          true
        end

        def target_choices
          game.players.flat_map { _1.graveyard.cards }
        end

        def resolve!(target:)
          trigger_effect(:exile, target: target)
          if target.creature?
            source.add_counter(Counters::Plus1Plus1)
            source.controller.gain_life(1)
          end
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
