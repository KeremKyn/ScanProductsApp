import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // intl paketini import edin
import 'package:scan_products_app/data/ingredientRecommendation_service.dart';
import 'package:scan_products_app/models/ingredientRecommendation.dart';
import 'package:scan_products_app/screens/ingredient_rec_detail_screen.dart'; // IngredientRecDetailScreen sayfasını import edin
import 'package:scan_products_app/constants/constant.dart'; // Renk sabitlerini import edin

class VoteRecScreen extends StatefulWidget {
  @override
  _VoteRecScreenState createState() => _VoteRecScreenState();
}

class _VoteRecScreenState extends State<VoteRecScreen> {
  final IngredientRecommendationService _recommendationService = IngredientRecommendationService();
  late Future<List<IngredientRecommendation>> _recommendationsFuture;

  @override
  void initState() {
    super.initState();
    _recommendationsFuture = _recommendationService.getAllRecommendations();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM y').format(date); // Tarih formatlama işlemi
  }

  String _maskName(String name) {
    List<String> parts = name.split(' ');
    return parts.map((part) {
      if (part.isEmpty) return '';
      return part[0] + '*' * (part.length - 1);
    }).join(' ');
  }

  Future<void> _refreshRecommendations() async {
    setState(() {
      _recommendationsFuture = _recommendationService.getAllRecommendations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tavsiyeleri İncele', style: TextStyle(color: Colors.white)),
        backgroundColor: IngredientPageColor,
      ),
      body: FutureBuilder<List<IngredientRecommendation>>(
        future: _recommendationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No recommendations found.'));
          }

          List<IngredientRecommendation> recommendations = snapshot.data!;

          // Like ve dislike sayısını toplayarak sıralama
          recommendations.sort((a, b) {
            int aVotes = (a.approvalCount ?? 0) - (a.rejectionCount ?? 0);
            int bVotes = (b.approvalCount ?? 0) - (b.rejectionCount ?? 0);
            return bVotes.compareTo(aVotes);
          });

          return ListView.builder(
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              IngredientRecommendation recommendation = recommendations[index];
              String name = recommendation.isAnonymous == true
                  ? _maskName(recommendation.recommenderName ?? 'Anonim')
                  : recommendation.recommenderName ?? 'No Name';

              String description = recommendation.recommendationDescription ?? '';
              bool isLongDescription = description.length > 20;
              description = isLongDescription ? '${description.substring(0, 20)}...' : description;

              return Card(
                margin: EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  leading: CircleAvatar(
                    backgroundColor: IngredientPageColor,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    recommendation.recommendedIngredientName ?? 'No Name',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${_formatDate(recommendation.creationTime ?? DateTime.now())}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                          SizedBox(width: 8),
                          Text(
                            name,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_circle_up, color: Colors.green),
                          Text(recommendation.approvalCount.toString()),
                        ],
                      ),
                      SizedBox(width: 16),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_circle_down, color: Colors.pink),
                          Text(recommendation.rejectionCount.toString()),
                        ],
                      ),
                    ],
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IngredientRecDetailScreen(recommendation),
                      ),
                    );
                    _refreshRecommendations();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
