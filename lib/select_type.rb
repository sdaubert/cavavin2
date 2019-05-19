SelectOptions = Struct.new(:id, :name)

class SelectType

  attr_reader :type_name, :options

  def initialize(name)
    @type_name = name
    @options = []
  end

  def <<(option)
    if option.class == Array
      @options += option
    else
      @options << option
    end
  end

end
