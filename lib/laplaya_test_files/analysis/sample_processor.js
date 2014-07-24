exports.process = function (xmlObj) {
    var result = {};
    result['objectives'] = {};
    result['objectives']['Made by Calixtemayoraz'] = false;
    try {
        var notes = xmlObj.project.notes[0];
        //This part bothers me, but I don't see any options to change how this works.
        //If a 'text' node has any properties, then it will be an object, where the properties are
        //in the node.$ attribute, and the text is in the node._ attribute. If there are no properties
        //then it will be a string directly.
        if (!(typeof notes == 'string' || notes instanceof String)) {
            notes = notes._
        }
        if (notes.indexOf("calixtemayoraz") != -1) {
            result['objectives']['Made by Calixtemayoraz'] = true;
        }
    }
    catch (err) {

    }
    var completed = true;
    for (var property in result['objectives']) {
        if (result['objectives'][property] != true) {
            completed = false;
        }
    }
    result['completed'] = completed;
    return result;
};