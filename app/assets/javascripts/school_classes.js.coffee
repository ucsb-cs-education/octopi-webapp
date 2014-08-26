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

SchoolClassesController.prototype.edit_students_via_csv = () ->



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
    confirm("This will reset the student's progress to where it currently should be based on what they have completed.
        Tasks and Activities that were manually unlocked for them and they have not completed or completed the prerequisites of will be locked again.\nContinue?")