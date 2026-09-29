module Magic
  module Cards
    DawnhandDissident = Creature("Dawnhand Dissident") do
      cost black: 1
      creature_type "Elf Warlock"
      power 1
      toughness 2
    end

    class DawnhandDissident < Creature
      # "{T}, Blight 1: Surveil 1."
      class SurveilAbility < Magic::ActivatedAbility
        costs "{T}, Blight 1"

        def resolve!
          game.choices.add(Magic::Choice::Surveil.new(actor: source, amount: 1))
        end
      end

      # "{T}, Blight 2: Exile target card from a graveyard."
      class ExileAbility < Magic::ActivatedAbility
        costs "{T}, Blight 2"

        def single_target?
          true
        end

        def target_choices
          game.players.flat_map { |player| player.graveyard.cards }
        end

        def resolve!(target:)
          trigger_effect(:exile, target: target)
          source.exiled_cards << target
        end
      end

      def activated_abilities = [SurveilAbility, ExileAbility]

      # "During your turn, you may cast creature spells from among cards you own exiled
      # with this creature by removing three counters from among creatures you control in
      # addition to paying their other costs."
      class CastExiledCreatures < StaticAbility
        def permits_casting_from_exile?(card, player)
          # No affordability check: the counters are removed before legality is checked.
          castable?(card, player)
        end

        def additional_cost_for(card, player)
          Costs::RemoveCountersFromCreatures.new(3) if card.zone&.exile? && castable?(card, player)
        end

        private

        def castable?(card, player)
          player == controller && game.current_turn.active_player == player &&
            card.creature? && card.owner == player && @source.exiled_cards.include?(card)
        end
      end

      def static_abilities = [CastExiledCreatures]
    end
  end
end
