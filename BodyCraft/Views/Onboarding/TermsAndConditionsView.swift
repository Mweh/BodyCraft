import SwiftUI

struct TermsAndConditionsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        Text("KOALA TERMS AND CONDITIONS OF USE")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Last Updated: March 12, 2026")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.secondaryText)
                        
                        Text("Welcome to KOALA! Before we begin your body transformation journey, please read these rules. By accessing or using the KOALA application, you agree to be legally bound by the terms below.")
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                        
                        // Section 1
                        VStack(alignment: .leading, spacing: 10) {
                            Text("1. Nature of Service (AI-Generated & \"As-Is\")")
                                .font(.headline).fontWeight(.bold).foregroundColor(AppTheme.primary)
                            Text("**For Information Only:** KOALA provides training and nutrition programs generated entirely by Artificial Intelligence (AI). This service is provided on an \"as is\" and \"as available\" basis without warranties of any kind.")
                                .foregroundColor(.white)
                            Text("**Risk of Use:** Any material you access or download through KOALA is entirely at your own risk. We do not guarantee the accuracy, integrity, or specific results of the programs provided by our algorithms.")
                                .foregroundColor(.white)
                        }
                        
                        // Section 2
                        VStack(alignment: .leading, spacing: 10) {
                            Text("2. Medical Disclaimer")
                                .font(.headline).fontWeight(.bold).foregroundColor(AppTheme.primary)
                            Text("**Not a Medical Provider:** KOALA is NOT a healthcare or medical provider. The features, nutritional plans, recipes, and training programs within the app are for general informational purposes only and do not constitute medical advice.")
                                .foregroundColor(.white)
                            Text("**Consultation Obligation:** You agree that you are solely responsible for consulting with a doctor or qualified professional before following any training or diet program, especially if you have a history of injuries or specific health conditions.")
                                .foregroundColor(.white)
                        }
                        
                        // Section 3
                        VStack(alignment: .leading, spacing: 10) {
                            Text("3. Assumption of Risk & Limitation of Liability")
                                .font(.headline).fontWeight(.bold).foregroundColor(AppTheme.primary)
                            Text("**Full Responsibility:** All risks associated with the use of the service, including but not limited to physical, mental, injury, loss, or death, are the sole responsibility of the User.")
                                .foregroundColor(.white)
                            Text("**Release of Claims:** You hereby release KOALA, its developers, and its affiliates from any and all claims, demands, or legal liabilities arising from your use of our services or your breach of these terms.")
                                .foregroundColor(.white)
                            Text("**Device Damage:** We are not responsible for any hardware damage or data loss that may occur as a result of using this application.")
                                .foregroundColor(.white)
                        }
                        
                        // Section 4
                        VStack(alignment: .leading, spacing: 10) {
                            Text("4. Intellectual Property Rights")
                                .font(.headline).fontWeight(.bold).foregroundColor(AppTheme.primary)
                            Text("**Ownership:** All content, designs, logos, the \"KOALA\" product name, slogans, and algorithms are our property and are protected by the Copyright and Trademark Laws of the Republic of Indonesia.")
                                .foregroundColor(.white)
                            Text("**Limited License:** You are granted access solely for personal, non-commercial use. It is strictly prohibited to reproduce, distribute, or use KOALA assets for commercial purposes without our prior written consent.")
                                .foregroundColor(.white)
                        }
                        
                        // Section 5
                        VStack(alignment: .leading, spacing: 10) {
                            Text("5. Personal Data & Privacy (In Accordance with PDP Law)")
                                .font(.headline).fontWeight(.bold).foregroundColor(AppTheme.primary)
                            Text("**Data Processing:** We collect and process personal data (identity, location, body metrics) for registration, service personalization, and application development purposes.")
                                .foregroundColor(.white)
                            Text("**Legal Compliance:** Protecting your privacy is our priority. We adhere to Law No. 27 of 2022 on Personal Data Protection (PDP Law) and the EIT Law (UU ITE).")
                                .foregroundColor(.white)
                            Text("**Third Parties:** Where necessary for operations, we may share data with third parties who are legally bound to maintain data protection standards equivalent to Indonesian law.")
                                .foregroundColor(.white)
                        }
                        
                        // Section 6
                        VStack(alignment: .leading, spacing: 10) {
                            Text("6. Governing Law & Dispute Resolution (BANI)")
                                .font(.headline).fontWeight(.bold).foregroundColor(AppTheme.primary)
                            Text("**Indonesian Law:** These Terms and Conditions are governed by the laws of the Republic of Indonesia.")
                                .foregroundColor(.white)
                            Text("**Arbitration:** In the event of a dispute that cannot be settled amicably, it shall be resolved through the Indonesian National Arbitration Board (BANI) in Jakarta, in accordance with Law No. 30 of 1999 concerning Arbitration and Alternative Dispute Resolution.")
                                .foregroundColor(.white)
                        }
                        
                        // Section 7
                        VStack(alignment: .leading, spacing: 10) {
                            Text("7. Modification & Termination")
                                .font(.headline).fontWeight(.bold).foregroundColor(AppTheme.primary)
                            Text("We reserve the right to modify these T&C at any time. Changes will take effect immediately upon publication in the app.")
                                .foregroundColor(.white)
                            Text("We reserve the full right to suspend or limit your access to the service if any rule violations are found or for other operational reasons.")
                                .foregroundColor(.white)
                        }
                        
                        // Final Consents
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Confirmation of Consent")
                                .font(.headline).fontWeight(.bold).foregroundColor(AppTheme.primary)
                            Text("I understand that KOALA uses AI and does not provide medical advice. I accept all physical and health risks and agree to the terms above.")
                                .foregroundColor(.white)
                        }
                        .padding(.top, 8)
                        
                        Spacer().frame(height: 40)
                    }
                    .padding()
                }
            }
            .navigationTitle("Terms & Conditions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.primary)
                }
            }
        }
    }
}
