import 'package:flutter/material.dart';
import '../../../core/utils/apis.dart';
import '../../../core/utils/transfer_money.dart';
import '../../../globals.dart';
import '../widgets/itinerary-app_bar.dart';
import '../../../core/styles/colors.dart';
import 'created_2itinerary_screen.dart';
import '../models/Itinerary.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CreateByAi extends StatefulWidget {
  final String location;
  final String totalDay;
  final String startDate;
  final String endDate;

  const CreateByAi({
    super.key,
    required this.location,
    required this.totalDay,
    required this.startDate,
    required this.endDate,
  });

  @override
  _CreateByAiState createState() => _CreateByAiState();
}

class _CreateByAiState extends State<CreateByAi> {
  final TextEditingController _budgetController = TextEditingController();
  bool isPending = false;
  final _formKey = GlobalKey<FormState>();
  bool _isInterestValid = true;

  Map<String, bool> _interests = {
    'Cultural experiences': false,
    'Museums': false,
    'Shopping': false,
    'Outdoor activities': false,
    'Relaxation': false,
    'Beach': false,
  };

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  final ApiService _apiService = ApiService();

  Future<void> _sendDataToBackend() async {
    try {
      final String dateInfo =
          (widget.startDate.isNotEmpty && widget.endDate.isNotEmpty)
              ? "from ${widget.startDate} to ${widget.endDate} "
              : "";

      final String budgetText = _budgetController.text.trim();
      final String formattedBudget = budgetText.isNotEmpty
          ? CurrencyFormatter.format(budgetText)
          : "Not specified";

      int night = int.parse(widget.totalDay);
      night = night - 1;

      final String prompt =
          "I want to have travel schedule ${dateInfo}in ${widget.location} for ${widget.totalDay} Days and $night. "
          "With my budget is $formattedBudget. "
          "I am interested in activities such as: ${_interests.entries.where((entry) => entry.value).map((entry) => entry.key).join(', ')}."
          "At least 4 location in one day. "
          "Important: Please generate for me 2 type plan for me to select.";

      final Map<String, dynamic> requestData = {
        'prompt': prompt,
      };
      try {
        final response = await _apiService.request(
          path: '/itineraries/generate',
          method: 'POST',
          typeUrl: 'baseUrl',
          currentPath: '',
          data: requestData,
        );

        final itineraryResponse = parseItineraryResponse(response.body);

        //Fetch images for location
        // String name = itineraryResponse.itinerary;
        String? imageItinerary = await ApiService().fetchImageUrl(cityTrip!);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItineraryCreated(data: itineraryResponse, image: imageItinerary),
            settings: RouteSettings(name: '/my-trip/itinerary-created'),
          ),
        );
      } catch (e) {
        print("Lỗi khi xử lý JSON: $e");
      }
    } catch (error) {
      _showResponseDialog('Error', 'Failed to plan trip: $error');
    }
  }

  void _showResponseDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ItineraryAppBar(
        titleText: 'Create Itinerary',
        actions: [],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "What is your budget range for the trip?",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Budget",
                        hintText: "Eg: 5000000 VND",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a budget';
                        }
                        if (!RegExp(r'^\d+$').hasMatch(value)) {
                          return 'Only numbers are allowed';
                        }
                        if (int.tryParse(value)! <= 0) {
                          return 'Budget must be greater than 0';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      "What are your interests?",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor),
                    ),
                    SizedBox(height: 10),
                    ..._interests.keys.map((interest) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: CheckboxListTile(
                          title: Text(interest),
                          value: _interests[interest],
                          activeColor: AppColors.orangeColor,
                          onChanged: (bool? value) {
                            setState(() {
                              _interests[interest] = value!;
                              _isInterestValid = _interests
                                  .containsValue(true);
                            });
                          },
                          controlAffinity: ListTileControlAffinity.trailing,
                        ),
                      );
                    }).toList(),
                    if (!_isInterestValid)
                      Padding(
                        padding: const EdgeInsets.only(top: 5, left: 10),
                        child: Text(
                          'Please select at least one interest.',
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    SizedBox(height: 30),
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isPending ? null : _handleStartPlanning,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orangeColor,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text(
                            'Start planning',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isPending)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: LoadingAnimationWidget.threeRotatingDots(
                  color: AppColors.orangeColor,
                  size: 80,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleStartPlanning() async {
    setState(() {
      _isInterestValid = _interests.containsValue(true);
    });

    if (!_formKey.currentState!.validate() || !_isInterestValid) {
      return;
    }

    setState(() {
      isPending = true;
    });

    await _sendDataToBackend();

    setState(() {
      isPending = false;
    });
    setState(() {});
  }
}
