class StudentResponse::SandboxResponseLaplayaFile < StudentResponse::StudentResponseLaplayaFile
  belongs_to :module_page, foreign_key: :parent_id
  resourcify
end