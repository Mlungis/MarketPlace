using System;
using System.IO;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using System.Web.UI;
using Newtonsoft.Json;

namespace MarketPlace
{
    public partial class PaymentProof : Page
    {
        // Firebase Storage bucket URL (replace with your own bucket)
        private const string firebaseStorageBucket = "zeromarket-ddd36.appspot.com";

        // Firebase Realtime Database URL for PaymentProofs
        private const string firebaseDbUrl = "https://zeromarket-ddd36-default-rtdb.firebaseio.com/PaymentProofs.json";

        // TODO: Your Firebase Bearer OAuth2 access token (requires secure handling)
        private const string firebaseAccessToken = "YOUR_FIREBASE_ACCESS_TOKEN";

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected async void btnSubmit_Click(object sender, EventArgs e)
        {
            lblMessage.Text = "";

            if (string.IsNullOrWhiteSpace(txtEmail.Text))
            {
                lblMessage.Text = "Please enter your email.";
                return;
            }

            if (!fileUpload.HasFile)
            {
                lblMessage.Text = "Please upload a screenshot of your payment.";
                return;
            }

            string extension = Path.GetExtension(fileUpload.FileName).ToLower();
            if (extension != ".jpg" && extension != ".jpeg" && extension != ".png" && extension != ".gif")
            {
                lblMessage.Text = "Only image files (.jpg, .jpeg, .png, .gif) are allowed.";
                return;
            }

            string uniqueFileName = Guid.NewGuid().ToString() + extension;

            try
            {
                byte[] fileBytes;
                using (var ms = new MemoryStream())
                {
                    fileUpload.PostedFile.InputStream.CopyTo(ms);
                    fileBytes = ms.ToArray();
                }

                // 1. Upload file bytes to Firebase Storage
                string downloadUrl = await UploadFileToFirebaseStorage(uniqueFileName, fileBytes);

                if (string.IsNullOrEmpty(downloadUrl))
                {
                    lblMessage.Text = "Failed to upload file to Firebase Storage.";
                    return;
                }

                // 2. Save record to Firebase Realtime Database
                var paymentProofData = new
                {
                    Email = txtEmail.Text.Trim(),
                    FileName = uniqueFileName,
                    FileUrl = downloadUrl,
                    UploadDate = DateTime.UtcNow.ToString("o")
                };

                bool dbSuccess = await SavePaymentProofToFirebase(paymentProofData);

                if (dbSuccess)
                {
                    pnlForm.Visible = false;
                    pnlThankYou.Visible = true;
                }
                else
                {
                    lblMessage.Text = "Failed to save payment proof record.";
                }
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Error uploading file: " + ex.Message;
            }
        }

        private async Task<string> UploadFileToFirebaseStorage(string fileName, byte[] fileBytes)
        {
            // Firebase Storage REST upload endpoint for your bucket:
            // https://firebasestorage.googleapis.com/v0/b/[bucket]/o?name=[filename]

            string uploadUrl = $"https://firebasestorage.googleapis.com/v0/b/{firebaseStorageBucket}/o?name={Uri.EscapeDataString(fileName)}";

            using (var httpClient = new HttpClient())
            {
                httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", firebaseAccessToken);

                using (var content = new ByteArrayContent(fileBytes))
                {
                    // Set content type (change as needed)
                    content.Headers.ContentType = new MediaTypeHeaderValue("image/jpeg");

                    var response = await httpClient.PostAsync(uploadUrl, content);
                    if (!response.IsSuccessStatusCode)
                    {
                        return null;
                    }

                    string jsonResult = await response.Content.ReadAsStringAsync();

                    // Parse JSON response to extract download URL
                    var obj = JsonConvert.DeserializeObject<dynamic>(jsonResult);

                    // Compose a public download URL
                    // You may need to set your bucket files as publicly accessible or generate signed URLs
                    string downloadTokens = obj.downloadTokens;
                    string downloadUrl = $"https://firebasestorage.googleapis.com/v0/b/{firebaseStorageBucket}/o/{Uri.EscapeDataString(fileName)}?alt=media&token={downloadTokens}";

                    return downloadUrl;
                }
            }
        }

        private async Task<bool> SavePaymentProofToFirebase(object paymentProofData)
        {
            using (var httpClient = new HttpClient())
            {
                string json = JsonConvert.SerializeObject(paymentProofData);
                var content = new StringContent(json, Encoding.UTF8, "application/json");

                var response = await httpClient.PostAsync(firebaseDbUrl, content);
                return response.IsSuccessStatusCode;
            }
        }
    }
}
