using BCrypt.Net; // For password hashing/verification (make sure you have this NuGet package installed)
using Newtonsoft.Json; // For JSON deserialization
using System;
using System.Collections.Generic;
using System.IO; // For file operations
using System.Linq;
using System.Net.Http; // For Firebase API calls
using System.Threading.Tasks; // For async operations
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls; // Required for HtmlGenericControl
using System.Web.UI.WebControls;

namespace MarketPlace
{
    public partial class AdvertiserDash : System.Web.UI.Page
    {
        // Model for a Post as stored in your application (Frontend representation)
        public class Post
        {
            // IMPORTANT: For Firebase, we'll use the Firebase generated key as the PostId.
            // This 'PostId' here will serve as a local identifier once fetched.
            public string PostFirebaseId { get; set; } // The actual Firebase key (e.g., "-MsxY..._")
            public string Title { get; set; }
            public string Description { get; set; }
            public string ShortDescription
            {
                get
                {
                    return Description != null && Description.Length > 100 ?
                                             Description.Substring(0, 97) + "..." : Description;
                }
            }
            public decimal Price { get; set; }
            public string Category { get; set; }
            public string ImageUrl { get; set; }
            public DateTime DateCreated { get; set; }
            public int Views { get; set; }
            public string AdvertiserId { get; set; } // Firebase User ID of the advertiser
            public string AdvertiserFullName { get; set; }
            public string AdvertiserProfilePic { get; set; }
            public string AdvertiserEmail { get; set; }
            public string AdvertiserPhone { get; set; }
        }

        // Model for an Advertiser (User) profile as used in your application
        public class Advertiser
        {
            public string AdvertiserId { get; set; } // Firebase User ID
            public string FullName { get; set; }
            public string Email { get; set; }
            public string Phone { get; set; }
            public string ProfilePictureUrl { get; set; }
            public string PasswordHash { get; set; }
            public string BusinessName { get; set; }
            public string Plan { get; set; }
        }

        // Firebase-specific model for deserializing User data from Firebase Realtime DB
        // Corresponds to the structure under /Users/{userId}
        private class FirebaseUser
        {
            public string FullName { get; set; }
            public string Email { get; set; }
            public string Phone { get; set; }
            [JsonProperty("Password")] // Map "Password" in Firebase to PasswordHash
            public string PasswordHash { get; set; }
            public string Role { get; set; }
            public string ProfilePictureUrl { get; set; }
        }

        // Firebase-specific model for deserializing Business data from Firebase Realtime DB
        // Corresponds to the structure under /Businesses/{businessKey}
        private class FirebaseBusiness
        {
            public string UserId { get; set; }
            public string BusinessName { get; set; }
            public string Plan { get; set; }
            public string ContactEmail { get; set; }
            public string ContactPhone { get; set; }
        }

        // Firebase-specific model for deserializing Post data from Firebase Realtime DB
        // Corresponds to the structure under /Posts/{postKey}
        private class FirebasePost
        {
            public string Title { get; set; }
            public string Description { get; set; }
            public decimal Price { get; set; }
            public string Category { get; set; }
            public string ImageUrl { get; set; }
            public string DateCreated { get; set; } // Store as string for Firebase, convert to DateTime in C#
            public int Views { get; set; }
            public string AdvertiserId { get; set; }
            public string AdvertiserFullName { get; set; }
            public string AdvertiserProfilePic { get; set; }
            public string AdvertiserEmail { get; set; }
            public string AdvertiserPhone { get; set; }
        }

        // _currentAdvertiser holds the profile data of the logged-in user
        private Advertiser _currentAdvertiser;

        private static readonly HttpClient _httpClient = new HttpClient();
        private const string FirebaseBaseUrl = "https://zeromarket-ddd36-default-rtdb.firebaseio.com/";

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["AdvertiserId"] == null)
                {
                    Response.Redirect("Login.aspx", false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }
                else
                {
                    string advertiserId = Session["AdvertiserId"].ToString();

                    // Attempt to load current advertiser's detailed data from Firebase
                    _currentAdvertiser = await GetAdvertiserByIdFromFirebase(advertiserId);

                    if (_currentAdvertiser == null)
                    {
                        Session.Clear();
                        Response.Redirect("Login.aspx?error=" + Server.UrlEncode("Your session is invalid or advertiser data not found."), false);
                        Context.ApplicationInstance.CompleteRequest();
                        return;
                    }

                    // Initial setup of the dashboard view
                    ShowPanel("pnlQuickActions"); // Default view - using string instead of Panel object
                    await BindAllPostsGrid(); // Fetch and bind all posts from DB
                    UpdateProfileInfo(); // Update sidebar profile
                    await UpdateStats(); // Update sidebar stats
                }
            }
        }

        // --- Firebase Data Retrieval Methods ---
        protected void rptAllPosts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            // This method will be called when a command is fired from within the Repeater.
            // You'll typically use e.CommandName and e.CommandArgument here.

            switch (e.CommandName)
            {
                case "ViewDetails": // Example command name for viewing details
                                    // Assuming CommandArgument holds the PostID
                    int postIdToView = Convert.ToInt32(e.CommandArgument);
                    // Perform action to view details of the post with postIdToView
                    Response.Redirect($"PostDetails.aspx?ID={postIdToView}");
                    break;

                case "EditPost": // Example command name for editing a post
                    int postIdToEdit = Convert.ToInt32(e.CommandArgument);
                    // Perform action to edit the post
                    Response.Redirect($"EditPost.aspx?ID={postIdToEdit}");
                    break;

                // Add more cases for other commands as needed (e.g., "DeletePost", "MarkSold")
                default:
                    // Handle unknown commands or do nothing
                    break;
            }
        }

        protected async void txtMyPostsSearch_TextChanged(object sender, EventArgs e)
        {
            // This method will be called when the text in txtMyPostsSearch changes and AutoPostBack is true.
            // You should re-bind your "My Posts" Repeater or GridView here based on the new search text.
            await BindMyPostsGrid(); // Assuming you have a method to bind "My Posts"
        }
        protected void cvImageRequired_ServerValidate(object source, ServerValidateEventArgs args)
        {
            // This method is called when the CustomValidator performs server-side validation.
            // 'args.IsValid' should be set to true if validation passes, false otherwise.

            // Check if the FileUpload control has a file selected.
            // Assuming fuImage is the ID of your FileUpload control.
            if (fuImage.HasFile)
            {
                args.IsValid = true; // Image is provided, validation passes
            }
            else
            {
                args.IsValid = false; // No image selected, validation fails
            }
        }


        private async Task<Advertiser> GetAdvertiserByIdFromFirebase(string userId)
        {
            try
            {
                // 1. Fetch user (Advertiser) details from "Users" collection
                string userUrl = $"{FirebaseBaseUrl}Users/{Uri.EscapeDataString(userId)}.json";
                var userResponse = await _httpClient.GetAsync(userUrl);

                if (!userResponse.IsSuccessStatusCode)
                {
                    System.Diagnostics.Trace.TraceWarning($"Firebase user fetch failed for ID '{userId}' with status: {userResponse.StatusCode}");
                    return null;
                }
                var userJson = await userResponse.Content.ReadAsStringAsync();
                var firebaseUser = JsonConvert.DeserializeObject<FirebaseUser>(userJson);

                if (firebaseUser == null) return null;

                // 2. Fetch business details from "Businesses" collection using UserId
                string businessUrl = $"{FirebaseBaseUrl}Businesses.json?orderBy=\"UserId\"&equalTo=\"{Uri.EscapeDataString(userId)}\"";
                var businessResponse = await _httpClient.GetAsync(businessUrl);

                FirebaseBusiness firebaseBusiness = null;
                if (businessResponse.IsSuccessStatusCode)
                {
                    var businessJson = await businessResponse.Content.ReadAsStringAsync();
                    var businessesDict = JsonConvert.DeserializeObject<Dictionary<string, FirebaseBusiness>>(businessJson);
                    firebaseBusiness = businessesDict?.Values.FirstOrDefault();
                }
                else
                {
                    System.Diagnostics.Trace.TraceWarning($"Firebase business fetch failed for UserId '{userId}' with status: {businessResponse.StatusCode}. Proceeding without business data.");
                }

                // Construct the Advertiser model from fetched data
                var advertiser = new Advertiser
                {
                    AdvertiserId = userId,
                    FullName = firebaseUser.FullName,
                    Email = firebaseUser.Email,
                    Phone = firebaseUser.Phone,
                    ProfilePictureUrl = firebaseUser.ProfilePictureUrl,
                    PasswordHash = firebaseUser.PasswordHash
                };

                // Add business specific data if available
                if (firebaseBusiness != null)
                {
                    advertiser.BusinessName = firebaseBusiness.BusinessName;
                    advertiser.Plan = firebaseBusiness.Plan;
                    // You might choose to override contact info from business if it's primary
                    if (!string.IsNullOrEmpty(firebaseBusiness.ContactEmail)) advertiser.Email = firebaseBusiness.ContactEmail;
                    if (!string.IsNullOrEmpty(firebaseBusiness.ContactPhone)) advertiser.Phone = firebaseBusiness.ContactPhone;
                }
                else
                {
                    advertiser.BusinessName = "N/A";
                    advertiser.Plan = "None";
                }

                return advertiser;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error fetching advertiser data from Firebase for ID '{userId}': {ex.Message}");
                return null;
            }
        }

        private async Task<List<Post>> GetAllPostsFromFirebase()
        {
            try
            {
                string postsUrl = $"{FirebaseBaseUrl}Posts.json";
                var response = await _httpClient.GetAsync(postsUrl);

                if (!response.IsSuccessStatusCode)
                {
                    System.Diagnostics.Trace.TraceError($"Failed to fetch posts from Firebase: {response.StatusCode}");
                    return new List<Post>();
                }

                var json = await response.Content.ReadAsStringAsync();
                if (string.IsNullOrEmpty(json) || json == "null")
                {
                    return new List<Post>();
                }

                // Firebase returns a dictionary where keys are the unique IDs
                var firebasePostsDict = JsonConvert.DeserializeObject<Dictionary<string, FirebasePost>>(json);

                if (firebasePostsDict == null) return new List<Post>();

                List<Post> posts = new List<Post>();
                foreach (var entry in firebasePostsDict)
                {
                    FirebasePost fbPost = entry.Value;
                    posts.Add(new Post
                    {
                        PostFirebaseId = entry.Key, // Store the Firebase generated key
                        Title = fbPost.Title,
                        Description = fbPost.Description,
                        Price = fbPost.Price,
                        Category = fbPost.Category,
                        ImageUrl = fbPost.ImageUrl,
                        DateCreated = DateTime.Parse(fbPost.DateCreated), // Convert string to DateTime
                        Views = fbPost.Views,
                        AdvertiserId = fbPost.AdvertiserId,
                        AdvertiserFullName = fbPost.AdvertiserFullName,
                        AdvertiserProfilePic = fbPost.AdvertiserProfilePic,
                        AdvertiserEmail = fbPost.AdvertiserEmail,
                        AdvertiserPhone = fbPost.AdvertiserPhone
                    });
                }
                return posts;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error fetching all posts from Firebase: {ex.Message}");
                return new List<Post>();
            }
        }

        private async Task SaveNewPostToFirebase(Post post)
        {
            try
            {
                string postsUrl = $"{FirebaseBaseUrl}Posts.json";
                var firebasePost = new FirebasePost
                {
                    Title = post.Title,
                    Description = post.Description,
                    Price = post.Price,
                    Category = post.Category,
                    ImageUrl = post.ImageUrl,
                    DateCreated = post.DateCreated.ToString("o"), // "o" for round-trip format
                    Views = post.Views,
                    AdvertiserId = post.AdvertiserId,
                    AdvertiserFullName = post.AdvertiserFullName,
                    AdvertiserProfilePic = post.AdvertiserProfilePic,
                    AdvertiserEmail = post.AdvertiserEmail,
                    AdvertiserPhone = post.AdvertiserPhone
                };
                var content = new StringContent(JsonConvert.SerializeObject(firebasePost), System.Text.Encoding.UTF8, "application/json");

                var response = await _httpClient.PostAsync(postsUrl, content);

                if (!response.IsSuccessStatusCode)
                {
                    string errorContent = await response.Content.ReadAsStringAsync();
                    throw new Exception($"Failed to save post to Firebase: {response.StatusCode} - {errorContent}");
                }
                // Optionally, retrieve the Firebase key from the response if needed for local tracking
                // var responseData = JsonConvert.DeserializeObject<Dictionary<string, string>>(await response.Content.ReadAsStringAsync());
                // post.PostFirebaseId = responseData["name"];
            }
            catch (Exception ex)
            {
                throw new Exception($"Error saving post to Firebase: {ex.Message}", ex);
            }
        }

        private async Task UpdatePostInFirebase(Post post)
        {
            if (string.IsNullOrEmpty(post.PostFirebaseId))
            {
                throw new ArgumentException("Cannot update post without a valid Firebase ID.", nameof(post.PostFirebaseId));
            }

            try
            {
                string postUrl = $"{FirebaseBaseUrl}Posts/{Uri.EscapeDataString(post.PostFirebaseId)}.json";
                var firebasePost = new FirebasePost
                {
                    Title = post.Title,
                    Description = post.Description,
                    Price = post.Price,
                    Category = post.Category,
                    ImageUrl = post.ImageUrl,
                    DateCreated = post.DateCreated.ToString("o"),
                    Views = post.Views,
                    AdvertiserId = post.AdvertiserId,
                    AdvertiserFullName = post.AdvertiserFullName,
                    AdvertiserProfilePic = post.AdvertiserProfilePic,
                    AdvertiserEmail = post.AdvertiserEmail,
                    AdvertiserPhone = post.AdvertiserPhone
                };
                var content = new StringContent(JsonConvert.SerializeObject(firebasePost), System.Text.Encoding.UTF8, "application/json");

                var request = new HttpRequestMessage(new HttpMethod("PATCH"), postUrl)
                {
                    Content = content
                };
                var response = await _httpClient.SendAsync(request);

                if (!response.IsSuccessStatusCode)
                {
                    string errorContent = await response.Content.ReadAsStringAsync();
                    throw new Exception($"Failed to update post in Firebase: {response.StatusCode} - {errorContent}");
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error updating post in Firebase: {ex.Message}", ex);
            }
        }

        private async Task DeletePostFromFirebase(string postFirebaseId)
        {
            if (string.IsNullOrEmpty(postFirebaseId))
            {
                throw new ArgumentException("Cannot delete post without a valid Firebase ID.", nameof(postFirebaseId));
            }

            try
            {
                string postUrl = $"{FirebaseBaseUrl}Posts/{Uri.EscapeDataString(postFirebaseId)}.json";
                var response = await _httpClient.DeleteAsync(postUrl);

                if (!response.IsSuccessStatusCode)
                {
                    string errorContent = await response.Content.ReadAsStringAsync();
                    throw new Exception($"Failed to delete post from Firebase: {response.StatusCode} - {errorContent}");
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error deleting post from Firebase: {ex.Message}", ex);
            }
        }

        private void HideAllPanels()
        {
            // Safe panel hiding with null checks
            SafeSetPanelVisible("pnlQuickActions", false);
            SafeSetPanelVisible("pnlAllPosts", false);
            SafeSetPanelVisible("pnlCreatePost", false);
            SafeSetPanelVisible("pnlMyPosts", false);
            SafeSetPanelVisible("pnlPostDetails", false);
            SafeSetPanelVisible("pnlProfileSettings", false);

            // Clear status messages when switching panels
            SafeSetPanelVisible("pnlCreatePostStatusMessage", false);
            SafeSetLiteralText("litCreatePostStatusMessage", string.Empty);
            SafeSetPanelVisible("pnlProfileStatusMessage", false);
            SafeSetLiteralText("litProfileStatusMessage", string.Empty);

            // Reset validation summaries
            SafeSetControlVisible("vsCreatePost", false);
            SafeSetControlVisible("vsProfileSettings", false);
        }

        private void ShowPanel(string panelId)
        {
            HideAllPanels();
            SafeSetPanelVisible(panelId, true);
            SetActiveNavLink(panelId);
        }

        // Helper method to safely set panel visibility
        private void SafeSetPanelVisible(string panelId, bool visible)
        {
            Panel panel = FindControl(panelId) as Panel;
            if (panel != null)
            {
                panel.Visible = visible;
            }
        }

        // Helper method to safely set control visibility
        private void SafeSetControlVisible(string controlId, bool visible)
        {
            Control control = FindControl(controlId);
            if (control != null)
            {
                control.Visible = visible;
            }
        }

        // Helper method to safely set literal text
        private void SafeSetLiteralText(string literalId, string text)
        {
            Literal literal = FindControl(literalId) as Literal;
            if (literal != null)
            {
                literal.Text = text;
            }
        }

        private void SetActiveNavLink(string activePanelId)
        {
            // Safe navigation link setting with null checks
            LinkButton lnkAllPosts = FindControl("lnkAllPosts") as LinkButton;
            LinkButton lnkCreatePost = FindControl("lnkCreatePost") as LinkButton;
            LinkButton lnkMyPosts = FindControl("lnkMyPosts") as LinkButton;
            LinkButton lnkProfile = FindControl("lnkProfile") as LinkButton;

            if (lnkAllPosts != null) lnkAllPosts.CssClass = "nav-link";
            if (lnkCreatePost != null) lnkCreatePost.CssClass = "nav-link";
            if (lnkMyPosts != null) lnkMyPosts.CssClass = "nav-link";
            if (lnkProfile != null) lnkProfile.CssClass = "nav-link";

            switch (activePanelId)
            {
                case "pnlAllPosts":
                    if (lnkAllPosts != null) lnkAllPosts.CssClass += " active";
                    break;
                case "pnlCreatePost":
                    if (lnkCreatePost != null) lnkCreatePost.CssClass += " active";
                    break;
                case "pnlMyPosts":
                    if (lnkMyPosts != null) lnkMyPosts.CssClass += " active";
                    break;
                case "pnlProfileSettings":
                    if (lnkProfile != null) lnkProfile.CssClass += " active";
                    break;
                default:
                    if (lnkAllPosts != null) lnkAllPosts.CssClass += " active";
                    break;
            }
        }

        // --- Sidebar Navigation Clicks ---
        protected async void ShowAllPosts_Click(object sender, EventArgs e)
        {
            ShowPanel("pnlAllPosts");
            await BindAllPostsGrid(); // Fetch and rebind data
            SafeSetTextBoxText("txtSearch", string.Empty);
            SafeSetDropDownValue("ddlCategory", "");
            SafeSetDropDownValue("ddlSortBy", "latest");
        }

        protected void ShowCreatePost_Click(object sender, EventArgs e)
        {
            ShowPanel("pnlCreatePost");
            ClearCreatePostForm();
            SafeSetButtonText("btnSubmitPost", "Create Post");
            SafeSetControlVisible("btnCancelEdit", false);
            SafeSetHiddenFieldValue("hdnPostId", string.Empty); // This will now store FirebasePostId for editing
        }

        protected async void ShowMyPosts_Click(object sender, EventArgs e)
        {
            ShowPanel("pnlMyPosts");
            await BindMyPostsGrid(); // Fetch and rebind data
            SafeSetTextBoxText("txtMyPostsSearch", string.Empty);
            SafeSetDropDownValue("ddlMyPostsCategory", "");
            SafeSetDropDownValue("ddlMyPostsSortBy", "latest");
        }

        protected void ShowProfile_Click(object sender, EventArgs e)
        {
            ShowPanel("pnlProfileSettings");
            LoadProfileSettings();
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        // Helper methods for safe control manipulation
        private void SafeSetTextBoxText(string textBoxId, string text)
        {
            TextBox textBox = FindControl(textBoxId) as TextBox;
            if (textBox != null)
            {
                textBox.Text = text;
            }
        }

        private void SafeSetDropDownValue(string dropDownId, string value)
        {
            DropDownList dropDown = FindControl(dropDownId) as DropDownList;
            if (dropDown != null)
            {
                // Ensure the value exists in the dropdown list to avoid errors
                if (dropDown.Items.FindByValue(value) != null)
                {
                    dropDown.SelectedValue = value;
                }
                else
                {
                    // Optionally, log a warning or set a default value
                    System.Diagnostics.Trace.TraceWarning($"Dropdown '{dropDownId}' does not contain value '{value}'.");
                }
            }
        }

        private void SafeSetButtonText(string buttonId, string text)
        {
            Button button = FindControl(buttonId) as Button;
            if (button != null)
            {
                button.Text = text;
            }
        }

        private void SafeSetHiddenFieldValue(string hiddenFieldId, string value)
        {
            HiddenField hiddenField = FindControl(hiddenFieldId) as HiddenField;
            if (hiddenField != null)
            {
                hiddenField.Value = value;
            }
        }

        // --- Profile Section Logic ---
        private void UpdateProfileInfo()
        {
            if (_currentAdvertiser != null)
            {
                SafeSetLiteralText("litUserName", _currentAdvertiser.FullName);

                Image imgProfilePic = FindControl("imgProfilePic") as Image;
                if (imgProfilePic != null)
                {
                    imgProfilePic.ImageUrl = string.IsNullOrEmpty(_currentAdvertiser.ProfilePictureUrl) ?
                        ResolveUrl("~/images/default-avatar.png") : _currentAdvertiser.ProfilePictureUrl;
                }
            }
        }

        private async Task UpdateStats()
        {
            if (_currentAdvertiser != null)
            {
                List<Post> allPosts = await GetAllPostsFromFirebase(); // Re-fetch all posts to get current stats
                List<Post> myPosts = allPosts.Where(p => p.AdvertiserId == _currentAdvertiser.AdvertiserId).ToList();

                SafeSetLiteralText("litTotalPosts", myPosts.Count.ToString());
                SafeSetLiteralText("litTotalViews", myPosts.Sum(p => p.Views).ToString());
            }
            else
            {
                SafeSetLiteralText("litTotalPosts", "0");
                SafeSetLiteralText("litTotalViews", "0");
            }
        }

        private void LoadProfileSettings()
        {
            if (_currentAdvertiser != null)
            {
                SafeSetTextBoxText("txtProfileName", _currentAdvertiser.FullName);
                SafeSetTextBoxText("txtProfileEmail", _currentAdvertiser.Email);
                SafeSetTextBoxText("txtProfilePhone", _currentAdvertiser.Phone);

                // Fetch profile picture directly from _currentAdvertiser which was loaded from DB
                Image imgCurrentProfilePic = FindControl("imgCurrentProfilePic") as Image;
                if (imgCurrentProfilePic != null)
                {
                    imgCurrentProfilePic.ImageUrl = string.IsNullOrEmpty(_currentAdvertiser.ProfilePictureUrl) ?
                        ResolveUrl("~/images/default-avatar.png") : _currentAdvertiser.ProfilePictureUrl;
                }

                SafeSetTextBoxText("txtProfileOldPassword", string.Empty);
                SafeSetTextBoxText("txtProfileNewPassword", string.Empty);
                SafeSetTextBoxText("txtProfileConfirmPassword", string.Empty);
                SafeSetPanelVisible("pnlProfileStatusMessage", false);
            }
        }

        protected async void btnUpdateProfile_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                try
                {
                    if (_currentAdvertiser == null)
                    {
                        SetProfileStatusMessage(false, "Error: User data not loaded. Please log in again.");
                        System.Diagnostics.Trace.TraceError("btnUpdateProfile_Click: _currentAdvertiser was null.");
                        return;
                    }

                    // Get values safely
                    TextBox txtProfileName = FindControl("txtProfileName") as TextBox;
                    TextBox txtProfileEmail = FindControl("txtProfileEmail") as TextBox;
                    TextBox txtProfilePhone = FindControl("txtProfilePhone") as TextBox;
                    FileUpload fuProfilePic = FindControl("fuProfilePic") as FileUpload;

                    if (txtProfileName == null || txtProfileEmail == null || txtProfilePhone == null)
                    {
                        SetProfileStatusMessage(false, "Error: Required form controls not found.");
                        return;
                    }

                    // Update local object first
                    _currentAdvertiser.FullName = txtProfileName.Text.Trim();
                    _currentAdvertiser.Email = txtProfileEmail.Text.Trim();
                    _currentAdvertiser.Phone = txtProfilePhone.Text.Trim();

                    // Handle profile picture upload
                    if (fuProfilePic != null && fuProfilePic.HasFile)
                    {
                        string uploadPath = Server.MapPath("~/images/");
                        if (!Directory.Exists(uploadPath))
                        {
                            Directory.CreateDirectory(uploadPath);
                        }

                        string fileName = Path.GetFileName(fuProfilePic.FileName);
                        string uniqueFileName = Guid.NewGuid().ToString() + Path.GetExtension(fileName);
                        string filePath = Path.Combine(uploadPath, uniqueFileName);

                        fuProfilePic.SaveAs(filePath);
                        _currentAdvertiser.ProfilePictureUrl = ResolveUrl("~/images/" + uniqueFileName);
                    }

                    // *** Firebase Update Logic for User Profile ***
                    string userUpdateUrl = $"{FirebaseBaseUrl}Users/{Uri.EscapeDataString(_currentAdvertiser.AdvertiserId)}.json";
                    var userUpdateData = new
                    {
                        FullName = _currentAdvertiser.FullName,
                        Email = _currentAdvertiser.Email,
                        Phone = _currentAdvertiser.Phone,
                        ProfilePictureUrl = _currentAdvertiser.ProfilePictureUrl,
                    };
                    var userContent = new StringContent(JsonConvert.SerializeObject(userUpdateData), System.Text.Encoding.UTF8, "application/json");

                    var userRequest = new HttpRequestMessage(new HttpMethod("PATCH"), userUpdateUrl)
                    {
                        Content = userContent
                    };
                    var userResponse = await _httpClient.SendAsync(userRequest);

                    if (!userResponse.IsSuccessStatusCode)
                    {
                        string errorContent = await userResponse.Content.ReadAsStringAsync();
                        throw new Exception($"Failed to update user profile in Firebase: {userResponse.StatusCode} - {errorContent}");
                    }
                    // *** End Firebase Update Logic ***

                    UpdateProfileInfo(); // Update sidebar display
                    SetProfileStatusMessage(true, "Profile information updated successfully!");
                }
                catch (Exception ex)
                {
                    SetProfileStatusMessage(false, "Error updating profile: " + ex.Message);
                    System.Diagnostics.Trace.TraceError($"Profile update error for advertiser ID {_currentAdvertiser?.AdvertiserId}: {ex.Message}");
                }
            }
            else
            {
                SafeSetControlVisible("vsProfileSettings", true);
            }
        }

        protected async void btnUpdatePassword_Click(object sender, EventArgs e)
        {
            TextBox txtProfileNewPassword = FindControl("txtProfileNewPassword") as TextBox;
            if (txtProfileNewPassword != null && !string.IsNullOrEmpty(txtProfileNewPassword.Text) && Page.IsValid)
            {
                try
                {
                    if (_currentAdvertiser == null)
                    {
                        SetProfileStatusMessage(false, "Error: User data not loaded. Please log in again.");
                        System.Diagnostics.Trace.TraceError("btnUpdatePassword_Click: _currentAdvertiser was null.");
                        return;
                    }

                    TextBox txtProfileOldPassword = FindControl("txtProfileOldPassword") as TextBox;
                    TextBox txtProfileConfirmPassword = FindControl("txtProfileConfirmPassword") as TextBox;

                    if (txtProfileOldPassword == null || txtProfileConfirmPassword == null)
                    {
                        SetProfileStatusMessage(false, "Error: Password form controls not found.");
                        return;
                    }

                    string oldPassword = txtProfileOldPassword.Text;
                    string newPassword = txtProfileNewPassword.Text;
                    string confirmPassword = txtProfileConfirmPassword.Text;

                    // 1. Verify old password
                    if (!BCrypt.Net.BCrypt.Verify(oldPassword, _currentAdvertiser.PasswordHash))
                    {
                        SetProfileStatusMessage(false, "Old password is incorrect.");
                        return;
                    }

                    // 2. Check if new passwords match (ASP.NET validators usually handle this, but a server-side check is good practice)
                    if (newPassword != confirmPassword)
                    {
                        SetProfileStatusMessage(false, "New password and confirm password do not match.");
                        return;
                    }

                    // 3. Hash the new password
                    string newPasswordHash = BCrypt.Net.BCrypt.HashPassword(newPassword);

                    // 4. Update the password in Firebase
                    string userPasswordUpdateUrl = $"{FirebaseBaseUrl}Users/{Uri.EscapeDataString(_currentAdvertiser.AdvertiserId)}.json";
                    var passwordUpdateData = new
                    {
                        Password = newPasswordHash // Note: This maps to the "Password" field in FirebaseUser model
                    };
                    var passwordContent = new StringContent(JsonConvert.SerializeObject(passwordUpdateData), System.Text.Encoding.UTF8, "application/json");

                    var passwordRequest = new HttpRequestMessage(new HttpMethod("PATCH"), userPasswordUpdateUrl)
                    {
                        Content = passwordContent
                    };
                    var passwordResponse = await _httpClient.SendAsync(passwordRequest);

                    if (!passwordResponse.IsSuccessStatusCode)
                    {
                        string errorContent = await passwordResponse.Content.ReadAsStringAsync();
                        throw new Exception($"Failed to update password in Firebase: {passwordResponse.StatusCode} - {errorContent}");
                    }

                    // 5. Update the local _currentAdvertiser object with the new hash
                    _currentAdvertiser.PasswordHash = newPasswordHash;

                    // 6. Clear password fields and show success message
                    SafeSetTextBoxText("txtProfileOldPassword", string.Empty);
                    SafeSetTextBoxText("txtProfileNewPassword", string.Empty);
                    SafeSetTextBoxText("txtProfileConfirmPassword", string.Empty);
                    SetProfileStatusMessage(true, "Password updated successfully!");
                }
                catch (Exception ex)
                {
                    SetProfileStatusMessage(false, "Error updating password: " + ex.Message);
                    System.Diagnostics.Trace.TraceError($"Password update error for advertiser ID {_currentAdvertiser?.AdvertiserId}: {ex.Message}");
                }
            }
            else
            {
                SafeSetControlVisible("vsProfileSettings", true);
            }
        }

        private void SetProfileStatusMessage(bool isSuccess, string message)
        {
            Panel pnlProfileStatusMessage = FindControl("pnlProfileStatusMessage") as Panel;
            Literal litProfileStatusMessage = FindControl("litProfileStatusMessage") as Literal;

            if (pnlProfileStatusMessage != null && litProfileStatusMessage != null)
            {
                pnlProfileStatusMessage.Visible = true;
                if (isSuccess)
                {
                    pnlProfileStatusMessage.CssClass = "alert alert-success mt-3";
                }
                else
                {
                    pnlProfileStatusMessage.CssClass = "alert alert-danger mt-3";
                }
                litProfileStatusMessage.Text = message;
            }
        }


        // --- Post Management Logic (All Posts & My Posts) ---

        private async Task BindAllPostsGrid()
        {
            GridView gvAllPosts = FindControl("gvAllPosts") as GridView;
            if (gvAllPosts == null) return;

            List<Post> allPosts = await GetAllPostsFromFirebase();

            // Filtering and Sorting logic for All Posts GridView
            string searchTerm = (FindControl("txtSearch") as TextBox)?.Text?.Trim();
            string categoryFilter = (FindControl("ddlCategory") as DropDownList)?.SelectedValue;
            string sortBy = (FindControl("ddlSortBy") as DropDownList)?.SelectedValue;

            IEnumerable<Post> filteredPosts = allPosts;

            if (!string.IsNullOrEmpty(searchTerm))
            {
                filteredPosts = filteredPosts.Where(p =>
                    p.Title.IndexOf(searchTerm, StringComparison.OrdinalIgnoreCase) >= 0 ||
                    p.Description.IndexOf(searchTerm, StringComparison.OrdinalIgnoreCase) >= 0);
            }

            if (!string.IsNullOrEmpty(categoryFilter) && categoryFilter != "All")
            {
                filteredPosts = filteredPosts.Where(p => p.Category == categoryFilter);
            }

            switch (sortBy)
            {
                case "latest":
                    filteredPosts = filteredPosts.OrderByDescending(p => p.DateCreated);
                    break;
                case "oldest":
                    filteredPosts = filteredPosts.OrderBy(p => p.DateCreated);
                    break;
                case "priceAsc":
                    filteredPosts = filteredPosts.OrderBy(p => p.Price);
                    break;
                case "priceDesc":
                    filteredPosts = filteredPosts.OrderByDescending(p => p.Price);
                    break;
                case "views":
                    filteredPosts = filteredPosts.OrderByDescending(p => p.Views);
                    break;
            }

            gvAllPosts.DataSource = filteredPosts.ToList();
            gvAllPosts.DataBind();
        }

        private async Task BindMyPostsGrid()
        {
            GridView gvMyPosts = FindControl("gvMyPosts") as GridView;
            if (gvMyPosts == null) return;

            if (_currentAdvertiser == null)
            {
                gvMyPosts.DataSource = new List<Post>();
                gvMyPosts.DataBind();
                return;
            }

            List<Post> allPosts = await GetAllPostsFromFirebase();
            List<Post> myPosts = allPosts.Where(p => p.AdvertiserId == _currentAdvertiser.AdvertiserId).ToList();

            // Filtering and Sorting logic for My Posts GridView
            string searchTerm = (FindControl("txtMyPostsSearch") as TextBox)?.Text?.Trim();
            string categoryFilter = (FindControl("ddlMyPostsCategory") as DropDownList)?.SelectedValue;
            string sortBy = (FindControl("ddlMyPostsSortBy") as DropDownList)?.SelectedValue;

            IEnumerable<Post> filteredMyPosts = myPosts;

            if (!string.IsNullOrEmpty(searchTerm))
            {
                filteredMyPosts = filteredMyPosts.Where(p =>
                    p.Title.IndexOf(searchTerm, StringComparison.OrdinalIgnoreCase) >= 0 ||
                    p.Description.IndexOf(searchTerm, StringComparison.OrdinalIgnoreCase) >= 0);
            }

            if (!string.IsNullOrEmpty(categoryFilter) && categoryFilter != "All")
            {
                filteredMyPosts = filteredMyPosts.Where(p => p.Category == categoryFilter);
            }

            switch (sortBy)
            {
                case "latest":
                    filteredMyPosts = filteredMyPosts.OrderByDescending(p => p.DateCreated);
                    break;
                case "oldest":
                    filteredMyPosts = filteredMyPosts.OrderBy(p => p.DateCreated);
                    break;
                case "priceAsc":
                    filteredMyPosts = filteredMyPosts.OrderBy(p => p.Price);
                    break;
                case "priceDesc":
                    filteredMyPosts = filteredMyPosts.OrderByDescending(p => p.Price);
                    break;
                case "views":
                    filteredMyPosts = filteredMyPosts.OrderByDescending(p => p.Views);
                    break;
            }

            gvMyPosts.DataSource = filteredMyPosts.ToList();
            gvMyPosts.DataBind();
        }

        protected async void btnSearch_Click(object sender, EventArgs e)
        {
            await BindAllPostsGrid();
        }

        protected async void ddlCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            await BindAllPostsGrid();
        }

        protected async void ddlSortBy_SelectedIndexChanged(object sender, EventArgs e)
        {
            await BindAllPostsGrid();
        }

        protected async void btnMyPostsSearch_Click(object sender, EventArgs e)
        {
            await BindMyPostsGrid();
        }

        protected async void ddlMyPostsCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            await BindMyPostsGrid();
        }

        protected async void ddlMyPostsSortBy_SelectedIndexChanged(object sender, EventArgs e)
        {
            await BindMyPostsGrid();
        }

        protected void gvAllPosts_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            GridView gvAllPosts = FindControl("gvAllPosts") as GridView;
            if (gvAllPosts != null)
            {
                gvAllPosts.PageIndex = e.NewPageIndex;
                _ = BindAllPostsGrid(); // Rebind the grid for the new page
            }
        }

        protected void gvMyPosts_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            GridView gvMyPosts = FindControl("gvMyPosts") as GridView;
            if (gvMyPosts != null)
            {
                gvMyPosts.PageIndex = e.NewPageIndex;
                _ = BindMyPostsGrid(); // Rebind the grid for the new page
            }
        }

        protected async void gvMyPosts_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ViewPost")
            {
                string postFirebaseId = e.CommandArgument.ToString();
                await ViewPostDetails(postFirebaseId);
            }
            else if (e.CommandName == "EditPost")
            {
                string postFirebaseId = e.CommandArgument.ToString();
                await LoadPostForEdit(postFirebaseId);
            }
            else if (e.CommandName == "DeletePost")
            {
                string postFirebaseId = e.CommandArgument.ToString();
                // Implement a confirmation dialog in the UI before calling DeletePostFromFirebase
                await DeletePost(postFirebaseId);
            }
        }

        private async Task ViewPostDetails(string postFirebaseId)
        {
            // Fetch the specific post
            List<Post> allPosts = await GetAllPostsFromFirebase();
            Post post = allPosts.FirstOrDefault(p => p.PostFirebaseId == postFirebaseId);

            if (post != null)
            {
                // Populate the Post Details Panel controls
                SafeSetLiteralText("litPostTitle", post.Title);
                SafeSetLiteralText("litPostDescription", post.Description);
                SafeSetLiteralText("litPostPrice", post.Price.ToString("C")); // Format as currency
                SafeSetLiteralText("litPostCategory", post.Category);
                SafeSetLiteralText("litPostDateCreated", post.DateCreated.ToShortDateString());
                SafeSetLiteralText("litPostViews", post.Views.ToString());
                SafeSetLiteralText("litPostAdvertiserName", post.AdvertiserFullName);
                SafeSetLiteralText("litPostAdvertiserEmail", post.AdvertiserEmail);
                SafeSetLiteralText("litPostAdvertiserPhone", post.AdvertiserPhone);

                Image imgPostDetail = FindControl("imgPostDetail") as Image;
                if (imgPostDetail != null)
                {
                    imgPostDetail.ImageUrl = string.IsNullOrEmpty(post.ImageUrl) ?
                        ResolveUrl("~/images/default-post.png") : post.ImageUrl;
                }

                // Increment view count in Firebase (optional, but good for analytics)
                await IncrementPostView(postFirebaseId, post.Views);
                await UpdateStats(); // Update sidebar stats after view increment

                ShowPanel("pnlPostDetails");
            }
            else
            {
                // Handle case where post is not found (e.g., show an error message)
                // For simplicity, we'll just go back to My Posts
                ShowPanel("pnlMyPosts");
                SetMyPostsStatusMessage(false, "Post not found or an error occurred.");
            }
        }

        private async Task IncrementPostView(string postFirebaseId, int currentViews)
        {
            try
            {
                string postUrl = $"{FirebaseBaseUrl}Posts/{Uri.EscapeDataString(postFirebaseId)}.json";
                var updateData = new
                {
                    Views = currentViews + 1
                };
                var content = new StringContent(JsonConvert.SerializeObject(updateData), System.Text.Encoding.UTF8, "application/json");

                var request = new HttpRequestMessage(new HttpMethod("PATCH"), postUrl)
                {
                    Content = content
                };
                var response = await _httpClient.SendAsync(request);

                if (!response.IsSuccessStatusCode)
                {
                    string errorContent = await response.Content.ReadAsStringAsync();
                    System.Diagnostics.Trace.TraceError($"Failed to increment post view in Firebase for ID '{postFirebaseId}': {response.StatusCode} - {errorContent}");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error incrementing post view for ID '{postFirebaseId}': {ex.Message}");
            }
        }

        private async Task LoadPostForEdit(string postFirebaseId)
        {
            List<Post> allPosts = await GetAllPostsFromFirebase();
            Post postToEdit = allPosts.FirstOrDefault(p => p.PostFirebaseId == postFirebaseId);

            if (postToEdit != null)
            {
                // Populate the "Create New Post" form with existing data for editing
                SafeSetTextBoxText("txtPostTitle", postToEdit.Title);
                SafeSetTextBoxText("txtPostDescription", postToEdit.Description);
                SafeSetTextBoxText("txtPostPrice", postToEdit.Price.ToString());
                SafeSetDropDownValue("ddlPostCategory", postToEdit.Category);

                // For image, you might want to display the current image and allow new upload
                Image imgPostPreview = FindControl("imgPostPreview") as Image;
                if (imgPostPreview != null)
                {
                    imgPostPreview.ImageUrl = string.IsNullOrEmpty(postToEdit.ImageUrl) ?
                        ResolveUrl("~/images/placeholder.png") : postToEdit.ImageUrl;
                    imgPostPreview.Visible = true;
                }

                SafeSetHiddenFieldValue("hdnPostId", postToEdit.PostFirebaseId); // Store Firebase ID for update
                SafeSetButtonText("btnSubmitPost", "Update Post");
                SafeSetControlVisible("btnCancelEdit", true);
                ShowPanel("pnlCreatePost"); // Show the create/edit form
            }
            else
            {
                SetMyPostsStatusMessage(false, "Could not find post to edit.");
            }
        }

        protected async void btnSubmitPost_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                try
                {
                    string postFirebaseId = (FindControl("hdnPostId") as HiddenField)?.Value;
                    bool isNewPost = string.IsNullOrEmpty(postFirebaseId);

                    // Safely get values from controls
                    string title = (FindControl("txtPostTitle") as TextBox)?.Text.Trim();
                    string description = (FindControl("txtPostDescription") as TextBox)?.Text.Trim();
                    string priceText = (FindControl("txtPostPrice") as TextBox)?.Text.Trim();
                    string category = (FindControl("ddlPostCategory") as DropDownList)?.SelectedValue;
                    FileUpload fuPostImage = FindControl("fuPostImage") as FileUpload;

                    if (string.IsNullOrEmpty(title) || string.IsNullOrEmpty(description) || string.IsNullOrEmpty(priceText) || string.IsNullOrEmpty(category))
                    {
                        SetCreatePostStatusMessage(false, "Please fill in all required fields.");
                        return;
                    }

                    if (!decimal.TryParse(priceText, out decimal price))
                    {
                        SetCreatePostStatusMessage(false, "Invalid price format.");
                        return;
                    }

                    string imageUrl = string.Empty;
                    if (fuPostImage != null && fuPostImage.HasFile)
                    {
                        string uploadPath = Server.MapPath("~/images/");
                        if (!Directory.Exists(uploadPath))
                        {
                            Directory.CreateDirectory(uploadPath);
                        }

                        string fileName = Path.GetFileName(fuPostImage.FileName);
                        string uniqueFileName = Guid.NewGuid().ToString() + Path.GetExtension(fileName);
                        string filePath = Path.Combine(uploadPath, uniqueFileName);

                        fuPostImage.SaveAs(filePath);
                        imageUrl = ResolveUrl("~/images/" + uniqueFileName);
                    }
                    else if (!isNewPost)
                    {
                        // If it's an edit and no new file, retain the existing image URL
                        List<Post> allPosts = await GetAllPostsFromFirebase();
                        Post existingPost = allPosts.FirstOrDefault(p => p.PostFirebaseId == postFirebaseId);
                        if (existingPost != null)
                        {
                            imageUrl = existingPost.ImageUrl;
                        }
                    }
                    else
                    {
                        // For new posts, if no image is uploaded, use a default
                        imageUrl = ResolveUrl("~/images/default-post.png");
                    }

                    // Ensure _currentAdvertiser is loaded
                    if (_currentAdvertiser == null)
                    {
                        _currentAdvertiser = await GetAdvertiserByIdFromFirebase(Session["AdvertiserId"].ToString());
                        if (_currentAdvertiser == null)
                        {
                            SetCreatePostStatusMessage(false, "Advertiser data not found. Please log in again.");
                            return;
                        }
                    }

                    Post post = new Post
                    {
                        Title = title,
                        Description = description,
                        Price = price,
                        Category = category,
                        ImageUrl = imageUrl,
                        AdvertiserId = _currentAdvertiser.AdvertiserId,
                        AdvertiserFullName = _currentAdvertiser.FullName,
                        AdvertiserProfilePic = _currentAdvertiser.ProfilePictureUrl,
                        AdvertiserEmail = _currentAdvertiser.Email,
                        AdvertiserPhone = _currentAdvertiser.Phone
                    };

                    if (isNewPost)
                    {
                        post.DateCreated = DateTime.UtcNow;
                        post.Views = 0;
                        await SaveNewPostToFirebase(post);
                        SetCreatePostStatusMessage(true, "New post created successfully!");
                    }
                    else
                    {
                        post.PostFirebaseId = postFirebaseId; // Assign the Firebase ID for update
                        // Fetch existing post to retain DateCreated and Views
                        List<Post> allPosts = await GetAllPostsFromFirebase();
                        Post existingPost = allPosts.FirstOrDefault(p => p.PostFirebaseId == postFirebaseId);
                        if (existingPost != null)
                        {
                            post.DateCreated = existingPost.DateCreated;
                            post.Views = existingPost.Views;
                        }
                        else
                        {
                            post.DateCreated = DateTime.UtcNow; // Fallback if existing post not found
                            post.Views = 0;
                        }

                        await UpdatePostInFirebase(post);
                        SetCreatePostStatusMessage(true, "Post updated successfully!");
                    }

                    ClearCreatePostForm();
                    await BindAllPostsGrid(); // Refresh grids
                    await BindMyPostsGrid();
                    await UpdateStats(); // Refresh stats
                }
                catch (Exception ex)
                {
                    SetCreatePostStatusMessage(false, "Error saving post: " + ex.Message);
                    System.Diagnostics.Trace.TraceError($"Post save/update error: {ex.Message}");
                }
            }
            else
            {
                SafeSetControlVisible("vsCreatePost", true);
            }
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            ClearCreatePostForm();
            ShowPanel("pnlMyPosts");
        }

        private void ClearCreatePostForm()
        {
            SafeSetTextBoxText("txtPostTitle", string.Empty);
            SafeSetTextBoxText("txtPostDescription", string.Empty);
            SafeSetTextBoxText("txtPostPrice", string.Empty);
            SafeSetDropDownValue("ddlPostCategory", ""); // Set to default or empty
            // Reset FileUpload (cannot clear selected file directly, but UI will show "No file chosen")
            Image imgPostPreview = FindControl("imgPostPreview") as Image;
            if (imgPostPreview != null)
            {
                imgPostPreview.Visible = false;
                imgPostPreview.ImageUrl = string.Empty;
            }
            SafeSetHiddenFieldValue("hdnPostId", string.Empty);
            SafeSetButtonText("btnSubmitPost", "Create Post");
            SafeSetControlVisible("btnCancelEdit", false);
            SetCreatePostStatusMessage(false, string.Empty); // Clear status message
            SafeSetPanelVisible("pnlCreatePostStatusMessage", false);
        }

        private void SetCreatePostStatusMessage(bool isSuccess, string message)
        {
            Panel pnlCreatePostStatusMessage = FindControl("pnlCreatePostStatusMessage") as Panel;
            Literal litCreatePostStatusMessage = FindControl("litCreatePostStatusMessage") as Literal;

            if (pnlCreatePostStatusMessage != null && litCreatePostStatusMessage != null)
            {
                pnlCreatePostStatusMessage.Visible = true;
                if (isSuccess)
                {
                    pnlCreatePostStatusMessage.CssClass = "alert alert-success mt-3";
                }
                else
                {
                    pnlCreatePostStatusMessage.CssClass = "alert alert-danger mt-3";
                }
                litCreatePostStatusMessage.Text = message;
            }
        }

        private void SetMyPostsStatusMessage(bool isSuccess, string message)
        {
            Panel pnlMyPostsStatusMessage = FindControl("pnlMyPostsStatusMessage") as Panel;
            Literal litMyPostsStatusMessage = FindControl("litMyPostsStatusMessage") as Literal;

            if (pnlMyPostsStatusMessage != null && litMyPostsStatusMessage != null)
            {
                pnlMyPostsStatusMessage.Visible = true;
                if (isSuccess)
                {
                    pnlMyPostsStatusMessage.CssClass = "alert alert-success mt-3";
                }
                else
                {
                    pnlMyPostsStatusMessage.CssClass = "alert alert-danger mt-3";
                }
                litMyPostsStatusMessage.Text = message;
            }
        }

        protected async void btnBackToMyPosts_Click(object sender, EventArgs e)
        {
            ShowPanel("pnlMyPosts");
            await BindMyPostsGrid();
        }
        protected async void txtSearch_TextChanged(object sender, EventArgs e)
        {
            // This method will be called when the text in txtSearch changes and AutoPostBack is true.
            await BindAllPostsGrid();
        }
        protected void rptMyPosts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            // Handle commands from the MyPosts repeater
            switch (e.CommandName)
            {
                case "ViewPost":
                    string postFirebaseId = e.CommandArgument.ToString();
                    _ = ViewPostDetails(postFirebaseId);
                    break;

                case "EditPost":
                    string postIdToEdit = e.CommandArgument.ToString();
                    _ = LoadPostForEdit(postIdToEdit);
                    break;

                case "DeletePost":
                    string postIdToDelete = e.CommandArgument.ToString();
                    _ = DeletePost(postIdToDelete);
                    break;

                default:
                    // Handle unknown commands
                    break;
            }
        }

        private async Task DeletePost(string postFirebaseId)
        {
            try
            {
                await DeletePostFromFirebase(postFirebaseId);
                SetMyPostsStatusMessage(true, "Post deleted successfully!");
                await BindMyPostsGrid(); // Rebind to reflect deletion
                await BindAllPostsGrid(); // Also update the All Posts grid
                await UpdateStats(); // Update stats
            }
            catch (Exception ex)
            {
                SetMyPostsStatusMessage(false, "Error deleting post: " + ex.Message);
                System.Diagnostics.Trace.TraceError($"Post deletion error for ID '{postFirebaseId}': {ex.Message}");
            }
        }
    }
}