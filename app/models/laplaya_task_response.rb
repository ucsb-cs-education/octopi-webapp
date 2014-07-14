class LaplayaTaskResponse < TaskResponse
  has_one :laplaya_file, foreign_key: :laplaya_file_id

end