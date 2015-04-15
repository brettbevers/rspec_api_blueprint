class NestedHash < Hash
  def new
    super do |hash, key|
      hash[key] = NestedHash.new
    end
  end

  def +(other)
    case other
      when String
        other
      else
        super
    end
  end

  def max_depth
    1 + map{ |k,v| v.is_a? NestedHash ? v.max_depth : 0 }.max
  end

  def min_depth
    1 + map{ |k,v| v.is_a? NestedHash ? v.min_depth : 0 }.min
  end

  def depth
    result = max_depth
    if result == min_depth
      result
    else
      nil
    end
  end
end