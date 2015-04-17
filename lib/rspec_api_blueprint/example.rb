class Example

  ACTION_REGEXP = /\[(GET|HEAD|POST|PUT|DELETE|TRACE|OPTIONS|CONNECT|PATCH)\]/i

  def initialize(example)
    @example = example
  end

  attr_reader :example

  def levels
    return @levels if @levels
    all_levels = example_groups.reverse.map{ |group| group[:description_args].first }
    index = all_levels.find_index{ |description| ACTION_REGEXP === description }
    @levels = all_levels[0..index]
  end

  def description
    example.description
  end

  def headers
    example.metadata[:headers]
  end

  private

  def example_groups
    @example_groups ||= Array.new.tap do |example_groups|
      example_group = example.metadata[:example_group]
      while example_group
        example_groups << example_group
        example_group = example_group[:example_group]
      end
    end
  end

end