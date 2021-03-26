/**
 * jspsych-canvas-mouseclick-response
 * Chris Jungerius (modified from Josh de Leeuw)
 *
 * a jsPsych plugin for displaying a canvas stimulus and getting a keyboard response
 *
 * documentation: docs.jspsych.org
 *
 **/


jsPsych.plugins["canvas-mouseclick-response"] = (function () {

  var plugin = {};

  plugin.info = {
    name: 'canvas-mouseclick-response',
    description: '',
    parameters: {
      stimulus: {
        type: jsPsych.plugins.parameterType.FUNCTION,
        pretty_name: 'Stimulus',
        default: undefined,
        description: 'The drawing function to apply to the canvas. Should take the canvas object as argument.'
      },
      choices: {
        type: jsPsych.plugins.parameterType.KEY,
        array: true,
        pretty_name: 'Choices',
        default: jsPsych.ALL_KEYS,
        description: 'The keys the subject is allowed to press to respond to the stimulus.'
      },
      prompt: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'Prompt',
        default: null,
        description: 'Any content here will be displayed below the stimulus.'
      },
      stimulus_duration: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Stimulus duration',
        default: null,
        description: 'How long to hide the stimulus.'
      },
      trial_duration: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Trial duration',
        default: null,
        description: 'How long to show trial before it ends.'
      },
      response_ends_trial: {
        type: jsPsych.plugins.parameterType.BOOL,
        pretty_name: 'Response ends trial',
        default: true,
        description: 'If true, trial will end when subject makes a response.'
      },
      canvas_size: {
        type: jsPsych.plugins.parameterType.INT,
        array: true,
        pretty_name: 'Canvas size',
        default: [500, 500],
        description: 'Array containing the height (first value) and width (second value) of the canvas element.'
      },
      images: {
        type: jsPsych.plugins.parameterType.STRING,
        array: true,
        pretty_name: 'Images',
        default: null,
        description: 'Array containing the paths to the object and scene images.'
      },

    }
  }

  plugin.trial = function (display_element, trial) {

    var new_html = '<div id="jspsych-canvas-keyboard-response-stimulus">' + '<canvas id="jspsych-canvas-stimulus" height="' + trial.canvas_size[0] + '" width="' + trial.canvas_size[1] + '"></canvas>' + '</div>';

    // add prompt
    if (trial.prompt !== null) {
      new_html += trial.prompt;
    }

    // load images
    let object = new Image();
    let scene = new Image();
    object.src = trial.images[0];
    scene.src = trial.images[1];
    object.width = 100;
    object.height = 100;

    // draw
    display_element.innerHTML = new_html;
    let c = document.getElementById("jspsych-canvas-stimulus");

    var ctx = c.getContext('2d');

    // draw scene
    var centerx = canvasW/2 - sceneW/2;
    var centery = canvasH/2 - sceneH/2;
    ctx.drawImage(scene, centerx, centery, sceneW, sceneH);

    // draw guide circle
    ctx.strokeStyle = 'white'
    ctx.arc(canvasW/2, canvasH/2, guide_cir_r, 0, 2 * Math.PI);
    ctx.lineWidth = circleThick;
    ctx.stroke();

    // draw object
    var centerx = canvasW/2 - objectW/2;
    var centery = canvasH/2 - objectH/2;
    var xPos = jsPsych.timelineVariable('xPos');
    var yPos = jsPsych.timelineVariable('yPos');
    ctx.drawImage(object, centerx+xPos, centery+yPos, objectW, objectH);

    c.addEventListener('click', e => {

      x = e.offsetX;
      y = e.offsetY;

      let cx = ctx.canvas.width/2;
      let cy = ctx.canvas.height/2;

      let imageCenter_x = cx + xPos;
      let imageCenter_y = cy + yPos;

      // if the click is within the object
      if(x > imageCenter_x - objectH/2 && x < imageCenter_x + objectW/2 && y > imageCenter_y - objectH/2 && y < imageCenter_y + objectH/2) {

        // clear canvas
        ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
        ctx.beginPath();

        // draw scene
        var centerx = canvasW/2 - sceneW/2;
        var centery = canvasH/2 - sceneH/2;
        ctx.drawImage(scene, centerx, centery, sceneW, sceneH);

        // draw guide circle
        ctx.strokeStyle = 'white'
        ctx.arc(canvasW/2, canvasH/2, guide_cir_r, 0, 2 * Math.PI);
        ctx.lineWidth = circleThick;
        ctx.stroke();

        // draw object
        var centerx = canvasW/2 - objectW/2;
        var centery = canvasH/2 - objectH/2;
        ctx.drawImage(object, centerx+xPos, centery+yPos, objectW, objectH);

        // draw a box around the image
        ctx.strokeRect(centerx+xPos, centery+yPos, objectW, objectH);

        // record the x,y location (px)
        mouseX = x;
        mouseY = y;

      }
    });

    // store response
    var response = {
      rt: null,
      key: null
    };

    // function to end trial when it is time
    var end_trial = function () {

      // kill any remaining setTimeout handlers
      jsPsych.pluginAPI.clearAllTimeouts();

      // kill keyboard listeners
      if (typeof keyboardListener !== 'undefined') {
        jsPsych.pluginAPI.cancelKeyboardResponse(keyboardListener);
      }

      // gather the data to store for the trial
      var trial_data = {
        rt: response.rt,
        response: response.key
      };

      // clear the display
      display_element.innerHTML = '';

      // move on to the next trial
      jsPsych.finishTrial(trial_data);
    };

    // function to handle responses by the subject
    var after_response = function (info) {

      // after a valid response, the stimulus will have the CSS class 'responded'
      // which can be used to provide visual feedback that a response was recorded
      display_element.querySelector('#jspsych-canvas-keyboard-response-stimulus').className += ' responded';

      // only record the first response
      if (response.key == null) {
        response = info;
      }

      if (trial.response_ends_trial) {
        end_trial();
      }
    };

    // start the response listener
    if (trial.choices != jsPsych.NO_KEYS) {
      var keyboardListener = jsPsych.pluginAPI.getKeyboardResponse({
        callback_function: after_response,
        valid_responses: trial.choices,
        rt_method: 'performance',
        persist: false,
        allow_held_key: false
      });
    }

    // hide stimulus if stimulus_duration is set
    if (trial.stimulus_duration !== null) {
      jsPsych.pluginAPI.setTimeout(function () {
        display_element.querySelector('#jspsych-canvas-keyboard-response-stimulus').style.visibility = 'hidden';
      }, trial.stimulus_duration);
    }

    // end trial if trial_duration is set
    if (trial.trial_duration !== null) {
      jsPsych.pluginAPI.setTimeout(function () {
        end_trial();
      }, trial.trial_duration);
    }

  };

  return plugin;
})();
