module Magic
  module Cards
    MorcantsEyes = Enchantment("Morcant's Eyes") do
      cost generic: 1, green: 1
      type T::Kindred, T::Enchantment, T::Creatures["Elf"]
    end

    class MorcantsEyes < Enchantment
      class UpkeepTrigger < TriggeredAbility::BeginningOfYourUpkeep
        def call
          game.choices.add(Magic::Choice::Surveil.new(actor: actor, amount: 1))
        end
      end

      def event_handlers = { Events::BeginningOfUpkeep => UpkeepTrigger }

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{4}{G}{G}, Sacrifice {this}"

        ElfToken = Token.create "Elf" do
          creature_type "Elf"
          power 2
          toughness 2
          colors :black, :green
        end

        def requirements_met? = game.can_cast_sorcery?(controller)

        def resolve!
          elves = controller.graveyard.cards.count { |card| card.type?("Elf") }
          trigger_effect(:create_token, token_class: ElfToken, amount: elves)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
