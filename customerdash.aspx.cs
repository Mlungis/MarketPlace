using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MarketPlace
{
    public partial class customerdash : System.Web.UI.Page
    {
        // List to store posts - will be populated from database
        private static List<Post> _allPosts = new List<Post>();
        private static int _currentPostId = -1; // To store the ID of the currently viewed detailed post
        private static string _currentSellerName = string.Empty; // To store the seller name for profile view

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Set the culture for the page to en-US for consistent decimal handling
                System.Threading.Thread.CurrentThread.CurrentCulture = new System.Globalization.CultureInfo("en-US");
                System.Threading.Thread.CurrentThread.CurrentUICulture = new System.Globalization.CultureInfo("en-US");

                LoadUserData(); // Load user-specific data and stats
                ShowPanel(pnlAllPosts); // Default view is "All Posts"
                SetActiveNavLink(lnkAllPosts); // Set the active navigation link
            }
        }

        // --- Panel Visibility Management ---
        private void ShowPanel(Panel panelToShow)
        {
            // Hide all main content panels
            pnlAllPosts.Visible = false;
            pnlProfileSettings.Visible = false;
            pnlPostDetails.Visible = false;
            pnlSellerProfile.Visible = false;

            // Show the requested panel
            panelToShow.Visible = true;

            // Hide all status messages when switching panels to ensure they don't persist
            pnlProfileStatusMessage.Visible = false;
        }

        private void SetActiveNavLink(LinkButton activeLink)
        {
            // Reset CSS class for all navigation links
            lnkAllPosts.CssClass = "nav-link";
            lnkProfile.CssClass = "nav-link";
            lnkChangeTheme.CssClass = "nav-link";

            // Add 'active' class to the clicked link
            activeLink.CssClass += " active";
        }

        // --- Navigation Button Click Handlers ---
        protected void ShowAllPosts_Click(object sender, EventArgs e)
        {
            ShowPanel(pnlAllPosts);
            SetActiveNavLink(lnkAllPosts);
            BindAllPosts(); // Re-bind data when showing this panel to reflect any changes
        }

        protected void ShowProfile_Click(object sender, EventArgs e)
        {
            ShowPanel(pnlProfileSettings);
            SetActiveNavLink(lnkProfile);
            LoadProfileData(); // Load current user's profile data for editing
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Abandon(); // Clears all session data for the current user
            Response.Redirect("Login.aspx"); // Redirect to your login page
        }

        // --- Data Loading and Binding ---
        private void LoadUserData()
        {
            // TODO: Fetch the logged-in user's data from your database
            // For now, using default values
            litUserName.Text = "Customer User";
            imgProfilePic.ImageUrl = "~/images/default-avatar.png";

            // TODO: Update user stats from database
            litTotalPurchases.Text = "0";
            litItemsSaved.Text = "0";

            BindAllPosts(); // Initial bind of all posts
        }

        private void BindAllPosts()
        {
            var filteredPosts = _allPosts.AsEnumerable(); // Start with all posts

            // Apply search filter if text is entered
            if (!string.IsNullOrWhiteSpace(txtSearch.Text))
            {
                string searchTerm = txtSearch.Text.ToLower();
                filteredPosts = filteredPosts.Where(p =>
                    p.Title.ToLower().Contains(searchTerm) ||
                    p.Description.ToLower().Contains(searchTerm) ||
                    p.AdvertiserName.ToLower().Contains(searchTerm));
            }

            // Apply category filter if a category is selected
            if (!string.IsNullOrEmpty(ddlCategory.SelectedValue))
            {
                filteredPosts = filteredPosts.Where(p => p.Category == ddlCategory.SelectedValue);
            }

            // Apply sorting based on selected option
            switch (ddlSortBy.SelectedValue)
            {
                case "latest":
                    filteredPosts = filteredPosts.OrderByDescending(p => p.DateCreated);
                    break;
                case "oldest":
                    filteredPosts = filteredPosts.OrderBy(p => p.DateCreated);
                    break;
                case "popular":
                    filteredPosts = filteredPosts.OrderByDescending(p => p.Views);
                    break;
                default:
                    filteredPosts = filteredPosts.OrderByDescending(p => p.DateCreated);
                    break;
            }

            rptAllPosts.DataSource = filteredPosts.ToList();
            rptAllPosts.DataBind();

            lblNoPosts.Visible = !filteredPosts.Any();
        }

        private void LoadProfileData()
        {
            // TODO: Fetch the actual user details from your database
            txtFullName.Text = litUserName.Text;
            txtEmail.Text = ""; // Load from database
            txtPhoneNumber.Text = ""; // Load from database
            imgProfilePreview.ImageUrl = imgProfilePic.ImageUrl;
        }

        // Method to load a single post's details into the pnlPostDetails
        private void LoadPostDetails(int postId)
        {
            var post = _allPosts.FirstOrDefault(p => p.PostId == postId);
            if (post != null)
            {
                _currentPostId = postId;
                _currentSellerName = post.AdvertiserName;

                imgDetailImage.ImageUrl = !string.IsNullOrEmpty(post.ImageUrl) ? post.ImageUrl : "~/images/no-image.jpg";
                litDetailTitle.Text = post.Title;
                litDetailPrice.Text = post.Price.ToString("N2");
                litDetailDescription.Text = post.Description;
                litDetailAdvertiserName.Text = post.AdvertiserName;
                imgDetailAdvertiserAvatar.ImageUrl = post.AdvertiserProfilePic;
                litDetailDate.Text = post.DateCreated.ToString("MMM dd, yyyy");
                litDetailCategory.Text = post.Category;

                // Increment views for the specific post
                post.Views++;
            }
        }

        // Method to load a seller's profile details into the pnlSellerProfile
        private void LoadSellerProfile(string sellerName)
        {
            var sellerPost = _allPosts.FirstOrDefault(p => p.AdvertiserName == sellerName);

            if (sellerPost != null)
            {
                litSellerName.Text = sellerName;
                imgSellerProfileAvatar.ImageUrl = sellerPost.AdvertiserProfilePic;
                litSellerEmail.Text = sellerPost.AdvertiserEmail;
                litSellerPhone.Text = sellerPost.AdvertiserPhone;
            }
            else
            {
                litSellerName.Text = sellerName;
                imgSellerProfileAvatar.ImageUrl = "~/images/default-avatar.png";
                litSellerEmail.Text = "N/A";
                litSellerPhone.Text = "N/A";
            }
        }

        // --- Event Handlers for Filters and Actions ---
        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            BindAllPosts();
        }

        protected void ddlCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindAllPosts();
        }

        protected void ddlSortBy_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindAllPosts();
        }

        protected void rptAllPosts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "ViewDetails")
            {
                int postId = Convert.ToInt32(e.CommandArgument);
                LoadPostDetails(postId);
                ShowPanel(pnlPostDetails);
            }
        }

        protected void btnUpdateProfile_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                try
                {
                    litUserName.Text = txtFullName.Text;

                    // Handle profile picture upload
                    if (fuProfileImage.HasFile)
                    {
                        string uploadDir = Server.MapPath("~/uploads/profiles/");
                        if (!System.IO.Directory.Exists(uploadDir))
                        {
                            System.IO.Directory.CreateDirectory(uploadDir);
                        }

                        string fileName = Guid.NewGuid().ToString() + System.IO.Path.GetExtension(fuProfileImage.FileName);
                        string filePath = System.IO.Path.Combine(uploadDir, fileName);
                        fuProfileImage.SaveAs(filePath);
                        imgProfilePic.ImageUrl = "~/uploads/profiles/" + fileName;
                        imgProfilePreview.ImageUrl = imgProfilePic.ImageUrl;
                    }

                    // TODO: Update user profile in database

                    ShowProfileStatusMessage("Profile updated successfully!", true);
                }
                catch (Exception ex)
                {
                    ShowProfileStatusMessage("Error updating profile: " + ex.Message, false);
                }
            }
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                // TODO: Implement actual password validation against database
                // TODO: Hash and update password in database

                ShowProfileStatusMessage("Password changed successfully!", true);
                txtCurrentPassword.Text = string.Empty;
                txtNewPassword.Text = string.Empty;
                txtConfirmNewPassword.Text = string.Empty;
            }
        }

        // View Seller Profile button from Post Details view
        protected void lnkViewSellerProfile_Click(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(_currentSellerName))
            {
                LoadSellerProfile(_currentSellerName);
                ShowPanel(pnlSellerProfile);
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "sellerNotFound", $"alert('Error: Seller information not available for this post.');", true);
            }
        }

        // Contact Advertiser button from Post Details view
        protected void btnContactAdvertiser_Click(object sender, EventArgs e)
        {
            // TODO: Implement messaging interface or contact form
            ScriptManager.RegisterStartupScript(this, GetType(), "contactAdvertiser", $"alert('Contact functionality would be implemented here.');", true);
        }

        // Back from Seller Profile to Post Details
        protected void btnBackFromSellerProfile_Click(object sender, EventArgs e)
        {
            if (_currentPostId > 0)
            {
                LoadPostDetails(_currentPostId);
                ShowPanel(pnlPostDetails);
            }
            else
            {
                ShowPanel(pnlAllPosts);
                SetActiveNavLink(lnkAllPosts);
                BindAllPosts();
            }
        }

        // --- Status Message Helper (for Profile Settings) ---
        private void ShowProfileStatusMessage(string message, bool isSuccess)
        {
            pnlProfileStatusMessage.Visible = true;
            litProfileStatusMessage.Text = message;
            pnlProfileStatusMessage.CssClass = isSuccess ? "status-message status-success" : "status-message status-error";
        }

        // --- Helper Classes for Data Structure ---
        public class Post
        {
            public int PostId { get; set; }
            public string Title { get; set; }
            public string Description { get; set; }
            public string ShortDescription { get; set; }
            public double Price { get; set; }
            public string ImageUrl { get; set; }
            public string AdvertiserName { get; set; }
            public string AdvertiserProfilePic { get; set; }
            public DateTime DateCreated { get; set; }
            public int Views { get; set; }
            public string Category { get; set; }
            public string Condition { get; set; }
            public string AdvertiserEmail { get; set; }
            public string AdvertiserPhone { get; set; }
        }
    }
}