class BaseLaplayaFile < LaplayaFile
  include Curriculumify
  undef :visible_to
  undef :visible_to=
end