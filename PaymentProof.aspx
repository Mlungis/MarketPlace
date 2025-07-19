<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PaymentProof.aspx.cs" Inherits="MarketPlace.PaymentProof" Async="true" %>


<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Submit Proof of Payment | NWU Market Place</title>
    <style>
        :root {
            --primary: #4B306A;
            --accent: #007C91;
            --light-bg: #f5f5f5;
            --text: #333;
        }

        body, html {
            margin: 0; padding: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--light-bg);
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .form-container {
            background: white;
            padding: 40px 35px;
            border-radius: 16px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.1);
            max-width: 400px;
            width: 100%;
            text-align: center;
        }

        h2 {
            color: var(--primary);
            margin-bottom: 20px;
            font-size: 28px;
        }

        label {
            display: block;
            text-align: left;
            font-weight: 600;
            margin-bottom: 8px;
            color: var(--text);
            font-size: 14px;
        }

        input[type="email"],
        input[type="file"] {
            width: 100%;
            padding: 12px;
            margin-bottom: 20px;
            border-radius: 10px;
            border: 1px solid #ccc;
            font-size: 14px;
            box-sizing: border-box;
        }

        input[type="email"]:focus,
        input[type="file"]:focus {
            outline: none;
            border-color: var(--accent);
            box-shadow: 0 0 5px var(--accent);
        }

        .submit-btn {
            width: 100%;
            background: linear-gradient(to right, var(--primary), var(--accent));
            border: none;
            color: white;
            padding: 14px;
            font-size: 16px;
            font-weight: 700;
            border-radius: 12px;
            cursor: pointer;
            transition: background 0.3s ease;
        }

        .submit-btn:hover {
            background: linear-gradient(to right, #372450, #005c6e);
        }

        .thank-you-message {
            font-size: 18px;
            color: var(--primary);
            margin-top: 25px;
        }

    </style>
</head>
<body>
    <form id="form1" runat="server" enctype="multipart/form-data">
        <div class="form-container">
            <h2>Submit Proof of Payment</h2>

            <asp:Panel ID="pnlForm" runat="server" Visible="true">
                <label for="txtEmail">Email Used to Sign Up</label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="email-input" TextMode="Email" placeholder="Enter your email" Required="true" />

                <label for="fileUpload">Upload Payment Screenshot</label>
                <asp:FileUpload ID="fileUpload" runat="server" />

                <asp:Button ID="btnSubmit" runat="server" Text="Submit" CssClass="submit-btn" OnClick="btnSubmit_Click" />
                <asp:Label ID="lblMessage" runat="server" ForeColor="Red" />
            </asp:Panel>

            <asp:Panel ID="pnlThankYou" runat="server" Visible="false">
                <div class="thank-you-message">
                    <p>Thank you for submitting your proof of payment.</p>
                    <p>Our team will contact you shortly to confirm your plan activation.</p>
                </div>
            </asp:Panel>
        </div>
    </form>
</body>
</html>
