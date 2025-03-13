import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lokaloka/core/styles/colors.dart';
import 'package:lokaloka/features/itinerary/models/Itinerary.dart';
import 'package:lokaloka/features/itinerary/screens/detail_itinerary_screen.dart';

import '../../../globals.dart';

class ItineraryCreated extends StatelessWidget {
  final ItineraryResponse data;
  final image;

  const ItineraryCreated({Key? key, required this.data, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Itinerary Created'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            _buildPlanDetails(context, data),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanDetails(BuildContext context, ItineraryResponse response) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: response.itinerary.map((itinerary) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (itinerary.title?.isNotEmpty ?? false)
              Text(
                itinerary.title ?? '',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.orangeColor),
              ),
            SizedBox(height: 5),
            _buildItineraryCard(context, itinerary),
            SizedBox(height: 25),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildItineraryCard(BuildContext context, Itinerary item) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) =>
                DetailItineraryScreen(itineraryItems: item, type: "detail"),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  // child: item.locations.isNotEmpty
                  //     ? Image.network(
                  //   item.locations.first.name,
                  //   width: 80,
                  //   height: 80,
                  //   fit: BoxFit.cover,
                  //   errorBuilder: (context, error, stackTrace) {
                  //     return Icon(Icons.image_not_supported, size: 80);
                  //   },
                  // )
                  //     : Icon(Icons.image, size: 80),
                  child: Image.network(
                    image,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  )),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title ?? 'No title',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text('$travelDays Days'),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.attach_money, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text('${item.price} VND'),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text('${item.locations.length} Destinations'),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.book, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => DetailItineraryScreen(
                          itineraryItems: item, type: "detail"),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: AppColors.orangeColor,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size(0, 0),
                ),
                child: Text(
                  'View detail',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
