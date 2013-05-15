EteRNA-Script-Interface
=======================

  EteRNA script interface help users make their own script solving puzzles or scoring lab puzzles in EteRNA. 
  
  And this repository shows you how script interface evaluates and test user's code.
  
  You can be a member of contributors if you want. Please contact us.


  

Installation
-------

  Just check out this repository on your machine.
  
        git clone https://github.com/EteRNAgame/EteRNA-Script-Interface.git


Usage
-----

  Simply open <b>main.html</b> on your browser. You can test whole script interface on local environment.



Add library
--------------

  - Make sure your own library follows our library conventions. 
  
        EteRNA script interface conventions

           - Library's filename and class should start with 'Lib'.(ex 'LibKws4679.js', 'LibKws4679')
  
           - Modularization your class like 'library/LibKws4679.js' due to stable deploy on production site.
     
              (Don't be afraid. Your class will be deployed after enough test.)
     
  
  - Add into main.html

    ```javascript
    <script type="text/javascript" src="library/your-file-name.js"></script>
    ```
    

  - Now you can use your class in script interface. 



How does it work?
-----------------

  1. server_resources/jscripts/builder-script.js creates logical action of script interface.
  
      <b>Note</b>: Compiled from server_resources/coffee/builder-script.coffee
  
  2. server_resources/jscripts/script.js creates UI of script interface.
  
      <b>Note</b>: Compiled from 'server_resources/html/script.html 
  
  3. script-connector.js initialize script interface.

  
  
