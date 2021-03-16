// extends 'from' object with members from 'to'. If 'to' is null, a deep clone of 'from' is returned
function extend(from, to)
{
    if (from == null || typeof from != "object") return from;
    if (from.constructor != Object && from.constructor != Array) return from;
    if (from.constructor == Date || from.constructor == RegExp || from.constructor == Function ||
        from.constructor == String || from.constructor == Number || from.constructor == Boolean)
        return new from.constructor(from);

    to = to || new from.constructor();

    for (var name in from)
    {
        to[name] = typeof to[name] == "undefined" ? extend(from[name], null) : to[name];
    }

    return to;
}

// jsPsych savedata function
function saveData(filename, filedata){
   $.ajax({
      type:'post',
      cache: false,
      url: 'save_data.php', // this is the path to the above PHP script
      data: {filename: filename, filedata: filedata},
      success: function(data) {
        if (data == "ok") {
          console.log("Success!")
        }
      }
   });
 }

 // Function for grabbing variables through the HTML file
 function getQueryVariable(variable)  {
     var query = window.location.search.substring(1);
     var vars = query.split("&amp;");
     for (var i=0;i<vars.length;i++) {
       var pair = vars[i].split("=");
       if (pair[0] == variable){return pair[1];}
     }
     alert('Query variable ' + variable + ' not found');
   }
