module Versionate
  extend ActiveSupport::Concern

  def self.included(base)
    base.extend(ClassMethods)
  end

  def save_current_version(options = {})
    success = true
    recursive = options[:resurive].nil? ? true : options[:recursive]
    unless versions.last && (versions.last.created_at == updated_at)
      success = false
      paper_trail_event = options[:paper_trail_event] || 'manual_version'
      paper_trail_event += ' (no child information)' unless recursive
      transaction do
        save_current_version_helper!(paper_trail_event, recursive)
        success = true
      end
    end
    (success) ? versions.last : false
  end

  def restore_version_created_at(date_created)
    version = versions.where(created_at: date_created).first
    restore_version(version)
  end

  def restore_version(version, duplicate = false)
    result = false
    #Before we restore, save the current version!
    if duplicate || save_current_version({paper_trail_event: 'pre_restore_save', with_children: false})
      error = nil
      transaction do
        if version
          result = self.class.restore_version_helper(version, duplicate)
        end
      end
    else
      error = 'Could not save previous version. Do not want to restore for fear of data loss'
    end
    result
  end

  module ClassMethods
    def modify_to_note_duplicate(reified, version)
      if reified.respond_to? :designer_note=
        reified.designer_note = "<p>This page has been restored from version with ID: #{version.id}, created on date #{version.created_at}</p> #{reified.designer_note}"
      end
      if reified.respond_to? :visible_to
        reified.visible_to = :none
      end
      if reified.respond_to? :title
        reified.title = "(Restored) #{reified.title}"
      end
    end

    def restore_version_helper(version, duplicate, override_parent = nil)
      reified = version.reify
      reified = reified.dup if duplicate
      unless override_parent.nil?
        reified.parent = override_parent
      end
      modify_to_note_duplicate(reified, version) if duplicate
      reified.save!
      #Note that at this point, reified is the new 'this'
      if reified.respond_to?(:restore_children_helper!, true) && version.child_versions != 'false'
        reified.restore_children_helper!(JSON.parse(version.child_versions, symbolize_names: true), duplicate)
      end
      reified
    end
  end

  def get_papertrail_serialized
    object_attrs = object_attrs_for_paper_trail self
    self.class.paper_trail_version_class.object_col_is_json? ? object_attrs : PaperTrail.serializer.dump(object_attrs)
  end

  def save_current_version_helper!(paper_trail_event, recursive)
    result = versions.last
    if result && (result.created_at == updated_at)
    else
      child_versions = 'false'
      if respond_to?(:save_children_versions!, true)
        child_versions = save_children_versions!(paper_trail_event, recursive)
      end
      result = versions.create(
          event: paper_trail_event,
          whodunnit: PaperTrail.whodunnit,
          created_at: updated_at,
          object: get_papertrail_serialized,
          child_versions: child_versions
      )
    end
    result
  end

end