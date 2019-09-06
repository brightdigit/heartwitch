 "use strict";
  var recordName = null;
  var database = null;
  var container = null;
  var hexlist = '0123456789abcdef';
  var b64list = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  function getUrlVars() {
      var vars = {};
      var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
          vars[key] = value;
      });
      return vars;
  }

  // GUID string with four dashes is always MSB first,
  // but base-64 GUID's vary by target-system endian-ness.
  // Little-endian systems are far more common.  Set le==true
  // when target system is little-endian (e.g., x86 machine).
  //
  function guid_to_base64(g, le) {
      var s = g.replace(/[^0-9a-f]/ig, '').toLowerCase();
      if (s.length != 32) return '';

      if (le) s = s.slice(6, 8) + s.slice(4, 6) + s.slice(2, 4) + s.slice(0, 2) +
        s.slice(10, 12) + s.slice(8, 10) +
        s.slice(14, 16) + s.slice(12, 14) +
        s.slice(16);
      s += '0';

      var a, p, q;
      var r = '';
      var i = 0;
      while (i < 33) {
        a = (hexlist.indexOf(s.charAt(i++)) << 8) |
          (hexlist.indexOf(s.charAt(i++)) << 4) |
          (hexlist.indexOf(s.charAt(i++)));

        p = a >> 6;
        q = a & 63;

        r += b64list.charAt(p) + b64list.charAt(q);
      }
      r += '==';

      return r;
    } // guid_to_base64()
  function deleteRecords (responseRecords) {
    console.log(responseRecords);
    if (responseRecords.length > 0){
    var recordNames = responseRecords.map( x => x.recordName );
    console.log("deleting", recordNames)
    database.deleteRecords(recordNames).then(onDeleteRecords)
    } else {
      onDeleteRecords()
    }
  }
  function onDeleteRecords (response) {
    if(response && response.hasErrors) {

      // Handle the errors in your app.
      throw response.errors[0];

    } else {
      return beginNewRecord(response);
    }
  }
  function beginNewRecord () {
    var xhr = new XMLHttpRequest();
    
    xhr.open('POST', 'workouts');
    xhr.responseType = "json"
    xhr.onload = function() {
      if (xhr.status === 200) {

        var record = {

          recordType: "Workout"

        };
        var hostName = getUrlVars()["hostName"] || window.location.hostname;
        var fields = { identifier : guid_to_base64(xhr.response.id), hostName : hostName }
        record.fields = Object.keys(fields).reduce(function(obj,key) {
          obj[key] = { value: fields[key] };
          return obj;
        },{});
        //alert(window.location.protocol + "//" + window.location.hostname +  ":" + window.location.port + "/run/" + xhr.response.id)
        //alert("ws://" + window.location.hostname +  ":" + window.location.port + "/listen/" + xhr.response.id)
        database.saveRecords(record).then(
                                          function (response) {
                                          recordName = response.records[0].recordName
                                          console.log(recordName)
                                          }
                                          )
        document.getElementById("id").innerText = xhr.response.id
        var ws = new WebSocket("wss://" + hostName  + "/workouts/" + xhr.response.id)
        ws.onopen = function() {
          
          // Web Socket is connected, send data using send()
          // ws.send("Message to send");
          
          //alert("Message is sent...");
          document.getElementById("heartRate").innerText = "..."
          console.log(ws.binaryType)
        };
        
        ws.onmessage = function (evt) {
          var received_msg = evt.data;
          var workout = JSON.parse(received_msg)
          document.getElementById("heartRate").innerText =workout.heartRate
          //alert("Message is received...");
        };
        
        ws.onclose = function() {
          
          // websocket is closed.
          //alert("Connection is closed...");
          document.getElementById("id").innerText = "Closed"
          if (recordName) {
            database.deleteRecords(recordName)
          }
        };
      }
      else if (xhr.status !== 200) {
        //alert('Request failed.  Returned status of ' + xhr.status);
        document.getElementById("id").innerText = "FAILED"
      }
    };
    xhr.send();
  }
  function onLogin () {
    var query = {
      recordType: "Workout"
    };
    database.performQuery(query).then(
                                      function (response) {
                                      if (response.hasErrors) {
                                      throw response.errors[0];
                                      
                                      } else {
                                      return deleteRecords(response.records)
                                      }
                                      }
                                      );
    container.whenUserSignsOut()
      .then(onUnauthorized);

  }
  
  function onUnauthorized (error) {
    console.log(error)
    container
    .whenUserSignsIn()
      .then(
            onLogin
       )
    .catch(onUnauthorized);
  }
 window.addEventListener('load', function() {
    CloudKit.configure({
        containers: [{
            containerIdentifier: 'iCloud.com.brightdigit.Heartwitch',
            apiTokenAuth: {
                apiToken: apiToken,
                     persist: true, // Sets a cookie.

                     signInButton: {
                       id: 'apple-sign-in-button',
                       theme: 'black' // Other options: 'white', 'white-with-outline'.
                     },

                     signOutButton: {
                       id: 'apple-sign-out-button',
                       theme: 'black'
                     }
            },
                     
            environment: 'development'
        }]
    });
    container = CloudKit.getDefaultContainer();
    container.setUpAuth()
   .then(function(userIdentity) {

     // Either a sign-in or a sign-out button was added to the DOM.

     // userIdentity is the signed-in user or null.
     if(userIdentity) {
    database = container.privateCloudDatabase;
       console.log(userIdentity);
         onLogin(userIdentity);
       //gotoAuthenticatedState(userIdentity);
     } else {
         onUnauthorized();
       //.catch(gotoUnauthenticatedState);
     }
   });
  });