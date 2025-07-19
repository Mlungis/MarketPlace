<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="customerdash.aspx.cs" Inherits="MarketPlace.customerdash" UnobtrusiveValidationMode="None" Culture="en-US" UICulture="en-US" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>NWU Marketplace - Customer Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet" />
    <style>
        /* GENERAL STYLES - Matched with AdvertiserDash */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        body {
            background-color: #fafafa;
            color: #222;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        a {
            color: #0078d4;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }

        /* HEADER - Matched with AdvertiserDash */
        .header {
            background: #004a99;
            color: white;
            padding: 10px 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: sticky;
            top: 0;
            z-index: 1000;
        }
        .header-content {
            display: flex;
            align-items: center;
            width: 100%;
            justify-content: space-between;
        }
        .logo {
            display: flex;
            align-items: center;
            gap: 10px;
            font-weight: 700;
            font-size: 1.5rem;
        }
        .logo i {
            font-size: 1.8rem;
        }
        .header-actions {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        .notification-btn {
            position: relative;
            background: transparent;
            border: none;
            color: white;
            cursor: pointer;
            font-size: 1.3rem;
            padding: 5px 10px;
        }
        .notification-badge {
            position: absolute;
            top: 0;
            right: 5px;
            background: #e81123;
            color: white;
            font-size: 0.7rem;
            padding: 2px 6px;
            border-radius: 12px;
            font-weight: 700;
        }
        .btn-secondary { /* Re-purposed for logout button in header */
            background-color: #0066cc;
            color: white;
            border: none;
            padding: 6px 14px;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 600;
            transition: background-color 0.3s ease;
        }
        .btn-secondary:hover {
            background-color: #004a99;
        }

        /* DASHBOARD LAYOUT - Matched with AdvertiserDash */
        .dashboard-container {
            display: flex;
            flex: 1;
            height: calc(100vh - 52px);
            overflow: hidden;
        }

        /* SIDEBAR - Matched with AdvertiserDash */
        .sidebar {
            background: #fff;
            width: 280px;
            border-right: 1px solid #ddd;
            display: flex;
            flex-direction: column;
            padding: 20px;
            overflow-y: auto;
        }
        .profile-section {
            text-align: center;
            margin-bottom: 30px;
        }
        .profile-avatar img, .profile-avatar {
            width: 90px;
            height: 90px;
            border-radius: 50%;
            object-fit: cover;
            background-color: #ddd;
            display: inline-block;
        }
        .profile-name {
            font-size: 1.25rem;
            font-weight: 700;
            margin-top: 10px;
        }
        .profile-status {
            font-size: 0.9rem;
            color: #0078d4;
            margin-top: 4px;
            font-weight: 600;
        }
        .stats-grid {
            display: flex;
            gap: 15px;
            justify-content: space-around;
            margin-bottom: 30px;
        }
        .stat-card {
            background: #0078d4;
            color: white;
            flex: 1;
            padding: 15px;
            border-radius: 8px;
            text-align: center;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .stat-number {
            font-size: 1.8rem;
            font-weight: 700;
        }
        .stat-label {
            font-size: 0.9rem;
            margin-top: 5px;
            font-weight: 600;
        }
        .nav-menu {
            list-style: none;
            padding-left: 0;
        }
        .nav-item {
            margin-bottom: 12px;
        }
        .nav-link {
            display: flex;
            align-items: center;
            gap: 10px;
            font-weight: 600;
            color: #444;
            padding: 10px 14px;
            border-radius: 6px;
            cursor: pointer;
            user-select: none;
            transition: background-color 0.3s ease;
        }
        .nav-link i {
            font-size: 1.2rem;
            width: 22px;
            text-align: center;
        }
        .nav-link:hover, .nav-link.active {
            background: #0078d4;
            color: white;
        }

        /* MAIN CONTENT - Matched with AdvertiserDash */
        .main-content {
            flex: 1;
            background: #fff;
            padding: 20px 30px;
            overflow-y: auto;
        }

        /* QUICK ACTIONS - Not used in Customer Dash, but keeping styles for consistency if needed */
        .quick-actions {
            display: flex;
            gap: 20px;
            margin-bottom: 25px;
            flex-wrap: wrap;
        }
        .action-card {
            background: #0078d4;
            color: white;
            flex: 1;
            min-width: 220px;
            border-radius: 12px;
            padding: 25px 20px;
            cursor: pointer;
            box-shadow: 0 4px 20px rgba(0,120,212,0.3);
            display: flex;
            flex-direction: column;
            align-items: center;
            transition: background-color 0.3s ease;
        }
        .action-card:hover {
            background: #005fa3;
        }
        .action-icon {
            font-size: 3rem;
            margin-bottom: 15px;
        }
        .action-title {
            font-size: 1.4rem;
            font-weight: 700;
            margin-bottom: 8px;
        }
        .action-description {
            font-size: 0.95rem;
            text-align: center;
            max-width: 240px;
        }

        /* CONTENT SECTIONS - Matched with AdvertiserDash */
        .content-section {
            /* padding: 15px 0; */
        }
        .section-header {
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .section-title {
            font-size: 1.6rem;
            font-weight: 700;
            color: #004a99;
            user-select: none;
        }
        .section-title i {
            font-size: 1.8rem;
        }

        /* SEARCH AND FILTERS - Matched with AdvertiserDash */
        .search-filters {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            margin-bottom: 20px;
            align-items: center;
        }
        .search-box {
            position: relative;
            flex: 1;
            max-width: 350px;
        }
        .search-icon {
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: #aaa;
            font-size: 1rem;
        }
        .search-input {
            width: 100%;
            padding: 8px 12px 8px 36px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 1rem;
            transition: border-color 0.3s ease;
        }
        .search-input:focus {
            border-color: #0078d4;
            outline: none;
        }
        .filter-btn {
            padding: 8px 14px;
            border-radius: 6px;
            border: 1px solid #ddd;
            background: white;
            cursor: pointer;
            font-weight: 600;
            color: #555;
            transition: border-color 0.3s ease;
        }
        .filter-btn:hover, .filter-btn:focus {
            border-color: #0078d4;
            outline: none;
            color: #004a99;
        }

        /* POSTS GRID - Matched with AdvertiserDash */
        .posts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 22px;
        }
        .post-card {
            background: white;
            border: 1px solid #ddd;
            border-radius: 12px;
            box-shadow: 0 3px 8px rgba(0,0,0,0.05);
            display: flex;
            flex-direction: column;
            overflow: hidden;
            transition: box-shadow 0.3s ease;
        }
        .post-card:hover {
            box-shadow: 0 6px 14px rgba(0,0,0,0.1);
        }
        .post-image {
            width: 100%;
            height: 190px;
            object-fit: cover;
            border-bottom: 1px solid #ddd;
            border-radius: 12px 12px 0 0;
        }
        .post-content {
            padding: 14px 18px 18px;
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        .post-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 12px;
        }
        .author-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            object-fit: cover;
        }
        .author-info h4 {
            font-size: 1rem;
            font-weight: 700;
            color: #0078d4;
        }
        .post-date {
            font-size: 0.8rem;
            color: #666;
            font-weight: 500;
        }
        .post-title {
            font-size: 1.15rem;
            font-weight: 700;
            margin-bottom: 8px;
            color: #222;
        }
        .post-description {
            flex: 1;
            font-size: 0.95rem;
            color: #555;
            margin-bottom: 15px;
        }
        .post-price {
            font-size: 1.1rem;
            font-weight: 700;
            color: #0078d4;
            margin-top: 10px;
        }
        .post-actions {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
            margin-top: 15px; /* Added margin */
        }
        .btn {
            padding: 6px 14px;
            border-radius: 6px;
            border: none;
            font-weight: 600;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }
        .btn-primary {
            background-color: #0078d4;
            color: white;
        }
        .btn-primary:hover {
            background-color: #005fa3;
        }
        .btn-secondary {
            background-color: #ddd;
            color: #444;
        }
        .btn-secondary:hover {
            background-color: #bbb;
        }

        /* FORM STYLES - Matched with AdvertiserDash */
        .form-group {
            margin-bottom: 20px;
        }
        .form-label {
            font-weight: 600;
            display: block;
            margin-bottom: 6px;
            color: #004a99;
        }
        .form-control {
            width: 100%;
            padding: 8px 12px;
            font-size: 1rem;
            border: 1px solid #ccc;
            border-radius: 6px;
            transition: border-color 0.3s ease;
        }
        .form-control:focus {
            border-color: #0078d4;
            outline: none;
        }
        .form-control.file-upload {
            padding: 6px 12px; /* Adjust padding for file input */
        }
        textarea.form-control {
            min-height: 100px;
            resize: vertical;
        }

        /* VALIDATION MESSAGES - Matched with AdvertiserDash */
        .status-error {
            color: #e81123;
            font-weight: 600;
            margin-top: 4px;
            font-size: 0.85rem;
        }
        .status-success {
            color: #107c10;
            font-weight: 700;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 1rem;
        }
        .status-success i {
            font-size: 1.3rem;
        }

        /* PROFILE SETTINGS SPECIFIC STYLES - Matched with AdvertiserDash */
        .profile-form-section {
            background: #f8f8f8;
            padding: 25px;
            border-radius: 12px;
            margin-bottom: 30px;
            border: 1px solid #eee;
        }
        .profile-form-section h3 {
            color: #004a99;
            margin-bottom: 20px;
            font-size: 1.4rem;
            font-weight: 700;
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
        }
        .profile-avatar-upload {
            display: flex;
            align-items: center;
            gap: 20px;
            margin-bottom: 30px;
        }
        .profile-avatar-display {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            object-fit: cover;
            border: 3px solid #0078d4;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .profile-password-info {
            background-color: #e6f2ff; /* Light blue background */
            border: 1px solid #a8d5ff; /* Blue border */
            border-radius: 8px;
            padding: 15px;
            margin-top: 20px;
            font-size: 0.9rem;
            color: #004a99;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .profile-password-info i {
            font-size: 1.2rem;
            color: #0078d4;
        }

        /* FADE-IN ANIMATION - Matched with AdvertiserDash */
        .fade-in {
            animation: fadeIn 0.5s ease forwards;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(15px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* RESPONSIVE - Matched with AdvertiserDash */
        @media (max-width: 900px) {
            .dashboard-container {
                flex-direction: column;
                height: auto;
            }
            .sidebar {
                width: 100%;
                border-right: none;
                border-bottom: 1px solid #ddd;
                flex-direction: row;
                overflow-x: auto;
                padding: 10px 15px;
            }
            .profile-section {
                flex: 1 0 auto;
                margin-bottom: 0;
                text-align: left;
            }
            .nav-menu {
                display: flex;
                flex-wrap: nowrap;
                gap: 8px;
            }
            .nav-item {
                margin-bottom: 0;
                flex: 0 0 auto;
            }
            .main-content {
                padding: 15px 20px;
                height: auto;
            }
            .posts-grid {
                grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            }
        }

        /* Post Details Specific Styles */
        .post-detail-card {
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            padding: 30px;
            max-width: 800px; /* Constrain width for readability */
            margin: 20px auto; /* Center the card */
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .detail-image {
            width: 100%;
            max-height: 400px;
            object-fit: contain; /* Use contain to see full image, cover if you prefer fill */
            border-radius: 8px;
            border: 1px solid #eee;
        }

        .detail-title {
            font-size: 2.2rem;
            font-weight: 700;
            color: #004a99;
            margin-bottom: 10px;
        }

        .detail-price {
            font-size: 1.8rem;
            font-weight: 800;
            color: #0078d4;
            margin-bottom: 15px;
        }

        .detail-meta-info {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }

        .detail-meta-item {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.95rem;
            color: #555;
            font-weight: 600;
        }

        .detail-meta-item i {
            color: #0078d4;
            font-size: 1.1rem;
        }

        .detail-description-full {
            font-size: 1.05rem;
            line-height: 1.6;
            color: #333;
            margin-bottom: 30px;
            white-space: pre-wrap; /* Preserves whitespace and line breaks */
        }

        .detail-advertiser-info {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 15px;
            background-color: #f0f8ff; /* Light blue background */
            border-radius: 8px;
            border: 1px solid #e0f0ff;
        }

        .detail-advertiser-avatar {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid #0078d4;
        }

        .detail-advertiser-name {
            font-size: 1.1rem;
            font-weight: 700;
            color: #004a99;
        }

        .detail-advertiser-status {
            font-size: 0.85rem;
            color: #666;
        }

        .back-button-container {
            margin-top: 30px;
            text-align: center;
        }

        /* Seller Profile Specific Styles (NEW) */
        .seller-profile-card {
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            padding: 30px;
            max-width: 600px;
            margin: 20px auto;
            text-align: center;
        }
        .seller-profile-card .profile-avatar-display {
            width: 120px;
            height: 120px;
            margin: 0 auto 20px;
            border: 4px solid #0078d4;
        }
        .seller-profile-card h3 {
            font-size: 2rem;
            color: #004a99;
            margin-bottom: 10px;
        }
        .seller-profile-card p {
            font-size: 1.1rem;
            color: #555;
            margin-bottom: 15px;
        }
        .seller-contact-info {
            font-size: 1rem;
            color: #333;
            margin-top: 20px;
            padding-top: 15px;
            border-top: 1px solid #eee;
        }
        .seller-contact-info i {
            margin-right: 8px;
            color: #0078d4;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />
        
        <header class="header">
            <div class="header-content">
                <div class="logo">
                    <i class="fas fa-store"></i>
                    <h1>NWU Marketplace</h1>
                </div>
                <div class="header-actions">
                    <button type="button" class="notification-btn">
                        <i class="fas fa-bell"></i>
                        <span class="notification-badge">3</span>
                    </button>
                    <asp:Button ID="btnLogout" runat="server" Text="Logout" CssClass="btn btn-secondary" OnClick="btnLogout_Click" />
                </div>
            </div>
        </header>

        <div class="dashboard-container">
            <aside class="sidebar">
                <div class="profile-section">
                    <div class="profile-avatar">
                        <asp:Image ID="imgProfilePic" runat="server" ImageUrl="~/images/default-avatar.png" AlternateText="Profile Picture" />
                    </div>
                    <div class="profile-name">
                        <asp:Literal ID="litUserName" runat="server" Text="Customer Name" />
                    </div>
                    <div class="profile-status">Active Buyer</div>
                </div>

                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-number">
                            <asp:Literal ID="litTotalPurchases" runat="server" Text="0" />
                        </div>
                        <div class="stat-label">Total Purchases</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">
                            <asp:Literal ID="litItemsSaved" runat="server" Text="0" />
                        </div>
                        <div class="stat-label">Items Saved</div>
                    </div>
                </div>

                <nav>
                    <ul class="nav-menu">
                        <li class="nav-item">
                            <asp:LinkButton ID="lnkAllPosts" runat="server" CssClass="nav-link active" OnClick="ShowAllPosts_Click">
                                <i class="fas fa-home"></i>
                                All Posts
                            </asp:LinkButton>
                        </li>
                        <%-- Removed Messages link --%>
                        <li class="nav-item">
                            <asp:LinkButton ID="lnkProfile" runat="server" CssClass="nav-link" OnClick="ShowProfile_Click">
                                <i class="fas fa-user-cog"></i>
                                Profile Settings
                            </asp:LinkButton>
                        </li>
                        <li class="nav-item">
                            <asp:LinkButton ID="lnkChangeTheme" runat="server" CssClass="nav-link">
                                <i class="fas fa-paint-brush"></i>
                                Change Theme
                            </asp:LinkButton>
                        </li>
                    </ul>
                </nav>
            </aside>

            <main class="main-content">
                <asp:Panel ID="pnlAllPosts" runat="server" CssClass="content-section">
                    <div class="section-header">
                        <h2 class="section-title">
                            <i class="fas fa-store"></i>
                            Campus Marketplace
                        </h2>
                    </div>
                    
                    <div class="search-filters">
                        <div class="search-box">
                            <i class="fas fa-search search-icon"></i>
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="search-input" placeholder="Search posts, items, or sellers..." AutoPostBack="true" OnTextChanged="txtSearch_TextChanged" />
                        </div>
                        <asp:DropDownList ID="ddlCategory" runat="server" CssClass="filter-btn" AutoPostBack="true" OnSelectedIndexChanged="ddlCategory_SelectedIndexChanged">
                            <asp:ListItem Text="All Categories" Value="" />
                            <asp:ListItem Text="Electronics" Value="electronics" />
                            <asp:ListItem Text="Books" Value="books" />
                            <asp:ListItem Text="Clothing" Value="clothing" />
                            <asp:ListItem Text="Housing" Value="housing" />
                            <asp:ListItem Text="Services" Value="services" />
                            <asp:ListItem Text="Other" Value="other" />
                        </asp:DropDownList>
                        <asp:DropDownList ID="ddlSortBy" runat="server" CssClass="filter-btn" AutoPostBack="true" OnSelectedIndexChanged="ddlSortBy_SelectedIndexChanged">
                            <asp:ListItem Text="Latest First" Value="latest" />
                            <asp:ListItem Text="Oldest First" Value="oldest" />
                            <asp:ListItem Text="Most Popular" Value="popular" />
                        </asp:DropDownList>
                    </div>

                    <div class="posts-grid">
                        <asp:Repeater ID="rptAllPosts" runat="server" OnItemCommand="rptAllPosts_ItemCommand">
                            <ItemTemplate>
                                <div class="post-card fade-in">
                                    <asp:Image ID="imgPost" runat="server" 
                                        ImageUrl='<%# !string.IsNullOrEmpty(Eval("ImageUrl").ToString()) ? Eval("ImageUrl") : "~/images/no-image.jpg" %>' 
                                        CssClass="post-image" 
                                        AlternateText='<%# Eval("Title") %>' />
                                    
                                    <div class="post-content">
                                        <div class="post-header">
                                            <asp:Image ID="imgAuthor" runat="server" 
                                                ImageUrl='<%# Eval("AdvertiserProfilePic") %>' 
                                                CssClass="author-avatar" 
                                                AlternateText='<%# Eval("AdvertiserName") %>' />
                                            <div class="author-info">
                                                <h4><%# Eval("AdvertiserName") %></h4>
                                                <div class="post-date"><%# Eval("DateCreated", "{0:MMM dd, yyyy}") %></div>
                                            </div>
                                        </div>
                                        
                                        <h3 class="post-title"><%# Eval("Title") %></h3>
                                        <p class="post-description"><%# Eval("ShortDescription") %></p>
                                        <div class="post-price"><strong>R <%# Eval("Price", "{0:N2}") %></strong></div>
                                        
                                        <div class="post-actions">
                                            <%-- Removed Contact and Comment buttons --%>
                                            <asp:Button ID="btnViewDetails" runat="server" 
                                                CommandName="ViewDetails" 
                                                CommandArgument='<%# Eval("PostId") %>' 
                                                Text="View Details" 
                                                CssClass="btn btn-primary" />
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        <asp:Label ID="lblNoPosts" runat="server" Text="No posts found matching your criteria." Visible="false" CssClass="status-error" Style="margin-top: 20px;" />
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlProfileSettings" runat="server" CssClass="content-section" Visible="false">
                    <div class="section-header">
                        <h2 class="section-title">
                            <i class="fas fa-user-cog"></i>
                            Profile Settings
                        </h2>
                    </div>

                    <asp:Panel ID="pnlProfileStatusMessage" runat="server" Visible="false">
                        <div class="status-message status-success">
                            <i class="fas fa-check-circle"></i>
                            <asp:Literal ID="litProfileStatusMessage" runat="server" />
                        </div>
                    </asp:Panel>

                    <div class="profile-form-section">
                        <h3>Personal Information</h3>
                        <div class="profile-avatar-upload">
                            <asp:Image ID="imgProfilePreview" runat="server" ImageUrl="~/images/default-avatar.png" CssClass="profile-avatar-display" AlternateText="Current Profile Picture" />
                            <div>
                                <asp:Label ID="lblProfileImage" runat="server" Text="Change Profile Picture" CssClass="form-label" AssociatedControlID="fuProfileImage" />
                                <asp:FileUpload ID="fuProfileImage" runat="server" CssClass="form-control file-upload" AllowMultiple="false" />
                                <asp:RegularExpressionValidator ID="revProfileImage" runat="server"
                                    ControlToValidate="fuProfileImage"
                                    ValidationExpression="^.*\.(jpg|JPG|jpeg|JPEG|png|PNG|gif|GIF)$"
                                    ErrorMessage="Only JPG, JPEG, PNG, GIF images are allowed."
                                    CssClass="status-error"
                                    Display="Dynamic"
                                    ValidationGroup="UpdateProfile" />
                            </div>
                        </div>

                        <div class="form-group">
                            <asp:Label ID="lblFullName" runat="server" Text="Full Name" CssClass="form-label" AssociatedControlID="txtFullName" />
                            <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" placeholder="Your full name" />
                            <asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName" ErrorMessage="Full Name is required." CssClass="status-error" Display="Dynamic" ValidationGroup="UpdateProfile" />
                        </div>
                        <div class="form-group">
                            <asp:Label ID="lblEmail" runat="server" Text="Email Address" CssClass="form-label" AssociatedControlID="txtEmail" />
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="Your email address" TextMode="Email" Enabled="false" />
                        </div>
                        <div class="form-group">
                            <asp:Label ID="lblPhoneNumber" runat="server" Text="Phone Number" CssClass="form-label" AssociatedControlID="txtPhoneNumber" />
                            <asp:TextBox ID="txtPhoneNumber" runat="server" CssClass="form-control" placeholder="e.g., 0712345678" TextMode="Phone" />
                            <asp:RequiredFieldValidator ID="rfvPhoneNumber" runat="server" ControlToValidate="txtPhoneNumber" ErrorMessage="Phone Number is required." CssClass="status-error" Display="Dynamic" ValidationGroup="UpdateProfile" />
                            <asp:RegularExpressionValidator ID="revPhoneNumber" runat="server"
                                ControlToValidate="txtPhoneNumber"
                                ValidationExpression="^(\+27|0)[6-8][0-9]{8}$"
                                ErrorMessage="Invalid South African phone number format."
                                CssClass="status-error"
                                Display="Dynamic"
                                ValidationGroup="UpdateProfile" />
                        </div>
                        <asp:Button ID="btnUpdateProfile" runat="server" Text="Update Profile" CssClass="btn btn-primary" OnClick="btnUpdateProfile_Click" ValidationGroup="UpdateProfile" />
                    </div>

                    <div class="profile-form-section">
                        <h3>Change Password</h3>
                        <div class="profile-password-info">
                            <i class="fas fa-info-circle"></i>
                            Leave password fields blank if you don't wish to change your password.
                        </div>
                        <div class="form-group">
                            <asp:Label ID="lblCurrentPassword" runat="server" Text="Current Password" CssClass="form-label" AssociatedControlID="txtCurrentPassword" />
                            <asp:TextBox ID="txtCurrentPassword" runat="server" CssClass="form-control" TextMode="Password" />
                            <asp:RequiredFieldValidator ID="rfvCurrentPassword" runat="server" ControlToValidate="txtCurrentPassword" ErrorMessage="Current Password is required to change password." CssClass="status-error" Display="Dynamic" ValidationGroup="ChangePassword" />
                        </div>
                        <div class="form-group">
                            <asp:Label ID="lblNewPassword" runat="server" Text="New Password" CssClass="form-label" AssociatedControlID="txtNewPassword" />
                            <asp:TextBox ID="txtNewPassword" runat="server" CssClass="form-control" TextMode="Password" />
                            <asp:RequiredFieldValidator ID="rfvNewPassword" runat="server" ControlToValidate="txtNewPassword" ErrorMessage="New Password is required." CssClass="status-error" Display="Dynamic" ValidationGroup="ChangePassword" />
                            <asp:RegularExpressionValidator ID="revNewPassword" runat="server"
                                ControlToValidate="txtNewPassword"
                                ValidationExpression="^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^\da-zA-Z]).{8,}$"
                                ErrorMessage="Password must be at least 8 characters long and include an uppercase letter, a lowercase letter, a number, and a special character."
                                CssClass="status-error"
                                Display="Dynamic"
                                ValidationGroup="ChangePassword" />
                        </div>
                        <div class="form-group">
                            <asp:Label ID="lblConfirmNewPassword" runat="server" Text="Confirm New Password" CssClass="form-label" AssociatedControlID="txtConfirmNewPassword" />
                            <asp:TextBox ID="txtConfirmNewPassword" runat="server" CssClass="form-control" TextMode="Password" />
                            <asp:CompareValidator ID="cvConfirmNewPassword" runat="server" ControlToCompare="txtNewPassword" ControlToValidate="txtConfirmNewPassword" ErrorMessage="New password and confirmation password do not match." CssClass="status-error" Display="Dynamic" ValidationGroup="ChangePassword" />
                        </div>
                        <asp:Button ID="btnChangePassword" runat="server" Text="Change Password" CssClass="btn btn-primary" OnClick="btnChangePassword_Click" ValidationGroup="ChangePassword" />
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlPostDetails" runat="server" CssClass="content-section" Visible="false">
                    <div class="section-header">
                        <h2 class="section-title">
                            <i class="fas fa-info-circle"></i>
                            Post Details
                        </h2>
                    </div>

                    <div class="post-detail-card fade-in">
                        <asp:Image ID="imgDetailImage" runat="server" CssClass="detail-image" AlternateText="Post Image" ImageUrl="~/images/no-image.jpg" />
                        <h2 class="detail-title">
                            <asp:Literal ID="litDetailTitle" runat="server" />
                        </h2>
                        <div class="detail-price">
                            R <asp:Literal ID="litDetailPrice" runat="server" />
                        </div>

                        <div class="detail-meta-info">
                            <div class="detail-meta-item">
                                <i class="fas fa-calendar-alt"></i>
                                <asp:Literal ID="litDetailDate" runat="server" />
                            </div>
                            <div class="detail-meta-item">
                                <i class="fas fa-tag"></i>
                                <asp:Literal ID="litDetailCategory" runat="server" />
                            </div>
                        </div>

                        <p class="detail-description-full">
                            <asp:Literal ID="litDetailDescription" runat="server" />
                        </p>

                        <div class="detail-advertiser-info">
                            <asp:Image ID="imgDetailAdvertiserAvatar" runat="server" CssClass="detail-advertiser-avatar" ImageUrl="~/images/default-avatar.png" AlternateText="Advertiser Avatar" />
                            <div>
                                <div class="detail-advertiser-name">
                                    <asp:Literal ID="litDetailAdvertiserName" runat="server" />
                                </div>
                                <div class="detail-advertiser-status">
                                    Seller
                                </div>
                                <asp:LinkButton ID="lnkViewSellerProfile" runat="server" Text="View Seller Profile" OnClick="lnkViewSellerProfile_Click" CssClass="btn btn-secondary" />
                                <asp:Button ID="btnContactAdvertiser" runat="server" Text="Contact Seller" CssClass="btn btn-primary" OnClick="btnContactAdvertiser_Click" />
                            </div>
                        </div>
                        
                        <div class="back-button-container">
                             <asp:Button ID="btnBackToAllPosts" runat="server" Text="Back to All Posts" CssClass="btn btn-secondary" OnClick="ShowAllPosts_Click" />
                        </div>
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlSellerProfile" runat="server" CssClass="content-section" Visible="false">
                    <div class="section-header">
                        <h2 class="section-title">
                            <i class="fas fa-user-alt"></i>
                            Seller Profile
                        </h2>
                    </div>

                    <div class="seller-profile-card fade-in">
                        <asp:Image ID="imgSellerProfileAvatar" runat="server" ImageUrl="~/images/default-avatar.png" CssClass="profile-avatar-display" AlternateText="Seller Profile Picture" />
                        <h3>
                            <asp:Literal ID="litSellerName" runat="server" />
                        </h3>
                        <p>
                            <asp:Literal ID="litSellerDescription" runat="server" Text="No description provided." />
                        </p>
                        
                        <div class="seller-contact-info">
                            <p><i class="fas fa-envelope"></i> <asp:Literal ID="litSellerEmail" runat="server" /></p>
                            <p><i class="fas fa-phone"></i> <asp:Literal ID="litSellerPhone" runat="server" /></p>
                        </div>

                        <div class="back-button-container">
                            <asp:Button ID="btnBackFromSellerProfile" runat="server" Text="Back to Post Details" CssClass="btn btn-secondary" OnClick="btnBackFromSellerProfile_Click" />
                        </div>
                    </div>
                </asp:Panel>

            </main>
        </div>
    </form>
</body>
</html>