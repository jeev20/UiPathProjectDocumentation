function DownloadSampleFromUiPathForum {
    # This function downloads, unzips files from UiPath forum given the url of the file.
    param (
        [string]$SourceUrl
    )
    # Lets download a sample project file and unzip 
    $WebRequest = iwr $SourceUrl   # Invoke-WebRequest to get headers 
    $WebRequest.Headers."Content-Disposition" -match -join ("\w+.", $SourceUrl.Split(".")[-1])
    $FileName = $Matches.0   # This gets us the filename from UiPath forum
    $ZipFile = -join ("C:\Users\", $env:UserName, "\Downloads\", $FileName)
    $UnzipLocation = -join ("C:\Users\", $env:UserName, "\Downloads\", $ZipFile.Split("\")[-1].ToString().Split(".")[0])
    $ExistsZipFile = Test-Path -Path $ZipFile   
    # Lets download only if the file is not found
    if ($ExistsZipFile -eq $false) {
        Invoke-WebRequest -Uri $SourceUrl -OutFile $ZipFile 
        Start-Sleep -Seconds 2
        Expand-Archive -Path $ZipFile -DestinationPath  $UnzipLocation -Force
    }
    else {
        Expand-Archive -Path $ZipFile -DestinationPath $UnzipLocation -Force
    }# if ends
}# function ends

# Calling the download function on the sample file
DownloadSampleFromUiPathForum  'https://forum.uipath.com/uploads/short-url/4j6bRIkvsRdRnsr7BhfcSHIwieF.zip'


# Find the current location
$CurrentDirectory = Get-Location |  select -expand Path
# Provide UiPath project path - Not dynamic for tutorial purposes

$ProjectPath = -join ("C:\Users\", $env:UserName, "\Downloads\TutorialRobustWorkflow\TutorialRobustWorkflow")


# Ensure the last folder level i.e., UiPath project name library name is used as the Output filename. 
$OutputFile = $CurrentDirectory + "\" + "ProjectDocumentation_" + $ProjectPath.Split("\")[-1].ToString() + ".html" 
# If output file exists, clear its content
$ExistsOutputFile = Test-Path -Path $OutputFile
if ($ExistsOutputFile -eq $true) {
    Clear-Content $OutputFile 
}

# Getting all .xaml files recursively in the $ProjectPath
$FilesFound = Get-ChildItem -Path $ProjectPath -Filter *.xaml -Recurse -File -Name  #-Exclude "RobustWorkflowTemplate.xaml" # Uncomment if using on REFramework

# Creating an empty array to save return objects
$ReturnObj = @()

# For each found file, extract the required values
ForEach ($File in $FilesFound ) {
    $FilePath = $ProjectPath + '\' + $File
    $XAMLData = New-Object xml
    $XAMLData.Load( $FilePath )  # Read the .xaml file

    #  The try and catch needs to be in place as a precaution for variables not so important for arguments and annotations
    try {
        $AnnotationText = $XAMLData.Activity.Sequence."Annotation.AnnotationText"
    }
    catch {}

    # Get variables, type and annotation
    # I would like to credit Siyang Wu for his wonderful approach used to get Variable details
    # https://marketplace.uipath.com/listings/get-all-variable-definitions/reviews
    $queue = New-Object System.Collections.Queue
    foreach ($node in $XAMLData.DocumentElement.ChildNodes) {
        $queue.Enqueue($node)
    } 
    $VariableNames = @()
    $VariableType = @()
    $VariableAnnotationText = @()
    $variableScope = @()
    while ($queue.count -gt 0) {
        $currentNode = $queue.Dequeue()
        if ($currentNode.Name.EndsWith('.Variables')) {
            if ($currentNode.ParentNode.DisplayName -eq $null) {
   
                $scopeName = $currentNode.ParentNode.'sap2010:WorkflowViewState.IdRef'
                #Write-Host $scopeName
            }else {
                $scopeName = $currentNode.ParentNode.DisplayName
            }# if DisplayName

            foreach ($node in $currentNode.ChildNodes) {
                if ($node.Default -eq $null) {
                }else { $queue.Enqueue($node) }
                $VariableNames += $node.Name
                $VariableType += $node.TypeArguments
                $VariableAnnotationText +=  $node.'Annotation.AnnotationText'
                $variableScope += $scopeName
            }
        }else {
            if ($currentNode.HasChildNodes) {
                foreach ($node in $currentNode.ChildNodes) {
                    $queue.Enqueue($node)
                } # End for each 
            } # End if HasChildnodes
        }# End if name ends with
    }# End while

    $Variable_Names = ''
    $Variable_Type = ''
    $VariableAnnotation_Text = ''
    $Variable_Scope = ''
    if ($VariableNames.Length -ne 0) {
        ForEach ($i in 0..($VariableNames.Count - 1)) {
            $VariableNamesTemp = $VariableNames[$i] 
            $VariableTypeTemp = $VariableType[$i]
            $VariableAnnotationTextTemp = $VariableAnnotationText[$i]
            $VariableScopeTemp = $variableScope[$i]

            $Variable_Names += "<li>" + $VariableNamesTemp + "`n" + "</li>"
            $Variable_Type += "<li>" + "$VariableTypeTemp `n" + "</li>"
            $Variable_Scope += "<li>" + "$VariableScopeTemp `n" + "</li>"
            if ($VariableAnnotationTextTemp.Length -eq 0) {
                $VariableAnnotation_Text += "<li>" + "None " + "</li>"
            }
            else { $VariableAnnotation_Text += "<li>" + "$VariableAnnotationTextTemp `n" + "</li>" }

        }
    }

    try {
        $ArgumentsNames = $XAMLData.Activity.Members.Property.Name
        $ArgumentsType = $XAMLData.Activity.Members.Property.Type
        $ArgumentsAnnotationText = $XAMLData.Activity.Members.Property."Annotation.AnnotationText"
    }
    catch {}
    # Arguments as a single string value with corresponding type
    $Arguments_Names = ''
    $Arguments_Type = ''
    $ArgumentsAnnotation_Text = ''
    if ($ArgumentsNames.Length -ne 0) {
        ForEach ($i in 0..($ArgumentsNames.Count - 1)) {
            try{
            $ArgumentsNamesTemp = $ArgumentsNames[$i] 
            $ArgumentsTypeTemp = $ArgumentsType[$i]
            $ArgumentsAnnotationTextTemp = $ArgumentsAnnotationText[$i]
            }catch{}
            
            $Arguments_Names += "<li>" + $ArgumentsNamesTemp + "`n" + "</li>"
            $Arguments_Type += "<li>" + "$ArgumentsTypeTemp `n" + "</li>"
            if ($ArgumentsAnnotationTextTemp.Length -eq 0) {
                $ArgumentsAnnotation_Text += "<li>"+"None "+ "</li>"
            }
            else { $ArgumentsAnnotation_Text += "<li>" + "$ArgumentsAnnotationTextTemp `n" + "</li>" }
    
        }
    }# If ends

    
    $Namespaces = $XAMLData.Activity.'TextExpression.NamespacesForImplementation'.Collection.String
    if($NameSpaces -eq $null){
        $Namespaces = $XAMLData.Activity.'TextExpression.NamespacesForImplementation'.List.String
    }
    $Namespace_Names = ''
    if ($Namespaces.Length -ne 0) {
        ForEach ($i in 0..($Namespaces.Count - 1)) {
            $NamespaceNamesTemp = $Namespaces[$i] 
            $Namespace_Names += "<li>" + $NamespaceNamesTemp + "`n" + "</li>"
        }
    }

    # $AssemblyReferences are not used, but leaving it for situations where it is needed 
    $AssemblyReferences = $XAMLData.Activity.'TextExpression.ReferencesForImplementation'.Collection.AssemblyReference
    if($AssemblyReferences -eq $null){
        $Namespaces = $XAMLData.Activity.'TextExpression.ReferencesForImplementation'.List.AssemblyReference
    }
    $AssemblyReferences_Names = ''
    if ($AssemblyReferences.Length -ne 0) {
        ForEach ($i in 0..($AssemblyReferences.Count - 1)) {
            $AssemblyReferencesNamesTemp = $AssemblyReferences[$i] 
            $AssemblyReferences_Names += "<li>" + $AssemblyReferencesNamesTemp + "`n" + "</li>"
        }
    }




    # Defining a custom PSObject 
    $obj = New-Object psobject -Property @{`
            "File"            = $File;
        "WorkflowAnnotation"  = $AnnotationText;
        "ArgumentNames"       = $Arguments_Names; 
        "ArgumentType"        = $Arguments_Type;
        "ArgumentsAnnotation" = $ArgumentsAnnotation_Text;
        "VariableNames"       = $Variable_Names; 
        "VariableType"        = $Variable_Type;
        "VariableAnnotation"  = $VariableAnnotation_Text;
        "VariableScope"       = $Variable_Scope;
        "Imports"           = $Namespace_Names;
        

    }
    # These headers will be returned
    $ReturnObj += $obj | select File, WorkflowAnnotation, VariableNames, VariableType, VariableAnnotation, VariableScope, ArgumentNames, ArgumentType, ArgumentsAnnotation,Imports
}# For loop ends


# We would want to make the output a little nicer to read with some CSS
$HtmlHead = '<style>
    body {
        background-color: azure;
        font-family:      "Calibri";
    }
    table {
        border-width:     1px;
        border-style:     solid;
        border-color:     black;
        border-collapse:  collapse;
        width:            100%;
    }
    th {
        border-width:     1px;
        padding:          5px;
        border-style:     solid;
        border-color:     black;
        background-color: #98C6F3;
    }
    td {
        border-width:     1px;
        padding:          5px;
        border-style:     solid;
        border-color:     black;
        background-color: White;
    }
    tr {
        text-align:       left;
    }
   td:hover {
          background-color: #ffff99;
        }
    tr:hover {
          color: #0000FF;
          font: bold Georgia, serif;
          scale: 1.05;
    }
    overflow-wrap: break-word;     /* Renamed property in CSS3 draft spec */
}
</style>'

# Converting and saving the PSObject as html and adding head to html output
$ReturnObj | ConvertTo-Html -Head $HtmlHead | Out-File $OutputFile

# We have to replace the generated data and replace list formating
$HTMLContent = Get-Content $OutputFile   # Reading content
$HTMLContent.Replace("&lt;li&gt;", "<li>").Replace("&lt;/li&gt;", "</li>") | Out-File $OutputFile

# Opening the HTML file in the browser
Start-Process $OutputFile
