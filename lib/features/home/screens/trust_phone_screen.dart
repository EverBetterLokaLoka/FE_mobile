import 'package:flutter/material.dart';
import '../../../core/styles/colors.dart';

class TrustPhoneScreen extends StatefulWidget {
  const TrustPhoneScreen({super.key});

  @override
  _TrustPhoneScreenState createState() => _TrustPhoneScreenState();
}

class _TrustPhoneScreenState extends State<TrustPhoneScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController phoneController1 = TextEditingController();

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (!RegExp(r'^\d{10,11}$').hasMatch(value)) {
      return "⚠ Invalid phone number.";
    }
    return null;
  }

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 15),
                      Align(
                        alignment: Alignment.topRight,
                        child: DropdownButton<String>(
                          value: "English",
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.black),
                          items: <String>["English", "Vietnamese"]
                              .map((String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value,
                                        style: const TextStyle(
                                            color: Colors.black)),
                                  ))
                              .toList(),
                          onChanged: (String? newValue) {},
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    "Welcome",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.orangeColor,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "This feature is designed to assist users in emergency situations or inconveniences, such as falling off a bike, accidents, or running out of gas. When you send out an emergency signal, other users in the nearby area who are also using the app will receive notifications and can quickly come to your aid. This not only helps you get timely assistance but also fosters a safe and reliable community.",
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 10),
                                  Center(
                                    child: const Text(
                                      "You are not alone in difficult times!",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFFFF8C00),
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 15),

                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Emergency Numbers",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                  buildPhoneInput(phoneController1),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Finish Button
                            ElevatedButton(
                              onPressed: () => {
                                if (_formKey.currentState!.validate()) {
                                  Navigator.pushNamed(context, '/home')
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF8C00),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 75),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                "Finish",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
              ))),
    );
  }

  Widget buildPhoneInput(TextEditingController controller) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: "Enter trust phone number",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            prefixIcon: const Icon(Icons.phone),
          ),
          validator: validatePhone,
        ),
      ],
    );
  }
}
