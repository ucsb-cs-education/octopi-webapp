# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

SchoolClassesController = Paloma.controller('SchoolClasses');

SchoolClassesController.prototype.show = () ->
  SortableJS()

SchoolClassesController.prototype.edit = () ->

  showFormAndHideAddNewStudentButton = () ->
    $("#new_student").removeClass("hidden")
    $("#new_student_button").addClass("hidden")

  hideFormAndShowNewStudentButton = () ->
    $("#new_student").addClass("hidden")
    $("#new_student_button").removeClass("hidden")

  addButtonOnClicks = () ->
    $("#new_student_button").click(showFormAndHideAddNewStudentButton)
    $("#cancel_new_student_button").click(hideFormAndShowNewStudentButton)

  SortableJS()

  $(document).ready(addButtonOnClicks);
  $(document).ready()

SchoolClassesActivitiesController = Paloma.controller('SchoolClasses/SchoolClassesActivities')
SchoolClassesActivitiesController.prototype.activity_page = () ->
  $(".unlock-all").click ->
    confirm "This will unlock the task for all students and cannot be undone.\nDo you wish to continue?"
