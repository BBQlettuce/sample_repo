require 'byebug'

class Array
  def my_inject(accumulator = nil, &block)
    if accumulator.nil?
      accumulator = first
      i = 1
    else
      i = 0
    end
    while i < length
      accumulator = block.call(accumulator, self[i])
      i += 1
    end
    accumulator
  end
end

def is_prime?(num)
  return false if num <= 1
  factors = []
  (2..num).each do |n|
    factors << n if num % n == 0
  end
  factors.length == 1
end

def primes(count)
  nums = []
  i = 1
  n = 2
  while i <= count
    if is_prime?(n)
      nums << n
      i += 1
    end
    n += 1
  end
  nums
end

# the "calls itself recursively" spec may say that there is no method
# named "and_call_original" if you are using an older version of
# rspec. You may ignore this failure.
# Also, be aware that the first factorial number is 0!, which is defined
# to equal 1. So the 2nd factorial is 1!, the 3rd factorial is 2!, etc.
def factorials_rec(num)
  return [1] if num == 1
  previous_factorial = factorials_rec(num - 1)
  last_fac = previous_factorial.last
  previous_factorial + [last_fac * (num - 1)]
end

class Array
  def dups
    output = {}
    idx = 0
    (idx...self.length).each do |i|
      el = self[i]
      if output[el].nil?
        output[el] = [i]
      else
        output[el] << i
      end
    end
    output.select {|el, dups| dups.length > 1}
  end
end

class String
  def symmetric_substrings
    output = []
    start_idx = 0
    while start_idx < self.length
      idx_range = 1
      while start_idx + idx_range <= self.length
        substring = self[start_idx, idx_range]
        output << substring if substring == substring.reverse &&
          substring.length > 1
        idx_range += 1
      end
      start_idx += 1
    end
    output
  end
end

class Array
  def merge_sort(&prc)
    #default is regular sort
    prc = Proc.new {|x, y| x <=> y} if prc.nil?
    #debugger
    dup = self.dup
    return dup if length <= 1
    left = dup.take(dup.length / 2).merge_sort(&prc)
    right = dup.drop(dup.length / 2).merge_sort(&prc)
    Array.merge(left, right, &prc)
  end

  private
  def self.merge(left, right, &prc)
    output = []
    until left.empty? || right.empty?
      case yield(left.first, right.first)
      when -1
        output << left.first
        left.shift
      else
        output << right.first
        right.shift
      end
    end
    output + left + right
  end
end
