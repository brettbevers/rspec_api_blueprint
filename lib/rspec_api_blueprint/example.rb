class Example

  ACTION_REGEXP = /\[(GET|HEAD|POST|PUT|DELETE|TRACE|OPTIONS|CONNECT|PATCH)\]/i

  def initialize(example)
    @example = example
  end

  attr_reader :example

  def levels
    return @levels if @levels
    index = group_descriptions.find_index{ |description| ACTION_REGEXP === description }
    @levels = index ? group_descriptions[0..index] : []
  end

  def description
    example.description
  end

  def headers
    example.metadata[:headers]
  end

  private

  def group_descriptions
    @group_descriptions ||= example.example_group.parent_groups.map{ |i| i.metadata[:description] }.reverse
  end

end