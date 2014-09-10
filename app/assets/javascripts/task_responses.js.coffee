TaskResponsesController = Paloma.controller('TaskResponses');

TaskResponsesController.prototype.show = () ->
  $("#change-student").change ->
    $(this).attr "action", $("#change-student option:selected").val()

TaskResponsesController.prototype.index = () ->
  SortableJS()