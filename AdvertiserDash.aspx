<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdvertiserDash.aspx.cs" Inherits="MarketPlace.AdvertiserDash" Async="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>NWU Marketplace - Your Campus Trading Hub</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet" />
    <style>
        /* GENERAL STYLES */
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

        /* HEADER */
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
        .btn-secondary {
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

        /* DASHBOARD LAYOUT */
        .dashboard-container {
            display: flex;
            flex: 1;
            height: calc(100vh - 52px); /* Adjust based on header height */
            overflow: hidden;
        }

        /* SIDEBAR */
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

        /* MAIN CONTENT */
        .main-content {
            flex: 1;
            background: #fff;
            padding: 20px 30px;
            overflow-y: auto;
        }

        /* QUICK ACTIONS */
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

        /* CONTENT SECTIONS */
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

        /* SEARCH AND FILTERS */
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

        /* POSTS GRID */
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
        .btn-danger {
            background-color: #e81123;
            color: white;
        }
        .btn-danger:hover {
            background-color: #c40a1b;
        }

        /* FORM STYLES */
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

        /* VALIDATION MESSAGES */
        .status-error {
            color: #e81123;
            font-weight: 600;
            margin-top: 4px;
            font-size: 0.85rem;
            display: block; /* Ensure it takes its own line */
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
        .status-info { /* Added for informational messages like "Editing post" */
            color: #0078d4;
            font-weight: 700;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 1rem;
        }
        .status-info i {
            font-size: 1.3rem;
            color: #0078d4;
        }

        /* NO POSTS MESSAGE STYLES */
        .no-posts-message {
            padding: 20px;
            text-align: center;
            font-style: italic;
            color: #666;
            grid-column: 1 / -1;
        }

        /* PROFILE SETTINGS SPECIFIC STYLES */
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

        /* CURRENT POST IMAGE STYLES */
        .current-post-image {
            max-width: 200px;
            max-height: 200px;
            margin: 10px 0;
            border: 1px solid #ddd;
            padding: 5px;
        }

        /* FADE-IN ANIMATION */
        .fade-in {
            animation: fadeIn 0.5s ease forwards;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(15px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* RESPONSIVE */
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
                justify-content: center; /* Center sidebar items on small screens */
            }
            .profile-section {
                flex: 1 0 auto;
                margin-bottom: 0;
                text-align: left;
                display: none; /* Hide profile section on small screens in sidebar to save space */
            }
            .stats-grid {
                display: none; /* Hide stats grid on small screens in sidebar */
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
            .search-filters {
                flex-direction: column;
                align-items: stretch;
            }
            .search-box {
                max-width: 100%;
            }
            .filter-btn {
                width: 100%;
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

        @media (max-width: 600px) {
            .post-detail-card {
                padding: 20px;
                margin: 15px;
            }
            .detail-title {
                font-size: 1.8rem;
            }
            .detail-price {
                font-size: 1.5rem;
            }
            .detail-meta-info {
                flex-direction: column;
                align-items: flex-start;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />
        
        <%-- Hidden field to store PostId for editing --%>
        <asp:HiddenField ID="hdnPostId" runat="server" Value="" />

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
                        <asp:Literal ID="litUserName" runat="server" Text="Mlungisi Ncube" />
                    </div>
                    <div class="profile-status">Active Seller</div>
                </div>

                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-number">
                            <asp:Literal ID="litTotalPosts" runat="server" Text="0" />
                        </div>
                        <div class="stat-label">Total Posts</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">
                            <asp:Literal ID="litTotalViews" runat="server" Text="0" />
                        </div>
                        <div class="stat-label">Total Views</div>
                    </div>
                </div>

                <nav>
                    <ul class="nav-menu">
                        <li class="nav-item">
                            <asp:LinkButton ID="lnkAllPosts" runat="server" CssClass="nav-link" OnClick="ShowAllPosts_Click">
                                <i class="fas fa-home"></i>
                                All Posts
                            </asp:LinkButton>
                        </li>
                        <li class="nav-item">
                            <asp:LinkButton ID="lnkCreatePost" runat="server" CssClass="nav-link" OnClick="ShowCreatePost_Click">
                                <i class="fas fa-plus-circle"></i>
                                Create Post
                            </asp:LinkButton>
                        </li>
                        <li class="nav-item">
                            <asp:LinkButton ID="lnkMyPosts" runat="server" CssClass="nav-link" OnClick="ShowMyPosts_Click">
                                <i class="fas fa-list"></i>
                                My Posts
                            </asp:LinkButton>
                        </li>
                        <li class="nav-item">
                            <asp:LinkButton ID="lnkProfile" runat="server" CssClass="nav-link" OnClick="ShowProfile_Click">
                                <i class="fas fa-user-cog"></i>
                                Profile Settings
                            </asp:LinkButton>
                        </li>
                    </ul>
                </nav>
            </aside>

            <main class="main-content">
                <%-- Quick Actions Panel (Dashboard View) --%>
                <asp:Panel ID="pnlQuickActions" runat="server" CssClass="quick-actions">
                    <div class="action-card" onclick="<%= Page.ClientScript.GetPostBackEventReference(lnkCreatePost, "") %>">
                        <div class="action-icon">
                            <i class="fas fa-plus-circle"></i>
                        </div>
                        <div class="action-title">Create New Post</div>
                        <div class="action-description">Share what you're selling with the campus community</div>
                    </div>
                    <div class="action-card" onclick="<%= Page.ClientScript.GetPostBackEventReference(lnkMyPosts, "") %>">
                        <div class="action-icon">
                            <i class="fas fa-chart-line"></i>
                        </div>
                        <div class="action-title">View Analytics</div>
                        <div class="action-description">Track your post performance and engagement</div>
                    </div>
                </asp:Panel>

                <%-- All Posts Panel --%>
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
                            <asp:ListItem Text="Electronics" Value="Electronics" />
                            <asp:ListItem Text="Books" Value="Books" />
                            <asp:ListItem Text="Clothing" Value="Clothing" />
                            <asp:ListItem Text="Housing" Value="Housing" />
                            <asp:ListItem Text="Services" Value="Services" />
                            <asp:ListItem Text="Vehicles" Value="Vehicles" />
                            <asp:ListItem Text="Other" Value="Other" />
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
                                        ImageUrl='<%# !string.IsNullOrEmpty(Eval("ImageUrl") as string) ? Eval("ImageUrl") : ResolveUrl("~/images/no-image.jpg") %>' 
                                        CssClass="post-image" 
                                        AlternateText='<%# Eval("Title") %>' />
                                    
                                    <div class="post-content">
                                        <div class="post-header">
                                            <asp:Image ID="imgAuthor" runat="server" 
                                                ImageUrl='<%# Eval("AdvertiserProfilePic") != null && !string.IsNullOrEmpty(Eval("AdvertiserProfilePic").ToString()) ? Eval("AdvertiserProfilePic") : ResolveUrl("~/images/default-avatar.png") %>' 
                                                CssClass="author-avatar" 
                                                AlternateText='<%# Eval("AdvertiserFullName") %>' />
                                            <div class="author-info">
                                                <h4><%# Eval("AdvertiserFullName") %></h4>
                                                <div class="post-date"><%# Eval("DateCreated", "{0:MMM dd, yyyy}") %></div>
                                            </div>
                                        </div>
                                        
                                        <h3 class="post-title"><%# Eval("Title") %></h3>
                                        <p class="post-description"><%# Eval("ShortDescription") %></p>
                                        <div class="post-price"><strong>R <%# Eval("Price", "{0:N2}") %></strong></div>
                                        
                                        <div class="post-actions">
                                            <asp:Button ID="btnViewDetails" runat="server" 
                                                CommandName="ViewDetails" 
                                                CommandArgument='<%# Eval("PostId") %>' 
                                                Text="View Details" 
                                                CssClass="btn btn-primary" />
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:Panel ID="pnlNoAllPostsMessage" runat="server" CssClass="no-posts-message" Visible="<%# ((Repeater)Container.NamingContainer).Items.Count == 0 %>">
                                    <p>No posts found matching your criteria.</p>
                                </asp:Panel>
                            </FooterTemplate>
                        </asp:Repeater>
                    </div>
                </asp:Panel>

                <%-- Create Post Panel --%>
                <asp:Panel ID="pnlCreatePost" runat="server" CssClass="content-section" Visible="false">
                    <div class="section-header">
                        <h2 class="section-title">
                            <i class="fas fa-plus-circle"></i>
                            Create New Post
                        </h2>
                    </div>
                    
                    <asp:Panel ID="pnlCreatePostStatusMessage" runat="server" Visible="false">
                        <div class="status-success">
                            <i class="fas fa-check-circle"></i>
                            <asp:Literal ID="litCreatePostStatusMessage" runat="server" />
                        </div>
                    </asp:Panel>
                    <asp:ValidationSummary ID="vsCreatePost" runat="server" ShowSummary="true" ValidationGroup="CreatePost" HeaderText="Please correct the following errors:" CssClass="status-error" />

                    <div class="form-group">
                        <asp:Label ID="lblTitle" runat="server" Text="Post Title" CssClass="form-label" AssociatedControlID="txtTitle" />
                        <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" placeholder="Enter a catchy title for your post" MaxLength="100" />
                        <asp:RequiredFieldValidator ID="rfvTitle" runat="server" 
                            ControlToValidate="txtTitle" 
                            ErrorMessage="Title is required." 
                            CssClass="status-error" 
                            Display="Dynamic" 
                            ValidationGroup="CreatePost" />
                    </div>

                    <div class="form-group">
                        <asp:Label ID="lblDescription" runat="server" Text="Description" CssClass="form-label" AssociatedControlID="txtDescription" />
                        <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="5" CssClass="form-control" placeholder="Provide a detailed description of your item..." MaxLength="500" />
                        <asp:RequiredFieldValidator ID="rfvDescription" runat="server" 
                            ControlToValidate="txtDescription" 
                            ErrorMessage="Description is required." 
                            CssClass="status-error" 
                            Display="Dynamic" 
                            ValidationGroup="CreatePost" />
                    </div>

                    <div class="form-group">
                        <asp:Label ID="lblPrice" runat="server" Text="Price (R)" CssClass="form-label" AssociatedControlID="txtPrice" />
                        <asp:TextBox ID="txtPrice" runat="server" CssClass="form-control" placeholder="e.g., 150.00" />
                        <asp:RequiredFieldValidator ID="rfvPrice" runat="server"
                            ControlToValidate="txtPrice"
                            ErrorMessage="Price is required."
                            CssClass="status-error"
                            Display="Dynamic"
                            ValidationGroup="CreatePost" />
                        <asp:RegularExpressionValidator ID="revPrice" runat="server"
                            ControlToValidate="txtPrice"
                            ValidationExpression="^\d+(\.\d{1,2})?$"
                            ErrorMessage="Price must be a valid number (e.g., 150 or 150.99)."
                            CssClass="status-error"
                            Display="Dynamic"
                            ValidationGroup="CreatePost" />
                    </div>

                    <div class="form-group">
                        <asp:Label ID="lblCategory" runat="server" Text="Category" CssClass="form-label" AssociatedControlID="ddlNewPostCategory" />
                        <asp:DropDownList ID="ddlNewPostCategory" runat="server" CssClass="form-control">
                            <asp:ListItem Text="Select Category" Value="" />
                            <asp:ListItem Text="Electronics" Value="Electronics" />
                            <asp:ListItem Text="Books" Value="Books" />
                            <asp:ListItem Text="Clothing" Value="Clothing" />
                            <asp:ListItem Text="Housing" Value="Housing" />
                            <asp:ListItem Text="Services" Value="Services" />
                            <asp:ListItem Text="Vehicles" Value="Vehicles" />
                            <asp:ListItem Text="Other" Value="Other" />
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvNewPostCategory" runat="server"
                            ControlToValidate="ddlNewPostCategory"
                            InitialValue=""
                            ErrorMessage="Category is required."
                            CssClass="status-error"
                            Display="Dynamic"
                            ValidationGroup="CreatePost" />
                    </div>

                    <div class="form-group">
                        <asp:Label ID="lblImageUpload" runat="server" Text="Upload Image" CssClass="form-label" AssociatedControlID="fuImage" />
                        <asp:FileUpload ID="fuImage" runat="server" CssClass="form-control file-upload" />
                        <asp:RegularExpressionValidator ID="revImage" runat="server"
                            ControlToValidate="fuImage"
                            ValidationExpression="^.*\.(jpg|jpeg|png|gif|bmp)$"
                            ErrorMessage="Only image files (jpg, jpeg, png, gif, bmp) are allowed."
                            CssClass="status-error"
                            Display="Dynamic"
                            ValidationGroup="CreatePost" />
                        <%-- Required if you always need an image for a new post --%>
                        <asp:CustomValidator ID="cvImageRequired" runat="server"
                            ControlToValidate="fuImage"
                            ErrorMessage="An image is required for a new post."
                            OnServerValidate="cvImageRequired_ServerValidate"
                            CssClass="status-error"
                            Display="Dynamic"
                            ValidationGroup="CreatePost" />
                    </div>

                    <%-- Current post image display (for editing) --%>
                    <asp:Image ID="imgCurrentPostPic" runat="server" CssClass="current-post-image" Visible="false" />

                    <asp:Button ID="btnSubmitPost" runat="server" Text="Create Post" CssClass="btn btn-primary" OnClick="btnSubmitPost_Click" ValidationGroup="CreatePost" />
                    <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel" CssClass="btn btn-secondary" OnClick="btnCancelEdit_Click" Visible="false" />
                </asp:Panel>

                <%-- My Posts Panel (For Advertiser's own posts) --%>
                <asp:Panel ID="pnlMyPosts" runat="server" CssClass="content-section" Visible="false">
                    <div class="section-header">
                        <h2 class="section-title">
                            <i class="fas fa-list"></i>
                            My Posts
                        </h2>
                    </div>

                    <div class="search-filters">
                        <div class="search-box">
                            <i class="fas fa-search search-icon"></i>
                            <asp:TextBox ID="txtMyPostsSearch" runat="server" CssClass="search-input" placeholder="Search your posts..." AutoPostBack="true" OnTextChanged="txtMyPostsSearch_TextChanged" />
                        </div>
                        <asp:DropDownList ID="ddlMyPostsCategory" runat="server" CssClass="filter-btn" AutoPostBack="true" OnSelectedIndexChanged="ddlMyPostsCategory_SelectedIndexChanged">
                            <asp:ListItem Text="All Categories" Value="" />
                            <asp:ListItem Text="Electronics" Value="Electronics" />
                            <asp:ListItem Text="Books" Value="Books" />
                            <asp:ListItem Text="Clothing" Value="Clothing" />
                            <asp:ListItem Text="Housing" Value="Housing" />
                            <asp:ListItem Text="Services" Value="Services" />
                            <asp:ListItem Text="Vehicles" Value="Vehicles" />
                            <asp:ListItem Text="Other" Value="Other" />
                        </asp:DropDownList>
                        <asp:DropDownList ID="ddlMyPostsSortBy" runat="server" CssClass="filter-btn" AutoPostBack="true" OnSelectedIndexChanged="ddlMyPostsSortBy_SelectedIndexChanged">
                            <asp:ListItem Text="Latest First" Value="latest" />
                            <asp:ListItem Text="Oldest First" Value="oldest" />
                            <asp:ListItem Text="Most Popular" Value="popular" />
                        </asp:DropDownList>
                    </div>

                    <div class="posts-grid">
                        <asp:Repeater ID="rptMyPosts" runat="server" OnItemCommand="rptMyPosts_ItemCommand">
                            <ItemTemplate>
                                <div class="post-card fade-in">
                                    <asp:Image ID="imgMyPost" runat="server" 
                                        ImageUrl='<%# !string.IsNullOrEmpty(Eval("ImageUrl") as string) ? Eval("ImageUrl") : ResolveUrl("~/images/no-image.jpg") %>' 
                                        CssClass="post-image" 
                                        AlternateText='<%# Eval("Title") %>' />
                                    
                                    <div class="post-content">
                                        <div class="post-header">
                                            <%-- For My Posts, Advertiser info is current user --%>
                                            <asp:Image ID="imgMyAuthor" runat="server" 
                                                ImageUrl='<%# Eval("AdvertiserProfilePic") != null && !string.IsNullOrEmpty(Eval("AdvertiserProfilePic").ToString()) ? Eval("AdvertiserProfilePic") : ResolveUrl("~/images/default-avatar.png") %>' 
                                                CssClass="author-avatar" 
                                                AlternateText='<%# Eval("AdvertiserFullName") %>' />
                                            <div class="author-info">
                                                <h4><%# Eval("AdvertiserFullName") %></h4>
                                                <div class="post-date"><%# Eval("DateCreated", "{0:MMM dd, yyyy}") %></div>
                                            </div>
                                        </div>
                                        
                                        <h3 class="post-title"><%# Eval("Title") %></h3>
                                        <p class="post-description"><%# Eval("ShortDescription") %></p>
                                        <div class="post-price"><strong>R <%# Eval("Price", "{0:N2}") %></strong></div>
                                        
                                        <div class="post-actions">
                                            <asp:Button ID="btnEditPost" runat="server" 
                                                CommandName="EditPost" 
                                                CommandArgument='<%# Eval("PostId") %>' 
                                                Text="Edit" 
                                                CssClass="btn btn-primary" />
                                            <asp:Button ID="btnDeletePost" runat="server" 
                                                CommandName="DeletePost" 
                                                CommandArgument='<%# Eval("PostId") %>' 
                                                Text="Delete" 
                                                CssClass="btn btn-danger" 
                                                OnClientClick="return confirm('Are you sure you want to delete this post?');" />
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:Panel ID="pnlNoMyPostsMessage" runat="server" CssClass="no-posts-message" Visible="<%# ((Repeater)Container.NamingContainer).Items.Count == 0 %>">
                                    <p>You haven't created any posts yet.</p>
                                </asp:Panel>
                            </FooterTemplate>
                        </asp:Repeater>
                    </div>
                </asp:Panel>

                <%-- Post Details Panel --%>
                <asp:Panel ID="pnlPostDetails" runat="server" CssClass="content-section" Visible="false">
                    <div class="section-header">
                        <h2 class="section-title">
                            <i class="fas fa-info-circle"></i>
                            Post Details
                        </h2>
                    </div>

                    <div class="post-detail-card">
                        <asp:Image ID="imgDetailImage" runat="server" CssClass="detail-image" AlternateText="Post Image" ImageUrl="~/images/no-image.jpg" />
                        <h2 class="detail-title"><asp:Literal ID="litDetailTitle" runat="server" /></h2>
                        <div class="detail-price">R <asp:Literal ID="litDetailPrice" runat="server" /></div>

                        <div class="detail-meta-info">
                            <div class="detail-meta-item"><i class="fas fa-tag"></i>Category: <asp:Literal ID="litDetailCategory" runat="server" /></div>
                            <div class="detail-meta-item"><i class="fas fa-calendar-alt"></i>Posted: <asp:Literal ID="litDetailDate" runat="server" /></div>
                            <div class="detail-meta-item"><i class="fas fa-eye"></i>Views: <asp:Literal ID="litDetailViews" runat="server" /></div>
                        </div>

                        <p class="detail-description-full"><asp:Literal ID="litDetailDescription" runat="server" /></p>

                        <div class="detail-advertiser-info">
                            <asp:Image ID="imgDetailAdvertiserAvatar" runat="server" CssClass="detail-advertiser-avatar" AlternateText="Advertiser Avatar" ImageUrl="~/images/default-avatar.png" />
                            <div>
                                <div class="detail-advertiser-name"><asp:Literal ID="litDetailAdvertiserName" runat="server" /></div>
                                <div class="detail-advertiser-status">Advertiser</div>
                            </div>
                        </div>

                        <div class="post-actions">
                           <asp:Button ID="btnContactAdvertiser" runat="server" Text="Contact Advertiser" CssClass="btn btn-primary" />
                            <asp:Button ID="btnBackToAllPosts" runat="server" Text="Back to All Posts" CssClass="btn btn-secondary" OnClick="ShowAllPosts_Click" />
                        </div>
                    </div>
                </asp:Panel>

                <%-- Profile Settings Panel --%>
                <asp:Panel ID="pnlProfileSettings" runat="server" CssClass="content-section" Visible="false">
                    <div class="section-header">
                        <h2 class="section-title">
                            <i class="fas fa-user-cog"></i>
                            Profile Settings
                        </h2>
                    </div>

                    <asp:Panel ID="pnlProfileStatusMessage" runat="server" Visible="false">
                        <div class="status-success">
                            <i class="fas fa-check-circle"></i>
                            <asp:Literal ID="litProfileStatusMessage" runat="server" />
                        </div>
                    </asp:Panel>
                    <asp:ValidationSummary ID="vsProfileSettings" runat="server" ShowSummary="true" ValidationGroup="ProfileSettings" HeaderText="Please correct the following errors:" CssClass="status-error" />

                    <div class="profile-form-section">
                        <h3>Personal Information</h3>
                        <div class="form-group">
                            <asp:Label ID="lblProfileName" runat="server" Text="Full Name" CssClass="form-label" AssociatedControlID="txtProfileName" />
                            <asp:TextBox ID="txtProfileName" runat="server" CssClass="form-control" placeholder="Your full name" MaxLength="100" />
                            <asp:RequiredFieldValidator ID="rfvProfileName" runat="server"
                                ControlToValidate="txtProfileName"
                                ErrorMessage="Full Name is required."
                                CssClass="status-error"
                                Display="Dynamic"
                                ValidationGroup="ProfileSettings" />
                        </div>
                        <div class="form-group">
                            <asp:Label ID="lblProfileEmail" runat="server" Text="Email Address" CssClass="form-label" AssociatedControlID="txtProfileEmail" />
                            <asp:TextBox ID="txtProfileEmail" runat="server" CssClass="form-control" placeholder="Your email address" TextMode="Email" MaxLength="100" />
                             <asp:RequiredFieldValidator ID="rfvProfileEmail" runat="server"
                                ControlToValidate="txtProfileEmail"
                                ErrorMessage="Email is required."
                                CssClass="status-error"
                                Display="Dynamic"
                                ValidationGroup="ProfileSettings" />
                             <asp:RegularExpressionValidator ID="revProfileEmail" runat="server"
                                ControlToValidate="txtProfileEmail"
                                ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                                ErrorMessage="Please enter a valid email address."
                                CssClass="status-error"
                                Display="Dynamic"
                                ValidationGroup="ProfileSettings" />
                        </div>
                         <div class="form-group">
                            <asp:Label ID="lblProfilePhone" runat="server" Text="Phone Number" CssClass="form-label" AssociatedControlID="txtProfilePhone" />
                            <asp:TextBox ID="txtProfilePhone" runat="server" CssClass="form-control" placeholder="e.g., 0821234567" MaxLength="15" />
                            <asp:RegularExpressionValidator ID="revProfilePhone" runat="server"
                                ControlToValidate="txtProfilePhone"
                                ValidationExpression="^(\+?\d{1,3}[- ]?)?\d{10}$"
                                ErrorMessage="Please enter a valid 10-digit phone number (e.g., 0821234567)."
                                CssClass="status-error"
                                Display="Dynamic"
                                ValidationGroup="ProfileSettings" />
                        </div>
                        <div class="form-group">
                            <asp:Label ID="lblProfilePicUpload" runat="server" Text="Update Profile Picture" CssClass="form-label" AssociatedControlID="fuProfilePic" />
                            <div class="profile-avatar-upload">
                                <asp:Image ID="imgCurrentProfilePic" runat="server" ImageUrl="~/images/default-avatar.png" CssClass="profile-avatar-display" />
                                <asp:FileUpload ID="fuProfilePic" runat="server" CssClass="form-control file-upload" />
                                <asp:RegularExpressionValidator ID="revProfilePic" runat="server"
                                    ControlToValidate="fuProfilePic"
                                    ValidationExpression="^.*\.(jpg|jpeg|png|gif|bmp)$"
                                    ErrorMessage="Only image files (jpg, jpeg, png, gif, bmp) are allowed."
                                    CssClass="status-error"
                                    Display="Dynamic"
                                    ValidationGroup="ProfileSettings" />
                            </div>
                        </div>
                         <asp:Button ID="btnUpdateProfile" runat="server" Text="Update Personal Info" CssClass="btn btn-primary" OnClick="btnUpdateProfile_Click" ValidationGroup="ProfileSettings" />
                    </div>

                    <div class="profile-form-section">
                        <h3>Change Password</h3>
                        <div class="profile-password-info">
                            <i class="fas fa-info-circle"></i>
                            Leave password fields blank if you do not wish to change your password.
                        </div>

                        <div class="form-group">
                            <asp:Label ID="lblOldPassword" runat="server" Text="Old Password" CssClass="form-label" AssociatedControlID="txtProfileOldPassword" />
                            <asp:TextBox ID="txtProfileOldPassword" runat="server" CssClass="form-control" TextMode="Password" />
                            <asp:CustomValidator ID="cvOldPasswordRequired" runat="server"
                                ControlToValidate="txtProfileOldPassword"
                                ErrorMessage="Old password is required if changing password."
                                OnServerValidate="cvOldPasswordRequired_ServerValidate"
                                CssClass="status-error"
                                Display="Dynamic"
                                ValidationGroup="ProfileSettings" />
                        </div>

                        <div class="form-group">
                            <asp:Label ID="lblNewPassword" runat="server" Text="New Password" CssClass="form-label" AssociatedControlID="txtProfileNewPassword" />
                            <asp:TextBox ID="txtProfileNewPassword" runat="server" CssClass="form-control" TextMode="Password" />
                            <asp:RegularExpressionValidator ID="revNewPassword" runat="server" 
                                ControlToValidate="txtProfileNewPassword" 
                                ValidationExpression="^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$" 
                                ErrorMessage="Password must be at least 8 characters, include an uppercase, lowercase, number, and special character." 
                                CssClass="status-error" 
                                Display="Dynamic" 
                                ValidationGroup="ProfileSettings" />
                            <asp:CustomValidator ID="cvNewPasswordRequired" runat="server"
                                ControlToValidate="txtProfileNewPassword"
                                ErrorMessage="New password is required if old password is entered."
                                OnServerValidate="cvNewPasswordRequired_ServerValidate"
                                CssClass="status-error"
                                Display="Dynamic"
                                ValidationGroup="ProfileSettings" />
                        </div>

                        <div class="form-group">
                            <asp:Label ID="lblConfirmPassword" runat="server" Text="Confirm New Password" CssClass="form-label" AssociatedControlID="txtProfileConfirmPassword" />
                            <asp:TextBox ID="txtProfileConfirmPassword" runat="server" CssClass="form-control" TextMode="Password" />
                            <asp:CompareValidator ID="cvConfirmPassword" runat="server" 
                                ControlToValidate="txtProfileConfirmPassword" 
                                ControlToCompare="txtProfileNewPassword" 
                                ErrorMessage="New passwords do not match." 
                                CssClass="status-error" 
                                Display="Dynamic" 
                                ValidationGroup="ProfileSettings" />
                            <asp:CustomValidator ID="cvConfirmPasswordRequired" runat="server"
                                ControlToValidate="txtProfileConfirmPassword"
                                ErrorMessage="Confirm password is required if new password is entered."
                                OnServerValidate="cvConfirmPasswordRequired_ServerValidate"
                                CssClass="status-error"
                                Display="Dynamic"
                                ValidationGroup="ProfileSettings" />
                        </div>

                        <div class="form-group">
                            <asp:Button ID="btnUpdatePassword" runat="server" Text="Update Password" CssClass="btn btn-primary" ValidationGroup="ProfileSettings" OnClick="btnUpdatePassword_Click" />
                        </div>
                    </div>
                </asp:Panel>

            </main>
        </div>
    </form>
</body>
</html>