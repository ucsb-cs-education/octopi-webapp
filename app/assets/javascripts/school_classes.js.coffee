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

  $(document).on "click", ".unlock-all", ->
    confirm("This will unlock for all students in this class and cannot be easily undone.\nDo you wish to continue?")

  new Grid("progress-table-div",
    srcType: "dom"
    srcData: "tasks-table"
    allowGridResize: false
    allowColumnResize: false
    allowClientSideSorting: true
    colSortType: [
      "string"
      "string"
      "number"
    ]
    allowSelections: true
    allowMultipleSelections: false
    showSelectionColumn: false
    fixedCols: 2
    )


SchoolClassesStudentProgressController = Paloma.controller('SchoolClasses/SchoolClassesStudentProgress')
SchoolClassesStudentProgressController.prototype.student_progress = () ->
  $(document).on "click", ".student_progress", ->
    confirm("This will lock all activities and tasks this student has not responded to nor has unlocked by completing a prerequisite task.\n
    This may take some time.\nContinue?")