class StudentResponse::ProjectResponseLaplayaFile < StudentResponse::StudentResponseLaplayaFile
  belongs_to :module_page, foreign_key: :parent_id
end