class MoveOwnerRoleToLaplayaDatabase < ActiveRecord::Migration
  def change
    LaplayaFile.where(user_id: nil).find_each do |file|
      file = file.becomes(LaplayaFile)
      user = User.with_role(:owner, file).first
      if user
        file.update_attributes!(owner: user)
        user.remove_role(:owner, file)
      end
    end
  end
end
