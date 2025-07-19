<%@ Page Async="true" Language="C#" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="MarketPlace.Register" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Register | NWU Market Place</title>
    <style>
        :root {
            --primary: #4B306A;
            --accent: #007C91;
            --light-bg: #f5f5f5;
            --form-bg: #ffffff;
            --text: #333;
        }

        * {
            box-sizing: border-box;
        }

        body, html {
            margin: 0;
            padding: 0;
            height: 100%;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--light-bg);
            position: relative;
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
            max-width: 450px;
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

        .form-group input,
        .form-group select {
            width: 100%;
            padding: 12px;
            border: 1px solid #ccc;
            border-radius: 10px;
            font-size: 14px;
        }

        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: var(--accent);
        }

        .register-btn {
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

        .register-btn:hover {
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
        }

        .extra-links a:hover {
            text-decoration: underline;
        }

        @keyframes fadeInLeft {
            from { opacity: 0; transform: translateX(-30px); }
            to { opacity: 1; transform: translateX(0); }
        }

        @keyframes fadeInRight {
            from { opacity: 0; transform: translateX(30px); }
            to { opacity: 1; transform: translateX(0); }
        }

        .contact-box {
            position: fixed;
            bottom: 20px;
            left: 20px;
            background: white;
            border-left: 4px solid var(--primary);
            padding: 15px 20px;
            border-radius: 10px;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
            font-size: 14px;
            color: var(--text);
            line-height: 1.5;
            z-index: 999;
        }

        .contact-box strong {
            color: var(--accent);
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

            .contact-box {
                left: 10px;
                right: 10px;
                bottom: 10px;
                font-size: 13px;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="left-section">
                <img src="nwuLogo.png" alt="NWU Logo" />
                <h1>Join NWU Market Place</h1>
                <p>Create your free account to start trading, listing, and exploring items around campus.</p>
            </div>

            <div class="right-section">
                <div class="form-box">
                    <h2>Create Account</h2>

                    <div class="form-group">
                        <label for="txtFullName">Full Name</label>
                        <input type="text" id="txtFullName" runat="server" placeholder="e.g. Mlungisi Ncube" />
                    </div>

                    <div class="form-group">
                        <label for="txtEmail">Email</label>
                        <input type="email" id="txtEmail" runat="server" placeholder="Enter your email" />
                    </div>

                    <div class="form-group">
                        <label for="txtCell">Cell Number</label>
                        <input type="tel" id="txtCell" runat="server" placeholder="e.g. +27..." />
                    </div>

                    <div class="form-group">
                        <label for="txtPassword">Password</label>
                        <input type="password" id="txtPassword" runat="server" placeholder="Create a strong password" />
                    </div>

                    <div class="form-group">
                        <label for="ddlRole">Register As</label>
                        <asp:DropDownList ID="ddlRole" runat="server" CssClass="form-control">
                            <asp:ListItem Text="Select Role" Value="" />
                            <asp:ListItem Text="Customer" Value="Customer" />
                            <asp:ListItem Text="Advertiser" Value="Advertiser" />
                        </asp:DropDownList>
                    </div>

                    <asp:Button ID="btnRegister" runat="server" Text="Register" CssClass="register-btn" OnClick="btnRegister_Click" />
                    <br />
                    <asp:Label ID="lblMessage" runat="server" Text="Label"></asp:Label>

                    <div class="extra-links">
                        Already have an account? <a href="Login.aspx">Login</a>
                    </div>
                </div>
            </div>
        </div>

        <div class="contact-box">
            <strong>Developer Contact:</strong><br />
            📞 +27 71 065 8544<br />
            ✉️ ncubemlu05@gmail.com
        </div>
    </form>
</body>
</html>
