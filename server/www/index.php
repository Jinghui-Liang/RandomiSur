     <!DOCTYPE html>
      <html>
        <head>
          <title> Behaviour Survey </title>
          <script src="https://unpkg.com/jspsych@7.0.0"></script>
          <script src="https://unpkg.com/@jspsych/plugin-html-button-response@1.0.0"></script>
          <script src="https://unpkg.com/@jspsych/plugin-survey-likert@1.0.0"></script>
          <script src="https://unpkg.com/@jspsych/plugin-instructions@1.0.0"></script>
          <script src="https://unpkg.com/@jspsych/plugin-survey-text@1.0.0"></script>
          <script src="https://unpkg.com/@jspsych/plugin-survey-multi-choice@1.0.0"></script>
          <style>
            .jspsych-btn {
            margin-bottom: 10px;
            }
          </style>
          <link
            rel="stylesheet"
            href="https://unpkg.com/jspsych@7.0.0/css/jspsych.css"
            />
          <link rel="shortcut icon" href="#"/>  <!-- remove it in production -->
        </head>
        <body></body>
        <!-- use module.js to connect js scripts. -->
        <script type = "module" src= "runSurvey.js"> </script>
      </html>
