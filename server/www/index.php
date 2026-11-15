<!DOCTYPE html>
<html>
  <head>
    <title> Demo </title>
    <script src="https://unpkg.com/jspsych@7.0.0"></script>
    <script src="https://unpkg.com/@jspsych/plugin-html-button-response@1.0.0"></script>
    <script src="https://unpkg.com/@jspsych/plugin-survey-likert@1.0.0"></script>
    <script src="https://unpkg.com/@jspsych/plugin-instructions@1.0.0"></script>
    <script src="https://unpkg.com/@jspsych/plugin-survey-text@1.0.0"></script>
    <script src="https://unpkg.com/@jspsych/plugin-survey-multi-choice@1.0.0"></script>
    <style>
      .jspsych-content {
	  width: 760px;
	  max-width: 92vw;
	  font-size: 22px;
	  line-height: 1.6;
      }

      .jspsych-content .jspsych-survey-likert-statement {
	  font-size: 24px;
	  line-height: 1.6;
      }
      .jspsych-content .jspsych-survey-likert-opts {
	  width: 100%;
	  box-sizing: border-box;
	  font-size: 20px;
      }
      .jspsych-content .jspsych-survey-likert-opts label {
	  font-size: 20px;
	  line-height: 1.4;
	  overflow-wrap: break-word;
      }
      .jspsych-content .jspsych-btn {
	  font-size: 20px;
	  padding: 10px 20px;
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
