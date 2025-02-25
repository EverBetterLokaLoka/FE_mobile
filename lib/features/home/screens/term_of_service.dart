import 'package:flutter/material.dart';
import 'package:lokaloka/features/home/screens/trust_phone_screen.dart';

import '../../../core/styles/colors.dart';

final String Term = """1. Term
This agreement is effective as of the date you access or use the App and will remain in effect until terminated as outlined below.
2. Services to Be Provided
The App offers an AI-powered travel assistant with features including:
* Personalized trip planning suggestions
* Map navigation with flagging features
* Real-time weather forecast updates
* Connection with friends to share moments
* Emergency alerts and location sharing for safety
* Dynamic travel plan updates
3. Fees
The App is free to use unless otherwise specified. Certain premium features may require a subscription or one-time fee, which will be disclosed before purchase.
4. Reimbursement of Certain Costs
Users are responsible for any internet, mobile, or data costs incurred while accessing the App.
5. Billing
All billing, when applicable, will be processed through the respective app stores or platforms, subject to their payment terms and conditions.
6. Limitation on Liability; Indemnification
The App is provided "as is" without warranty of any kind. We are not liable for any damages, including loss of data, travel disruptions, or personal injury resulting from the use of the App. Users agree to indemnify and hold harmless the company from any claims arising out of their use of the App.
7. Employees Deemed to Be Consultants
All individuals working on the App are independent consultants and not employees of the users.
8. Independent Contractor
The company operates as an independent entity and is not an agent, partner, or joint venture with users.
9. Confidential and Proprietary Information
Users agree not to misuse or disclose any proprietary information or trade secrets about the App.
10. Cooperation and Dispute Resolution
In the event of any disputes, users agree to cooperate in good faith to resolve issues. Disputes will first be addressed through informal negotiation and, if necessary, arbitration.
11. Books and Records
We maintain records of transactions and interactions within the App as required by law and for App functionality.
12. Entire Agreement; Waivers and Amendments
This document constitutes the entire agreement between the user and the company regarding the App. Any amendments must be in writing and signed by both parties.
13. Successors and Assigns
This agreement is binding upon and inures to the benefit of the parties and their respective successors and assigns.
14. No Third Party Beneficiaries
This agreement does not confer any rights or benefits on third parties.
15. Termination
The user or the company may terminate this agreement at any time. Upon termination, the user must cease all use of the App.
16. Governing Law
This agreement will be governed by and construed under the laws of the user’s primary country of residence unless otherwise stated.
17. Notices
All notices under this agreement must be in writing and will be deemed given when delivered to the registered email address associated with the user’s account.
18. Interpretation
Headings are for reference only and do not affect the meaning or interpretation of this agreement.
19. Further Assurances
Users agree to perform any additional acts required to carry out the purposes of this agreement.
20. Counterparts
This agreement may be executed in multiple counterparts, each of which will be deemed an original.""";

class TermOfService extends StatefulWidget {
  @override
  _TermOfServiceState createState() => _TermOfServiceState();
}

class _TermOfServiceState extends State<TermOfService> {
  bool isChecked = false;
  bool showError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/SC_000_Background.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.topRight,
                child: DropdownButton<String>(
                  value: "English",
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  items: <String>["English", "Vietnamese"]
                      .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                                style: const TextStyle(color: Colors.white)),
                          ))
                      .toList(),
                  onChanged: (String? newValue) {},
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Container(
                  width: 300,
                  height: 500,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Term of Service",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.orangeColor,
                        ),
                      ),
                      SizedBox(height: 15),
                      Expanded(
                        child: Scrollbar(
                          thumbVisibility: true,
                          radius: Radius.circular(10),
                          thickness: 6,
                          child: SingleChildScrollView(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                Term,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black87),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked = value!;
                      });
                    },
                  ),
                  Text(
                    "I agree with terms of service",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
              if (showError)
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    "You must agree to continue!",
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => {
                  if (isChecked) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TrustPhoneScreen(),
                      ),
                    )
                  } else{
                    setState(() {
                      showError = true;
                    })
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C00),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 75),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
