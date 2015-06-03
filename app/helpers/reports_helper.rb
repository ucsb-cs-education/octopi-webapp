require 'json'
require 'csv'
module ReportsHelper
  def conv_json_to_ary(cols, json_obj)
    h = JSON.parse(json_obj)
    h.values_at(*cols)
  end

end
