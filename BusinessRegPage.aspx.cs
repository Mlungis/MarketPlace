using System;
using System.Drawing;
using System.IO;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web.UI;
using Newtonsoft.Json;

namespace MarketPlace
{
    public partial class BusinessRegPage : System.Web.UI.Page
    {
        private static readonly string firebaseBusinessesUrl = "https://zeromarket-ddd36-default-rtdb.firebaseio.com/Businesses.json";
        private static readonly HttpClient _httpClient = new HttpClient();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                lblMessage.Text = "";
            }
        }

        protected async void btnRegisterBusiness_Click(object sender, EventArgs e)
        {
            string businessName = txtBusinessName.Text.Trim();
            string category = ddlBusinessType.SelectedValue;

            if (string.IsNullOrEmpty(businessName))
            {
                lblMessage.Text = "Please enter a business name.";
                lblMessage.ForeColor = Color.Red;
                return;
            }

            if (string.IsNullOrEmpty(category) || category == "0")
            {
                lblMessage.Text = "Please select a business category.";
                lblMessage.ForeColor = Color.Red;
                return;
            }

            if (!fileLogo.HasFile)
            {
                lblMessage.Text = "Please upload a business logo.";
                lblMessage.ForeColor = Color.Red;
                return;
            }

            string fileExtension = Path.GetExtension(fileLogo.FileName).ToLower();
            int fileSize = fileLogo.PostedFile.ContentLength;
            int maxFileSize = 1024 * 1024; // 1 MB
            string[] allowedExtensions = { ".jpg", ".jpeg", ".png", ".gif" };

            if (Array.IndexOf(allowedExtensions, fileExtension) == -1)
            {
                lblMessage.Text = "Invalid file type. Only JPG, JPEG, PNG, GIF images are allowed.";
                lblMessage.ForeColor = Color.Red;
                return;
            }

            if (fileSize > maxFileSize)
            {
                lblMessage.Text = $"File size exceeds the limit of {maxFileSize / (1024 * 1024)} MB.";
                lblMessage.ForeColor = Color.Red;
                return;
            }

            byte[] imageBytes;
            try
            {
                using (Stream fs = fileLogo.PostedFile.InputStream)
                {
                    imageBytes = new byte[fs.Length];
                    await fs.ReadAsync(imageBytes, 0, (int)fs.Length);
                }
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Error reading file: " + ex.Message;
                lblMessage.ForeColor = Color.Red;
                return;
            }

            if (Session["UserId"] == null)
            {
                lblMessage.Text = "User not logged in. Please log in again.";
                lblMessage.ForeColor = Color.Red;
                Response.Redirect("Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            // UserId is a string (Firebase ID)
            string userId = Session["UserId"].ToString();

            // Convert image to Base64 string (simple approach)
            string base64Image = Convert.ToBase64String(imageBytes);

            var businessData = new
            {
                BusinessName = businessName,
                Category = category,
                PictureBase64 = base64Image,
                UserId = userId,
                Timestamp = DateTime.UtcNow.ToString("o")
            };

            try
            {
                string json = JsonConvert.SerializeObject(businessData);
                var content = new StringContent(json, Encoding.UTF8, "application/json");

                HttpResponseMessage response = await _httpClient.PostAsync(firebaseBusinessesUrl, content);

                if (response.IsSuccessStatusCode)
                {
                    lblMessage.Text = "Business registered successfully!";
                    lblMessage.ForeColor = Color.Green;

                    Session["BusinessName"] = businessName;

                    Response.Redirect("AdvertiserDash.aspx", false);
                    Context.ApplicationInstance.CompleteRequest();
                }
                else
                {
                    lblMessage.Text = "Failed to save business. Firebase error.";
                    lblMessage.ForeColor = Color.Red;
                }
            }
            catch (Exception ex)
            {
                lblMessage.Text = "An unexpected error occurred: " + ex.Message;
                lblMessage.ForeColor = Color.Red;
            }
        }
    }
}
