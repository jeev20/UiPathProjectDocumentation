# Automate UiPath project documentation using PowerShell
A script which can document the name of each workflow, the function of each workflow, the names of the arguments used, their data type and corresponding annotations. Variables names, type and annotations can also be captured, but for this tutorial, I will not be including them. 

You can read a detailed walkthrough of this code in the UiPath Community Forum : https://forum.uipath.com/t/automate-uipath-project-documentation-using-powershell/383987

--------------------------------

### [Resulting output](https://jeev20.github.io/UiPathProjectDocumentation/)

--------------------------------------
### Scope for improvement
- [ ] To consider the sequential order of the invoked workflows from Main.xaml
- [ ] To read and document annotations in each of the sequences within a workflow 
- [ ] To apply 1 and 2 into REFramework, to create a document, which provides both the order and the annotations for the invoked workflows in Process.xaml
- [x] Support variables and programatically get scope of each variable

### **If you would like to contribute, please do and send me a pull request.** :thumbsup:

### Special mention
I would like to thank Siyang Wu for his brilliant approach to read the variable scope from UiPath Workflows. This repo has replicated his approach to retrieve variable information in PowerShell. 
His componenet is available at https://marketplace.uipath.com/listings/get-all-variable-definitions?utm_source=internal&utm_medium=related&utm_campaign=velocistar-globalvariables-activites 
