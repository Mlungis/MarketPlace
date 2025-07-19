using System;
using System.Net.Http;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.UI;
using Newtonsoft.Json;
using System.Threading.Tasks;

namespace MarketPlace
{
    public partial class Register : System.Web.UI.Page
    {
        // Use the same base URL structure as login, but let Firebase generate unique keys
        private static readonly string firebaseUrl = "https://zeromarket-ddd36-default-rtdb.firebaseio.com/Users.json";

        // Use static HttpClient for consistency with login code
        private static readonly HttpClient _httpClient = new HttpClient();

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected async void btnRegister_Click(object sender, EventArgs e)
        {
            lblMessage.Text = "";
            Page.Validate("RegisterUser");
            if (!Page.IsValid) return;

            string fullName = txtFullName.Value.Trim();
            string email = txtEmail.Value.Trim();
            string phone = txtCell.Value.Trim();
            string password = txtPassword.Value.Trim();
            string role = ddlRole.SelectedValue;

            try
            {
                // Check if email already exists before registering
                if (await EmailExistsAsync(email))
                {
                    lblMessage.Text = "An account with this email already exists.";
                    lblMessage.ForeColor = System.Drawing.Color.Red;
                    return;
                }

                string hashedPassword = BCrypt.Net.BCrypt.HashPassword(password);

                var userData = new
                {
                    FullName = fullName,
                    Email = email,
                    Phone = phone,
                    Password = hashedPassword,
                    Role = role
                };

                string json = JsonConvert.SerializeObject(userData);
                StringContent content = new StringContent(json, Encoding.UTF8, "application/json");

                // POST to /Users.json to let Firebase auto-generate unique keys
                HttpResponseMessage response = await _httpClient.PostAsync(firebaseUrl, content);

                if (response.IsSuccessStatusCode)
                {
                    lblMessage.Text = "Registration successful!";
                    lblMessage.ForeColor = System.Drawing.Color.Green;
                    Response.Redirect("Login.aspx", false);
                    Context.ApplicationInstance.CompleteRequest();
                }
                else
                {
                    string errorContent = await response.Content.ReadAsStringAsync();
                    lblMessage.Text = "Failed to register. Please try again.";
                    lblMessage.ForeColor = System.Drawing.Color.Red;
                    System.Diagnostics.Trace.TraceError($"Firebase registration failed: {response.StatusCode} - {errorContent}");
                }
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Registration failed due to an unexpected error. Please try again.";
                lblMessage.ForeColor = System.Drawing.Color.Red;
                System.Diagnostics.Trace.TraceError($"Registration exception for email {email}: {ex}");
            }
        }

        /// <summary>
        /// Check if email already exists in Firebase
        /// </summary>
        private async Task<bool> EmailExistsAsync(string email)
        {
            try
            {
                string queryUrl = $"https://zeromarket-ddd36-default-rtdb.firebaseio.com/Users.json?orderBy=\"Email\"&equalTo=\"{Uri.EscapeDataString(email)}\"";
                var response = await _httpClient.GetAsync(queryUrl);

                if (!response.IsSuccessStatusCode)
                {
                    return false; // Assume email doesn't exist if query fails
                }

                var json = await response.Content.ReadAsStringAsync();
                return !string.IsNullOrWhiteSpace(json) && json != "null" && json != "{}";
            }
            catch
            {
                return false; // Assume email doesn't exist if check fails
            }
        }

        protected void cvPasswordComplexity_ServerValidate(object source, System.Web.UI.WebControls.ServerValidateEventArgs args)
        {
            string password = args.Value;
            if (password.Length < 8)
            {
                args.IsValid = false;
                ((System.Web.UI.WebControls.CustomValidator)source).ErrorMessage = "Password must be at least 8 characters long.";
                return;
            }
            if (!Regex.IsMatch(password, @"\d"))
            {
                args.IsValid = false;
                ((System.Web.UI.WebControls.CustomValidator)source).ErrorMessage = "Password must contain at least one number.";
                return;
            }
            if (!Regex.IsMatch(password, @"[!@#$%^&*()_+=\[{\]};:<>|./?,-]"))
            {
                args.IsValid = false;
                ((System.Web.UI.WebControls.CustomValidator)source).ErrorMessage = "Password must contain at least one special character.";
                return;
            }
            args.IsValid = true;
        }
    }
}