class BaseLaplayaFile < LaplayaFile
  include Curriculumify
  include Versionate
  undef :visible_to
  undef :visible_to=
end