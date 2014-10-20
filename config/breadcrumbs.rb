crumb :root do
  link 'Home', root_path
end

crumb :staff_root do
  link 'Staff Home', staff_root_path
end

crumb :staff_school do |school|
  link school.name, school_path(school)
  parent :staff_root
end

crumb :staff_school_new_class do |school|
  link 'New Class', new_school_school_class_path(school)
  parent :staff_school, school
end

crumb :staff_school_students do |school|
  link 'Students', school_students_path(school)
  parent :staff_school, school
end

crumb :staff_school_student do |student|
  link student.name, student_path(student)
  parent :staff_school_students, student.school
end

crumb :staff_school_classes do
  link 'Your classes', teacher_school_classes_path
  parent :staff_root
end

crumb :staff_school_class do |klass|
  link klass.name, school_class_path(klass)
  parent :staff_school, klass.school
end

crumb :staff_school_class_edit do |klass|
  link "#{klass.name} (Edit)", edit_school_class_path(klass)
  parent :staff_school_class, klass
end

crumb :staff_school_class_edit_students do |klass|
  link "#{klass.name} (Edit Students)", edit_school_class_path(klass)
  parent :staff_school_class, klass
end

crumb :curriculum_index do
  link 'All curricula', curriculum_pages_path
  parent :staff_root
end

crumb :curriculum_page do |page|
  link page.title, curriculum_page_path(page)
  parent :curriculum_index
end

crumb :module_page do |page|
  link page.title, module_page_path(page)
  parent :curriculum_page, page.parent
end

crumb :activity_page do |page|
  link page.title, activity_page_path(page)
  parent :module_page, page.parent
end

crumb :laplaya_task do |page|
  link page.title, laplaya_task_path(page)
  parent :activity_page, page.parent
end

crumb :assessment_task do |page|
  link page.title, assessment_task_path(page)
  parent :activity_page, page.parent
end

crumb :offline_task do |page|
  link page.title, assessment_task_path(page)
  parent :activity_page, page.parent
end

crumb :assessment_question do |page|
  link page.title, assessment_question_path(page)
  parent :assessment_task, page.parent
end

# crumb :projects do
#   link "Projects", projects_path
# end

# crumb :project do |project|
#   link project.name, project_path(project)
#   parent :projects
# end

# crumb :project_issues do |project|
#   link "Issues", project_issues_path(project)
#   parent :project, project
# end

# crumb :issue do |issue|
#   link issue.title, issue_path(issue)
#   parent :project_issues, issue.project
# end

# If you want to split your breadcrumbs configuration over multiple files, you
# can create a folder named `config/breadcrumbs` and put your configuration
# files there. All *.rb files (e.g. `frontend.rb` or `products.rb`) in that
# folder are loaded and reloaded automatically when you change them, just like
# this file (`config/breadcrumbs.rb`).