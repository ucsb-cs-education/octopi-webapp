class MoveOwnerRoleToLaplayaDatabase < ActiveRecord::Migration
  def change
    LaplayaFile.where(user_id: nil).find_each do |file|
      user = User.with_role(:owner, file).first
      if user
        file.update_attributes!(owner: User.with_role(:owner, file).first)
        user.remove_role(:owner, file)
      end
    end
  end
end
