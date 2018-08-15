function New-ExcelDocument {
    param(

    )
    $Excel = New-Object -TypeName OfficeOpenXml.ExcelPackage
    return $Excel
}

function Save-ExcelDocument {
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)][Alias('Document', 'Excel', 'Package')] $ExcelDocument,
        [string] $FilePath,
        [alias('Show', 'Open')][switch] $OpenWorkBook
    )
    try {
        Write-Verbose "Save-ExcelDocument - Saving workbook $FilePath"
        $ExcelDocument.SaveAs($FilePath)
    } catch {
        $ErrorMessage = $_.Exception.Message
        if ($ErrorMessage -like "*The process cannot access the file*because it is being used by another process.*" -or
            $ErrorMessage -like "*Error saving file*") {
            $FilePath = "$($([System.IO.Path]::GetTempFileName()).Split('.')[0]).xlsx"
            Write-Warning "Save-ExcelDocument - Couldn't save file as it was in use. Trying different name $FilePath"
            $ExcelDocument.File = $FilePath
            Save-ExcelDocument -ExcelDocument $ExcelDocument -FilePath $FilePath -OpenWorkBook:$OpenWorkBook
        } else {
            Write-Warning $ErrorMessage
        }
    }

    if ($OpenWorkBook) { Invoke-Item -Path $FilePath }
}