# Automate UiPath project documentation using PowerShell
A script which can document the name of each workflow, the function of each workflow, the names of the arguments used, their data type and corresponding annotations. 


### Problem Statement
It is difficult to get an overview of projects after the development phase. Solution designers and reviewers can benefit from a script, which can easily provide an overview of the workflows developed in the project. 

### Solution 
This script iterates through the project folder. For each workflow found, it extracts important design details, such as name of the workflow, variables, arguments and imports used. The output HTML is save in a human readable format. 

### Usage 1 - Using the sample project provided
* Clone the github repository
* Navigate to the cloned repository
* Run the DocumentationUiPathSampleProject.ps1 file in PowerShell
* The output HTML file will be saved in the cloned repository location

### Usage 2 - Using one of your projects
* Clone the github repository
* Navigate to the cloned repository
* Open the DocumentationUiPathSampleProject.ps1 file in any preferred IDE
* Comment out the line which calls the function DownloadSampleFromUiPathForum
* Edit or Replace the $ProjectPath variable with the location of your project
* Run the DocumentationUiPathSampleProject.ps1 file in PowerShell
* The output HTML file will be saved in the cloned repository location


### Features

* Read the workflow files in the project recursively and provide filtering options to limit certain files or folders
* Get name of the workflow and the annotation describing what the workflow does
* Get workflow variable details --> variable names, variable scope, variable annotations and variable types
* Get workflow argument details --> argument names,  argument annotations and argument direction and types
* Get imports and/or assembly references used in the workflow
* Save the output to an HTML file

You can read a detailed walkthrough of this code in the [UiPath Community Forum - Tutorials](https://forum.uipath.com/t/automate-uipath-project-documentation-using-powershell/383987).

--------------------------------

### [Resulting output](https://jeev20.github.io/UiPathProjectDocumentation/)

--------------------------------------
### Scope for improvement
- [ ] To consider the sequential order of the invoked workflows from Main.xaml
- [ ] To read and document annotations in each of the sequences within a workflow 
- [ ] To apply 1 and 2 into REFramework, to create a document, which provides both the order and the annotations for the invoked workflows in Process.xaml
- [x] Support variables and programatically get scope of each variable



### Special mentions
* I would like to thank Siyang Wu for his brilliant approach to read the variable scope from UiPath Workflows. This repo has replicated his approach to retrieve variable information in PowerShell. His componenet is [available at](https://marketplace.uipath.com/listings/get-all-variable-definitions?utm_source=internal&utm_medium=related&utm_campaign=velocistar-globalvariables-activites)
* Thanks to my employer HEMIT for their support and encouragement.  

### **If you would like to contribute, please do and send me a pull request.** :thumbsup:
