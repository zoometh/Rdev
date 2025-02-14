Sub ProcessWordFiles()
    Dim wdApp As Object
    Dim wdDoc As Object
    Dim FolderPath As String
    Dim FileName As String
    Dim target As String
    Dim repl As String

    ' Set the target folder
    FolderPath = "C:\Users\Thomas Huet\Desktop\Documentation archéologique liée à la thèse\"  ' <-- Change this to your actual folder path

    ' Hyperlink replacement parameters
    target = "C:\Users\TH282424\AppData\Roaming\Microsoft\Word\"
    repl = ""

    ' Create Word Application object
    On Error Resume Next
    Set wdApp = GetObject(, "Word.Application") ' Try to get running instance
    If wdApp Is Nothing Then
        Set wdApp = CreateObject("Word.Application") ' If not running, create new
    End If
    On Error GoTo 0

    wdApp.Visible = False ' Run Word in the background

    ' Loop through all Word documents in the folder
    FileName = Dir(FolderPath & "*.docx") ' Get first Word file
    While FileName <> ""
        Set wdDoc = wdApp.Documents.Open(FolderPath & FileName, ReadOnly:=False)
        
        ' Process hyperlinks in the document
        Dim HL As Hyperlink
        For Each HL In wdDoc.Hyperlinks
            With HL
                If Len(.Address) > 0 Then
                    If InStr(1, LCase(.Address), LCase(target), vbTextCompare) > 0 Then
                        .Address = Replace(.Address, target, repl)
                    End If
                End If
            End With
        Next

        ' Save and close document
        wdDoc.Save
        wdDoc.Close False
        
        ' Get next file
        FileName = Dir
    Wend

    ' Quit Word if it was not originally running
    wdApp.Quit

    ' Cleanup
    Set wdDoc = Nothing
    Set wdApp = Nothing
End Sub
