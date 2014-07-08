# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

SchoolClassesController = Paloma.controller('SchoolClasses');

SchoolClassesController.prototype.show = () ->
  SortableJS()

SchoolClassesController.prototype.edit = () ->

  showFormAndHideAddNewStudentButton = () ->
    $("#create_and_add_student_form").show()
    $("#toggle_add_new_student_button").hide()
    $("#cancel_button").show()
    return

  hideFormAndShowNewStudentButton = () ->
    $("#create_and_add_student_form").hide()
    $("#toggle_add_new_student_button").show()
    $("#cancel_button").hide()
    return

  addButtonOnClicks = () ->
    $("#toggle_add_new_student_button").click(showFormAndHideAddNewStudentButton)
    $("#cancel_button").click(hideFormAndShowNewStudentButton)

  SortableJS()

  $(document).ready(addButtonOnClicks);
  $(document).ready()
