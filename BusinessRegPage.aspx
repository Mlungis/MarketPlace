<%@ Page Language="C#" Async="true" CodeBehind="BusinessRegPage.aspx.cs" Inherits="MarketPlace.BusinessRegPage" %>


<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Register Business | NWU Market Place</title>
    <style>
        :root {
            --primary: #4B306A;
            --accent: #007C91;
            --bg: #f5f5f5;
            --text: #333;
        }

        body, html {
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--bg);
        }

        .container {
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 40px 20px;
        }

        .form-box {
            background-color: #fff;
            border-radius: 16px;
            padding: 40px 30px;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
            max-width: 550px;
            width: 100%;
        }

        .form-box h2 {
            text-align: center;
            color: var(--primary);
            margin-bottom: 30px;
            font-size: 28px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            font-weight: 600;
            color: var(--text);
            margin-bottom: 8px;
        }

        .form-group input, .form-group select {
            width: 100%;
            padding: 12px;
            border: 1px solid #ccc;
            border-radius: 10px;
            font-size: 14px;
        }

        .form-group input[type="file"] {
            padding: 8px;
        }

        .submit-btn {
            width: 100%;
            background: linear-gradient(to right, var(--primary), var(--accent));
            color: white;
            padding: 14px;
            font-size: 16px;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            transition: background 0.3s ease;
        }

        .submit-btn:hover {
            background: linear-gradient(to right, #372450, #005c6e);
        }

        @media (max-width: 768px) {
            .form-box {
                padding: 30px 20px;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server" enctype="multipart/form-data">
        <div class="container">
            <div class="form-box">
                <h2>Register Your Business</h2>

                <div class="form-group">
                    <label for="txtBusinessName">Business Name</label>
                    <asp:TextBox ID="txtBusinessName" runat="server" CssClass="form-control" placeholder="Enter your business name" />
                </div>

                <div class="form-group">
                    <label for="ddlBusinessType">Business Type</label>
                    <asp:DropDownList ID="ddlBusinessType" runat="server" CssClass="form-control">
                        <asp:ListItem Text="Select a type" Value="" />
                        <asp:ListItem Text="Clothing" Value="Clothing" />
                        <asp:ListItem Text="Food" Value="Food" />
                        <asp:ListItem Text="Technology" Value="Technology" />
                        <asp:ListItem Text="Services" Value="Services" />
                        <asp:ListItem Text="Other" Value="Other" />
                    </asp:DropDownList>
                </div>

                <div class="form-group">
                    <label for="fileLogo">Upload Business Logo</label>
                    <asp:FileUpload ID="fileLogo" runat="server" CssClass="form-control" />
                </div>

                <asp:Button ID="btnRegisterBusiness" runat="server" Text="Submit Business" CssClass="submit-btn" OnClick="btnRegisterBusiness_Click" />
                 <asp:Label ID="lblMessage" runat="server" Text="Label"></asp:Label>
            </div>
        </div>
    </form>
</body>
</html>
