<%@ Page Language="C#" Async="true" CodeBehind="Plans.aspx.cs" Inherits="MarketPlace.Plans" %>


<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Plans | NWU Market Place</title>
    <style>
        :root {
            --primary: #4B306A;
            --accent: #007C91;
            --light-bg: #f5f5f5;
            --text: #333;
        }

        body, html {
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--light-bg);
        }

        .header {
            text-align: center;
            padding: 50px 20px 30px;
            background: linear-gradient(135deg, var(--primary), var(--accent));
            color: white;
            border-bottom-left-radius: 30px;
            border-bottom-right-radius: 30px;
        }

        .header h1 {
            font-size: 36px;
            margin-bottom: 10px;
        }

        .header p {
            font-size: 18px;
            color: #e0e0e0;
        }

        .plans-container {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            gap: 30px;
            padding: 40px 20px;
        }

        .plan-box {
            background-color: white;
            border-radius: 16px;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.05);
            width: 300px;
            padding: 30px;
            text-align: center;
            transition: transform 0.3s ease;
        }

        .plan-box:hover {
            transform: translateY(-8px);
        }

        .plan-title {
            font-size: 22px;
            font-weight: bold;
            color: var(--primary);
            margin-bottom: 10px;
        }

        .plan-price {
            font-size: 28px;
            font-weight: bold;
            color: var(--accent);
            margin: 10px 0;
        }

        .plan-desc {
            font-size: 16px;
            margin-bottom: 20px;
            color: var(--text);
        }

        .plan-button {
            display: inline-block;
            padding: 12px 24px;
            font-size: 14px;
            color: white;
            background: linear-gradient(to right, var(--primary), var(--accent));
            border: none;
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
            transition: background 0.3s ease;
        }

        .plan-button:hover {
            background: linear-gradient(to right, #372450, #005c6e);
        }

        .notice-box {
            max-width: 700px;
            margin: 40px auto 20px auto;
            background: #fff3cd;
            border-left: 6px solid #ffeeba;
            color: #856404;
            padding: 20px 25px;
            font-size: 16px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
        }

        .payment-instruction {
            max-width: 700px;
            margin: 10px auto 50px auto;
            text-align: center;
            font-weight: 600;
            color: var(--primary);
            font-size: 18px;
        }

        .submit-proof-btn {
            display: block;
            width: 220px;
            margin: 0 auto 60px auto;
            padding: 12px 0;
            background: linear-gradient(to right, var(--primary), var(--accent));
            color: white;
            font-size: 16px;
            font-weight: bold;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            text-decoration: none;
            text-align: center;
            transition: background 0.3s ease;
        }
        .submit-proof-btn:hover {
            background: linear-gradient(to right, #372450, #005c6e);
        }

        @media (max-width: 768px) {
            .plans-container {
                flex-direction: column;
                align-items: center;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="header">
            <h1>Choose Your Plan</h1>
            <p>Select the perfect plan to start or grow your business on NWU Market Place</p>
        </div>

        <div class="plans-container">
            <div class="plan-box">
                <div class="plan-title">Student Plan</div>
                <div class="plan-price">R0</div>
                <div class="plan-desc">Open 1 Business Account<br />Perfect for starters.</div>
                <asp:Button ID="btnFree" runat="server" CssClass="plan-button" Text="Choose Free Plan" OnClick="btnFree_Click" />
            </div>

            <div class="plan-box">
                <div class="plan-title">Silver Plan</div>
                <div class="plan-price">R150</div>
                <div class="plan-desc">Open up to 3 Business Accounts<br />Ideal for small teams.</div>
                <asp:Button ID="btnSilver" runat="server" CssClass="plan-button" Text="Choose Silver Plan" OnClick="btnSilver_Click" />
            </div>

            <div class="plan-box">
                <div class="plan-title">Gold Plan</div>
                <div class="plan-price">R250</div>
                <div class="plan-desc">Open up to 5 Business Accounts<br />For growing businesses.</div>
                <asp:Button ID="btnGold" runat="server" CssClass="plan-button" Text="Choose Gold Plan" OnClick="btnGold_Click" />
            </div>
        </div>

        <div class="payment-instruction">
            IF you chose the Silver or Gold plan, click the link below to submit your proof of payment.
        </div>

        <a href="SubmitProof.aspx" class="submit-proof-btn">Submit Proof of Payment</a>

        <div class="notice-box">
            <strong>NB:</strong> If you are going to choose the Silver or Gold plan, please take screenshots of your payment and click the link above to submit it.
            After you are done paying RETURN  to this page to sumbit proof of payment, our Team will verify it and contact you with the steps to follow.
        </div>
    </form>
</body>
</html>
