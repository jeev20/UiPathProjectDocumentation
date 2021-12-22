function DownloadSampleFromUiPathForum{
    # This function downloads, unzips files from UiPath forum given the url of the file.
    param (
        [string]$SourceUrl
    )
# Lets download a sample project file and unzip 
$WebRequest = iwr $SourceUrl   # Invoke-WebRequest to get headers 
$WebRequest.Headers."Content-Disposition" -match -join("\w+.",$SourceUrl.Split(".")[-1])
$FileName = $Matches.0   # This gets us the filename from UiPath forum
$ZipFile = -join("C:\Users\", $env:UserName, "\Downloads\", $FileName)
$ExistsZipFile = Test-Path -Path $ZipFile   
# Lets download only if the final is not found
if($ExistsZipFile -eq $false){
Invoke-WebRequest -Uri $SourceUrl -OutFile $ZipFile 
Expand-Archive $ZipFile
}# if ends
}# function ends

# Calling the download function on the sample file
DownloadSampleFromUiPathForum  'https://forum.uipath.com/uploads/short-url/4j6bRIkvsRdRnsr7BhfcSHIwieF.zip'

# Find the current location
$CurrentDirectory = Get-Location |  select -expand Path
# Provide UiPath project path - Not dynamic for tutorial purposes
$ProjectPath = -join("C:\Users\", $env:UserName, "\Downloads\TutorialRobustWorkflow\TutorialRobustWorkflow")

# Ensure the last folder level i.e., UiPath project name library name is used as the Output filename. 
$OutputFile = $CurrentDirectory+"\"+$ProjectPath.Split("\")[-1].ToString()+".html" 
# If output file exists, clear its content
$ExistsOutputFile = Test-Path -Path $OutputFile
if($ExistsOutputFile -eq $true){
Clear-Content $OutputFile 
}

# Getting all .xaml files recursively in the $ProjectPath
$FilesFound = Get-ChildItem -Path $ProjectPath -Filter *.xaml -Recurse -File -Name # -Exclude "Initial.xaml" # Uncomment if using on REFramework

# Creating an empty array to save return objects
$ReturnObj = @()

# For each found file, extract the required values
ForEach($File in $FilesFound ){
$FilePath = $ProjectPath + '\' + $File
[xml]$XAMLData = Get-Content $FilePath -Encoding UTF8  # Read the .xaml file

#  The try and catch needs to be in place as a precaution for variables not so important for arguments and annotations
try{$AnnotationText = $XAMLData.Activity.Sequence."Annotation.AnnotationText"
}catch{}

try{
$ArgumentsNames = $XAMLData.Activity.Members.Property.Name
$ArgumentsType = $XAMLData.Activity.Members.Property.Type
$ArgumentsAnnotationText = $XAMLData.Activity.Members.Property."Annotation.AnnotationText"
}catch{}
# Arguments as a single string value with corresponding type
$Arguments_Names = ''
$Arguments_Type = ''
$ArgumentsAnnotation_Text = ''
if($ArgumentsNames.Length -ne 0){
ForEach($i in 0..($ArgumentsNames.Count-1)){
    $ArgumentsNamesTemp = $ArgumentsNames[$i] 
    $ArgumentsTypeTemp = $ArgumentsType[$i]
    $ArgumentsAnnotationTextTemp = $ArgumentsAnnotationText[$i]

    $Arguments_Names += "<li>"+ $ArgumentsNamesTemp + "`n" + "</li>"
    $Arguments_Type += "<li>"+"$ArgumentsTypeTemp `n" + "</li>"
    if($ArgumentsAnnotationTextTemp.Length -eq 0){
        $ArgumentsAnnotation_Text += "None "
    }else{$ArgumentsAnnotation_Text += "<li>"+"$ArgumentsAnnotationTextTemp `n"+"</li>"}
    
}
}# If ends

# Defining a custom PSObject 
$obj = New-Object psobject -Property @{`
    "File" = $File;
    "WorkflowAnnotation" = $AnnotationText;
    "ArgumentNames" = $Arguments_Names; 
    "ArgumentType" = $Arguments_Type;
    "ArgumentsAnnotation" = $ArgumentsAnnotation_Text;
    }
# These headers will be returned
$ReturnObj += $obj | select File,WorkflowAnnotation,ArgumentNames,ArgumentType,ArgumentsAnnotation
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
$ReturnObj | ConvertTo-Html -Head $HtmlHead| Out-File $OutputFile

# We have to replace the generated data and replace list formating
$HTMLContent = Get-Content $OutputFile   # Reading content
$HTMLContent.Replace("&lt;li&gt;","<li>").Replace("&lt;/li&gt;", "</li>") | Out-File $OutputFile

# Opening the HTML file in the browser
Start-Process $OutputFile
