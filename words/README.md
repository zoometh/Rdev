# Processes for my Word files
> Sites.docx, Cultures.docx, Analyses statistiques.docx, Environnement.docx


## Replace hyperlinks

Replace "C:\Users\TH282424\AppData\Roaming\Microsoft\Word\" by "" (empty path)

```vb
Sub **ReplaceHL**()
    Dim HL As Hyperlink
    Dim target As String
    Dim repl As String

    target = "C:\Users\TH282424\AppData\Roaming\Microsoft\Word\"
    repl = ""

    ' Loop through each hyperlink
    For Each HL In ActiveDocument.Hyperlinks
        With HL
            ' Ensure error handling to prevent runtime errors
            On Error Resume Next
            
            ' Only proceed if Address is not empty or missing
            If Len(.Address) > 0 Then
                ' Ensure InStr is properly checked for a match
                If InStr(1, LCase(.Address), LCase(target), vbTextCompare) > 0 Then
                    .Address = Replace(.Address, target, repl)
                End If
            End If

            ' Reset error handling
            On Error GoTo 0
        End With
    Next
End Sub
```
