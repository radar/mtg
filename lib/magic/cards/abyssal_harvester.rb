module Magic
  module Cards
    AbyssalHarvester = Creature("Abyssal Harvester") do
      cost generic: 1, black: 2
      creature_type("Demon Warlock")
      power 3
      toughness 2
    end

    class AbyssalHarvester < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{T}"

        def target_choices
          game.graveyard_cards.by_any_type("Creature").select { |card| game.current_turn.events.any? { |e| e.is_a?(Events::CardEnteredZone) && e.card == card && e.to.graveyard? } }
        end

        def resolve!(target:)
          target.exile!
          copy = Permanent.resolve(game: game, owner: controller, card: target, token: true, copy: true, cast: false)
          copy.add_types(T::Creatures["Nightmare"], until_eot: false)
          controller.permanents.select { _1.token? && _1.type?("Nightmare") && _1 != copy }.each(&:exile!)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
