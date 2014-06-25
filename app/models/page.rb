class Page < ActiveRecord::Base
  resourcify

  protected
  def difference_between_arrays(array1, array2)
    difference = array1.dup
    array2.each do |element|
      index = difference.index(element)
      if index
        difference.delete_at(index)
      end
    end
    difference
  end

  def same_elements?(array1, array2)
    extra_items = difference_between_arrays(array1, array2)
    missing_items = difference_between_arrays(array2, array1)
    extra_items.empty? & missing_items.empty?
  end

end
