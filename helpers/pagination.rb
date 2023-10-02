class PaginatedArray
  def initialize(array_to_page, params)
    params = {} if params.nil?
    @array = validate_array(array_to_page)
    @elements_per_page = validate_elements_per_page(params['page_size'], 5)
    @last_page = set_last_page
    @current_page = current_page_set(params['page'])
  end

  def validate_array(array)
    if array.nil? || !array.is_a?(Array) || array.empty?
      []
    else
      array
    end
  end

  def validate_elements_per_page(elements_per_page, default_value)
    if elements_per_page.nil? || !Validation.str_is_integer?(elements_per_page) ||
       elements_per_page.to_i < 5
      default_value
    else
      elements_per_page.to_i
    end
  end

  def validate_page_no(page_no)
    if page_no.nil? || !Validation.str_is_integer?(page_no) || page_no.to_i <= 0
      1
    else
      page_no.to_i
    end
  end

  # Generating paginated array
  def paginated_array
    return [] if @array.empty?

    first_index = @elements_per_page * (@current_page - 1)
    last_index = @elements_per_page * @current_page

    @array.slice(first_index...last_index)
  end

  # Setting current_page (which page we want to have displayed)
  def current_page_set(page_no)
    # Validating if provided page is positive integer if no, we assign 1
    page = validate_page_no(page_no)
    # Minimum index in array
    minimum_size = @elements_per_page * page
    # Maximum index in array
    maximum_size = @array.length

    # If minimum index is bigger than array size, it means that given page_no is too big
    # and we set current_page as the last page, otherwise we just set current page as provided page_no
    if minimum_size > maximum_size
      @last_page
    else
      page
    end
  end

  # Last page is set before current page
  def set_last_page
    # If array is empty, we've got only one page
    if @array.empty?
      1
    else
      # Now we divide array length by elements_per_page, if there is remainder we add 1 to the last page value
      remainder = 0
      remainder = 1 if @array.length % @elements_per_page != 0
      (@array.length / @elements_per_page) + remainder
    end
  end

  def all_elements
    @array
  end

  def first_displayed
    if [1, 2].include?(@current_page)
      1
    elsif @last_page - @current_page < 2
      if (@last_page - 4).positive?
        @last_page - 4
      else
        1
      end
    else
      @current_page - 2
    end
  end

  def last_displayed
    if [1, 2].include?(@current_page)
      [@last_page, 5].min
    elsif @last_page - @current_page <= 2
      @last_page
    else
      @current_page + 2
    end
  end

  attr_reader :last_page, :elements_per_page, :current_page
end
