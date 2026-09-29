module Magic
  module Cards
    SoulbrightSeeker = Creature("Soulbright Seeker") do
      cost red: 1
      creature_type("Elemental Sorcerer")
      power 2
      toughness 1
    end

    class SoulbrightSeeker < Creature
      # As an additional cost to cast this spell, behold an Elemental or pay {2}.
      def additional_costs
        [Costs::Behold.new(self, type: "Elemental", or_mana: { generic: 2 })]
      end

      # {R}: Target creature you control gains trample until end of turn. If this is the third time
      # this ability has resolved this turn, add {R}{R}{R}{R}.
      class TrampleAbility < Magic::ActivatedAbility
        costs "{R}"

        def single_target?
          true
        end

        def target_choices
          battlefield.controlled_by(controller).creatures
        end

        def resolve!(target:)
          trigger_effect(:grant_keyword, target: target, keyword: :trample)
          source.trigger_once_this_turn!(self.class)
          controller.add_mana(red: 4) if source.triggered_once_keys_this_turn.count(self.class) == 3
        end
      end

      def activated_abilities = [TrampleAbility]
    end
  end
end
