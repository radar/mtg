module Magic
  class CardList < SimpleDelegator
    def controlled_by(player)
      self.class.new(select { |card| card.controller == player })
    end
  end
end
