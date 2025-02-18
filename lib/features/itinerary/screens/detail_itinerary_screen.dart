import 'package:flutter/material.dart';
import '../../../core/styles/colors.dart';
import '../widgets/itinerary-app_bar.dart';
import '../models/Itinerary.dart';
import '../../../core/utils/fortmat_daytime.dart';

class DetailItineraryScreen extends StatefulWidget {
  final Itinerary itineraryItems;

  const DetailItineraryScreen({Key? key, required this.itineraryItems})
      : super(key: key);

  @override
  _DetailItineraryScreenState createState() => _DetailItineraryScreenState();
}

class _DetailItineraryScreenState extends State<DetailItineraryScreen> {
  int selectedDay = 1; //

  @override
  Widget build(BuildContext context) {
    final filteredLocations = widget.itineraryItems.locations
        .where((location) => location.day == selectedDay)
        .toList();

    return Scaffold(
      appBar: ItineraryAppBar(
        titleText: 'Create Itinerary',
        actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (index) {
                  //Thay the total day trong prompt
                  int dayNumber = index + 1;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedDay = dayNumber;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedDay == dayNumber
                            ? AppColors.orangeColor
                            : AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: Text(
                        "Day $dayNumber",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filteredLocations.isEmpty
                  ? const Center(child: Text("No locations for this day."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: filteredLocations.length,
                      itemBuilder: (context, index) {
                        final location = filteredLocations[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Destination ${index + 1}: ${location.name}',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              if (location.timeStart != null)
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                  child: Image.network(
                                    'https://letsenhance.io/static/a31ab775f44858f1d1b80ee51738f4f3/11499/EnhanceAfter.jpg',
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      location.name,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.orangeColor),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(location.description,
                                        style: const TextStyle(
                                            color: Colors.black54)),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time,
                                            color: Colors.teal),
                                        const SizedBox(width: 5),
                                        const Text("Visit duration: ",
                                            style: TextStyle(
                                                color: AppColors.primaryColor)),
                                        Text(
                                          formatVisitTime(
                                              location.timeStart.toString(),
                                              location.timeFinish.toString()),
                                          style: const TextStyle(
                                              color: Colors.black),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        const Icon(Icons.attach_money,
                                            color: Colors.teal),
                                        const SizedBox(width: 5),
                                        const Text("Cost: ",
                                            style: TextStyle(
                                                color: AppColors.primaryColor)),
                                        Text("${location.price} VND",
                                            style: const TextStyle(
                                                color: Colors.black))
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    if (location.culture != null)
                                      Row(
                                        children: [
                                          const Icon(
                                              Icons.home_repair_service_sharp,
                                              color: Colors.teal),
                                          const SizedBox(width: 5),
                                          const Text("Culture: ",
                                              style: TextStyle(
                                                  color:
                                                      AppColors.primaryColor)),
                                          Text(location.culture!,
                                              style: const TextStyle(
                                                  color: Colors.black))
                                        ],
                                      ),
                                    const SizedBox(height: 10),
                                    if (location.activities.isNotEmpty)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Activities:",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primaryColor),
                                          ),
                                          ...location.activities
                                              .map((activity) => Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 5),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            "• ${activity.name}: ${activity.description}",
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black87)),
                                                        const SizedBox(
                                                            height: 3),
                                                        Text(
                                                            "   🔹 Possible: ${activity.activitiesPossible}",
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black87)),
                                                        Text(
                                                            "   💰 Price: ${activity.price} VND",
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black87)),
                                                        Text(
                                                            "   ⚠️ Rule: ${activity.rule}",
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .red)),
                                                        Text(
                                                            "   ⭐ Recommend: ${activity.recommend}",
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .green)),
                                                      ],
                                                    ),
                                                  ))
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
