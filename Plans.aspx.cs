using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web.UI;
using Newtonsoft.Json;

namespace MarketPlace
{
    public partial class Plans : System.Web.UI.Page
    {
        private static readonly string firebaseBaseUrl = "https://zeromarket-ddd36-default-rtdb.firebaseio.com";
        private static readonly HttpClient _httpClient = new HttpClient();

        // Optional: Firebase Auth token if needed
        private static readonly string firebaseAuthToken = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
                Response.Redirect("Login.aspx");
        }

        protected async void btnFree_Click(object sender, EventArgs e)
        {
            await HandlePlanSelection("Free", "Verified", "BusinessRegPage.aspx");
        }

        protected async void btnSilver_Click(object sender, EventArgs e)
        {
            await HandlePlanSelection("Silver", "Pending", "https://pay.yoco.com/r/4nAgbx");
        }

        protected async void btnGold_Click(object sender, EventArgs e)
        {
            await HandlePlanSelection("Gold", "Pending", "https://pay.yoco.com/r/mdAzdl");
        }

        private async Task HandlePlanSelection(string planName, string paymentStatus, string redirectUrl)
        {
            try
            {
                string userId = Session["UserId"].ToString();

                bool exists = await CheckIfPlanExistsAsync(userId, planName);
                if (exists)
                {
                    ShowMessage($"You have already selected the {planName} plan.", false);
                    return;
                }

                await InsertPlanAsync(userId, planName, paymentStatus);
                Response.Redirect(redirectUrl, false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex)
            {
                ShowMessage($"Error: {ex.Message}", false);
            }
        }

        private async Task<bool> CheckIfPlanExistsAsync(string userId, string planName)
        {
            string orderBy = Uri.EscapeDataString("\"UserId\"");
            string equalTo = Uri.EscapeDataString($"\"{userId}\"");

            string queryUrl = $"{firebaseBaseUrl}/Plans.json?orderBy={orderBy}&equalTo={equalTo}";

            if (!string.IsNullOrEmpty(firebaseAuthToken))
                queryUrl += $"&auth={firebaseAuthToken}";

            var response = await _httpClient.GetAsync(queryUrl);

            if (!response.IsSuccessStatusCode)
                throw new Exception($"Failed to query plans: {response.StatusCode}");

            var json = await response.Content.ReadAsStringAsync();

            if (string.IsNullOrWhiteSpace(json) || json == "null" || json == "{}")
                return false;

            var plansDict = JsonConvert.DeserializeObject<Dictionary<string, PlanFirebaseModel>>(json);

            // Check if user already has the specific plan
            return plansDict.Values.Any(p => p.Plan.Equals(planName, StringComparison.OrdinalIgnoreCase));
        }

        private async Task InsertPlanAsync(string userId, string planName, string paymentStatus)
        {
            var planData = new PlanFirebaseModel
            {
                UserId = userId,
                Plan = planName,
                PaymentStatus = paymentStatus,
                Timestamp = DateTime.UtcNow.ToString("o")
            };

            string json = JsonConvert.SerializeObject(planData);
            string postUrl = $"{firebaseBaseUrl}/Plans.json";

            if (!string.IsNullOrEmpty(firebaseAuthToken))
                postUrl += $"?auth={firebaseAuthToken}";

            var content = new StringContent(json, Encoding.UTF8, "application/json");
            var response = await _httpClient.PostAsync(postUrl, content);

            if (!response.IsSuccessStatusCode)
                throw new Exception($"Failed to insert plan: {response.StatusCode}");
        }

        private void ShowMessage(string message, bool success)
        {
            string safeMessage = message.Replace("'", "\\'");
            string script = $"alert('{safeMessage}');";
            ClientScript.RegisterStartupScript(this.GetType(), "alert", script, true);
        }

        private class PlanFirebaseModel
        {
            public string UserId { get; set; }
            public string Plan { get; set; }
            public string PaymentStatus { get; set; }
            public string Timestamp { get; set; }
        }
    }
}
