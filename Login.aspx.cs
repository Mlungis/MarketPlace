using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web.UI;
using Newtonsoft.Json;
using BCrypt.Net; // Make sure you have installed BCrypt.Net.Next via NuGet: Install-Package BCrypt.Net-Next

namespace MarketPlace
{
    public partial class Login : System.Web.UI.Page
    {
        private static readonly HttpClient _httpClient = new HttpClient();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                lblError.Text = "";
                if (Request.QueryString["error"] != null)
                {
                    lblError.Text = Server.UrlDecode(Request.QueryString["error"]);
                }
            }
        }

        protected async void btnLogin_Click(object sender, EventArgs e)
        {
            lblError.Text = "";

            string email = txtEmail.Text.Trim().ToLowerInvariant();
            string password = txtPass.Text.Trim();

            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                lblError.Text = "Please enter both email and password.";
                return;
            }

            try
            {
                var user = await GetUserByEmailAsync(email);

                if (user == null || string.IsNullOrEmpty(user.Password))
                {
                    lblError.Text = "Invalid email or password.";
                    return;
                }

                // Use BCrypt.Net.BCrypt.Verify for password comparison
                if (!BCrypt.Net.BCrypt.Verify(password, user.Password))
                {
                    lblError.Text = "Invalid email or password.";
                    return;
                }

                // Common session variables for all successful logins
                Session["UserId"] = user.Id;
                Session["Role"] = user.Role?.ToLowerInvariant();

                if (user.Role?.ToLowerInvariant() == "customer")
                {
                    Response.Redirect("customerDash.aspx", false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }
                else if (user.Role?.ToLowerInvariant() == "advertiser")
                {
                    bool hasPlan = await DoesUserHavePlanAsync(user.Id);
                    if (!hasPlan)
                    {
                        lblError.Text = "No active plan found. Redirecting to Plans page...";
                        Response.Redirect("Plans.aspx", false);
                        Context.ApplicationInstance.CompleteRequest();
                        return;
                    }

                    var advertiserData = await GetAdvertiserDataAsync(user.Id);
                    if (advertiserData == null)
                    {
                        lblError.Text = "No business registered. Redirecting to Business Registration page...";
                        Response.Redirect("BusinessRegPage.aspx", false);
                        Context.ApplicationInstance.CompleteRequest();
                        return;
                    }

                    // *** CRITICAL FIX: Set AdvertiserId in session for AdvertiserDash ***
                    Session["AdvertiserId"] = user.Id; // Use the Firebase User ID as the AdvertiserId
                    Session["BusinessName"] = advertiserData.BusinessName;
                    Session["Plan"] = advertiserData.Plan;

                    Response.Redirect("AdvertiserDash.aspx", false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }
                else
                {
                    lblError.Text = "Unknown user role. Please contact support.";
                    Session.Clear();
                }
            }
            catch (Exception ex)
            {
                lblError.Text = "Login failed: " + ex.Message;
                // Log the exception for debugging
                System.Diagnostics.Trace.TraceError($"Login error for email {email}: {ex.Message}");
            }
        }

        private async Task<User> GetUserByEmailAsync(string email)
        {
            string firebaseQueryUrl = $"https://zeromarket-ddd36-default-rtdb.firebaseio.com/Users.json?orderBy=\"Email\"&equalTo=\"{Uri.EscapeDataString(email)}\"";

            var response = await _httpClient.GetAsync(firebaseQueryUrl);

            if (!response.IsSuccessStatusCode)
            {
                System.Diagnostics.Trace.TraceWarning($"Firebase user query failed for email '{email}' with status code: {response.StatusCode}");
                return null;
            }

            var json = await response.Content.ReadAsStringAsync();

            if (string.IsNullOrWhiteSpace(json) || json == "null" || json == "{}")
                return null;

            var usersDict = JsonConvert.DeserializeObject<Dictionary<string, FirebaseUser>>(json);

            var foundUserEntry = usersDict.FirstOrDefault();

            if (foundUserEntry.Value != null)
            {
                return new User
                {
                    Id = foundUserEntry.Key, // Firebase ID
                    Email = foundUserEntry.Value.Email,
                    Password = foundUserEntry.Value.Password,
                    Role = foundUserEntry.Value.Role
                };
            }

            return null;
        }

        private async Task<bool> DoesUserHavePlanAsync(string userId)
        {
            string url = $"https://zeromarket-ddd36-default-rtdb.firebaseio.com/Plans.json?orderBy=\"UserId\"&equalTo=\"{Uri.EscapeDataString(userId)}\"";

            var response = await _httpClient.GetAsync(url);

            if (!response.IsSuccessStatusCode)
            {
                System.Diagnostics.Trace.TraceWarning($"Failed to check plan for UserId '{userId}' with status {response.StatusCode}");
                return false; // assume no plan on failure
            }

            var json = await response.Content.ReadAsStringAsync();

            if (string.IsNullOrWhiteSpace(json) || json == "null" || json == "{}")
                return false;

            var plansDict = JsonConvert.DeserializeObject<Dictionary<string, PlanFirebaseModel>>(json);

            // Check if any plan exists for the userId and it has a 'Plan' field (indicating existence)
            return plansDict != null && plansDict.Any(p => p.Value.Plan != null);
        }

        private async Task<AdvertiserData> GetAdvertiserDataAsync(string userId)
        {
            string advertiserUrl = $"https://zeromarket-ddd36-default-rtdb.firebaseio.com/Businesses.json?orderBy=\"UserId\"&equalTo=\"{Uri.EscapeDataString(userId)}\"";

            var response = await _httpClient.GetAsync(advertiserUrl);

            if (!response.IsSuccessStatusCode)
            {
                System.Diagnostics.Trace.TraceWarning($"Firebase business query failed for UserId '{userId}' with status code: {response.StatusCode}");
                return null;
            }

            var json = await response.Content.ReadAsStringAsync();

            if (string.IsNullOrWhiteSpace(json) || json == "null" || json == "{}")
                return null;

            var advertisers = JsonConvert.DeserializeObject<Dictionary<string, AdvertiserFirebaseModel>>(json);

            var first = advertisers.Values.FirstOrDefault();

            return first != null
                ? new AdvertiserData
                {
                    BusinessName = first.BusinessName,
                    Plan = first.Plan
                }
                : null;
        }

        // DTOs for Firebase deserialization
        private class FirebaseUser
        {
            public string FullName { get; set; }
            public string Email { get; set; }
            public string Phone { get; set; }
            public string Password { get; set; } // Hashed password from Firebase
            public string Role { get; set; }
        }

        private class User // Simplified user model for application logic
        {
            public string Id { get; set; } // This is the Firebase Key
            public string Email { get; set; }
            public string Password { get; set; }
            public string Role { get; set; }
        }

        private class AdvertiserFirebaseModel
        {
            public string UserId { get; set; }
            public string BusinessName { get; set; }
            public string Plan { get; set; } // The plan type associated with the business
            public string ContactEmail { get; set; } // Assuming these might exist in your business data
            public string ContactPhone { get; set; }
            public string ProfilePictureUrl { get; set; } // Assuming this might exist for the business
        }

        private class AdvertiserData // Simplified advertiser data for session
        {
            public string BusinessName { get; set; }
            public string Plan { get; set; }
        }

        private class PlanFirebaseModel
        {
            public string Plan { get; set; }
            public string UserId { get; set; }
            public string PaymentStatus { get; set; }
            public string Timestamp { get; set; }
        }
    }
}