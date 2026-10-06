module Magic
  # Lets one game's shuffles and random picks come from its own seeded Random, so a recorded game can be replayed.
  #
  # `Magic.with_random(rng) { ... }` makes every Array#shuffle, #shuffle! and #sample in the block (on this thread) use
  # +rng+. Outside such a block they use Ruby's global Random, as before. Installed once by lib/magic.rb.
  module Randomness
    module ArrayDefaults
      def shuffle(random: Magic.random) = super(random: random)
      def shuffle!(random: Magic.random) = super(random: random)
      def sample(*args, random: Magic.random) = super(*args, random: random)
    end

    def self.install!
      Array.prepend(ArrayDefaults) unless Array.include?(ArrayDefaults)
    end
  end

  def self.random = Thread.current[:magic_random] || ::Random

  def self.with_random(random)
    previous = Thread.current[:magic_random]
    Thread.current[:magic_random] = random
    yield
  ensure
    Thread.current[:magic_random] = previous
  end
end
