module Magic
  module Cards
    BookOfMazarbul = Saga("Book of Mazarbul") do
      cost generic: 2, red: 1
    end

    class BookOfMazarbul < Saga
      # I -- Amass Orcs 1.
      class Chapter1 < Saga::ChapterAbility
        def resolve!
          Magic::Amass.call(source: self, controller: controller, amount: 1, subtype: "Orc")
        end
      end

      # II -- Amass Orcs 2.
      class Chapter2 < Saga::ChapterAbility
        def resolve!
          Magic::Amass.call(source: self, controller: controller, amount: 2, subtype: "Orc")
        end
      end

      # III -- Creatures you control get +1/+0 and gain menace until end of turn.
      class Chapter3 < Saga::ChapterAbility
        def resolve!
          controller.creatures.each do |creature|
            pump(creature, 1, 0)
            give_keyword(creature, :menace)
          end
        end
      end

      def chapters = [Chapter1, Chapter2, Chapter3]
    end
  end
end
