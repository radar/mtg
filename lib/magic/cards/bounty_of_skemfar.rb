module Magic
  module Cards
    BountyOfSkemfar = Sorcery("Bounty of Skemfar") do
      cost generic: 2, green: 1
    end

    class BountyOfSkemfar < Sorcery
      class Choice < Magic::Choice
        attr_reader :revealed

        def initialize(actor:)
          super(actor: actor)
          @revealed = Magic::CardList.new(actor.controller.library.first(6))
          actor.controller.reveal(*revealed)
        end

        def land_choices
          revealed.lands
        end

        def elf_choices
          revealed.by_any_type("Elf")
        end

        def resolve!(land: nil, elf: nil)
          remaining = revealed.dup

          if land
            land.resolve!(enters_tapped: true)
            remaining.delete(land)
          end

          if elf
            elf.move_to_hand!
            remaining.delete(elf)
          end

          remaining.shuffle.each do |card|
            controller.library.remove(card)
            controller.library.push(card)
          end
        end
      end

      def resolve!
        game.choices.add(BountyOfSkemfar::Choice.new(actor: self))
      end
    end
  end
end
