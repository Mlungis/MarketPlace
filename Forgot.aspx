<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Forgot.aspx.cs" Inherits="MarketPlace.Forgot" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Forgot Password | NWU Market Place</title>
    <style>
        :root {
            --primary: #4B306A;
            --accent: #007C91;
            --light-bg: #f5f5f5;
            --form-bg: #ffffff;
            --text: #333;
        }

        body, html {
            margin: 0;
            padding: 0;
            height: 100%;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--light-bg);
        }

        .container {
            display: flex;
            height: 100vh;
        }

        .left-section {
            flex: 1.2;
            background: linear-gradient(135deg, var(--primary), var(--accent));
            color: white;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 40px;
            border-top-right-radius: 40px;
            border-bottom-right-radius: 40px;
            animation: fadeInLeft 1s ease;
        }

        .left-section img {
            width: 100px;
            margin-bottom: 20px;
        }

        .left-section h1 {
            font-size: 32px;
            margin-bottom: 10px;
        }

        .left-section p {
            font-size: 18px;
            text-align: center;
            max-width: 300px;
        }

        .right-section {
            flex: 1;
            background-color: var(--form-bg);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 60px 30px;
            animation: fadeInRight 1s ease;
        }

        .form-box {
            width: 100%;
            max-width: 400px;
            background: white;
            padding: 30px;
            border-radius: 16px;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
        }

        .form-box h2 {
            margin-bottom: 20px;
            color: var(--primary);
            font-size: 24px;
            text-align: center;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            font-weight: 600;
            margin-bottom: 8px;
            color: var(--text);
        }

        .form-group input {
            width: 100%;
            padding: 12px;
            border: 1px solid #ccc;
            border-radius: 10px;
            font-size: 14px;
        }

        .form-group input:focus {
            outline: none;
            border-color: var(--accent);
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

        .extra-links {
            text-align: center;
            margin-top: 15px;
            font-size: 14px;
        }

        .extra-links a {
            color: var(--accent);
            text-decoration: none;
            margin: 0 8px;
        }

        .extra-links a:hover {
            text-decoration: underline;
        }

        @keyframes fadeInLeft {
            from {
                opacity: 0;
                transform: translateX(-30px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        @keyframes fadeInRight {
            from {
                opacity: 0;
                transform: translateX(30px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        @media (max-width: 768px) {
            .container {
                flex-direction: column;
            }
            .left-section {
                border-radius: 0;
                border-bottom-left-radius: 40px;
                border-bottom-right-radius: 40px;
                padding: 30px 20px;
            }
            .right-section {
                padding: 30px 20px;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="left-section">
                <img src="nwuLogo.png" alt="NWU Logo" />
                <h1>Welcome to NWU Market Place</h1>
                <p>The Right Way at the Right Time – Recover your password securely.</p>
            </div>

            <div class="right-section">
                <div class="form-box">
                    <h2>Forgot Password</h2>

                    <div class="form-group">
                        <label for="txtEmail">Email Address</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="Enter your email" TextMode="Email" />
                    </div>

                    <asp:Button ID="btnSubmit" runat="server" Text="Submit" CssClass="submit-btn" OnClick="btnSubmit_Click" />

                    <div class="extra-links">
                        <a href="Login.aspx">Back to Login</a>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
