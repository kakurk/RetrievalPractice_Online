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

    function saveData(name, data){
      var xhr = new XMLHttpRequest();
      xhr.open('POST', 'write_data.php'); // 'write_data.php' is the path to the php file described above.
      xhr.setRequestHeader('Content-Type', 'application/json');
      xhr.send(JSON.stringify({filename: name, filedata: data}));
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
