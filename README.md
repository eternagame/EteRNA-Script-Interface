EteRNA-Script-Interface
=======================

  EteRNA script interface help users make their own script solving puzzles or scoring lab puzzles in EteRNA.

And this repository shows you how script interface evaluates and test user's code.

You can be a member of contributors if you want. Please contact us.



- How to install EteRNA script interface on my own machine?

  Just check out this repository on your machine. Open a terminal and execute.
  
    git clone https://github.com/EteRNAgame/EteRNA-Script-Interface.git


- How to use EteRNA script interface?

  Simply open main.html on your browser. You can test whole script interface on local environment.



- How to add my own libraries into script interface?

  Just follow these steps.
  
  1. Make sure your own library follows our library convention. 
  
    - EteRNA script interface conventions

       - Library's filename and class should start with 'Lib'.(ex 'LibKws4679.js', 'LibKws4679')
  
       - Modularization your class like 'library/LibKws4679.js' due to stable deploy on production site.
     
         (Don't be afraid. Your class will be deployed after enough test.)
     
  
  2. Add ' <script type="text/javascript" src="library/your-file-name.js"></script> ' into 'main.html'
    

  3. Now you can use your class in script interface. 



- How does it work?

  1. 'server_resources/jscripts/builder-script.js' creates logical action of script interface.
  
      ( Compiled from 'server_resources/coffee/builder-script.coffee' )
  
  2. 'server_resources/jscripts/script.js' creates UI of script interface.
  
      ( Compiled from 'server_resources/html/script.html )
  
  3. 'script-connector.js' initialize script interface.
  
  It is a little bit difficult to understand process of interface by studying only javascript codes since 
  
  real interface runs on Node.js and coffeescript environment. Javascript files in 'server_resources' 
  
  folder are coffeescript generated files so you'd better study coffeescript file in 'coffees' folder
  
  to understand how it works.
  
  
  
  
