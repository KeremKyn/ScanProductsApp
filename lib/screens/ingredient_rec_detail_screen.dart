import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_products_app/data/ingredientRecommendation_service.dart';
import 'package:scan_products_app/models/ingredientRecommendation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:scan_products_app/constants/constant.dart';
import 'package:scan_products_app/models/comment.dart';
import 'package:intl/intl.dart';

class IngredientRecDetailScreen extends StatefulWidget {
  final IngredientRecommendation ingredientRecommendation;

  IngredientRecDetailScreen(this.ingredientRecommendation);

  @override
  _IngredientRecDetailScreenState createState() =>
      _IngredientRecDetailScreenState();
}

class _IngredientRecDetailScreenState extends State<IngredientRecDetailScreen>
    with TickerProviderStateMixin {
  final IngredientRecommendationService _recommendationService =
      IngredientRecommendationService();
  late TabController _tabController;
  late Future<List<Comment>> _commentsFuture;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _commentsFuture = _recommendationService
        .getComments(widget.ingredientRecommendation.recommendationId!);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _voteUp() {
    _recommendationService
        .incrementApprovalCount(
            widget.ingredientRecommendation.recommendationId!)
        .then((_) {
      setState(() {
        widget.ingredientRecommendation.approvalCount =
            (widget.ingredientRecommendation.approvalCount ?? 0) + 1;
      });
    });
  }

  void _voteDown() {
    _recommendationService
        .incrementRejectionCount(
            widget.ingredientRecommendation.recommendationId!)
        .then((_) {
      setState(() {
        widget.ingredientRecommendation.rejectionCount =
            (widget.ingredientRecommendation.rejectionCount ?? 0) + 1;
      });
    });
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _incrementCommentLikeCount(Comment comment) {
    _recommendationService
        .incrementCommentLikeCount(comment.commentId!)
        .then((_) {
      setState(() {
        _commentsFuture = _recommendationService
            .getComments(widget.ingredientRecommendation.recommendationId!);
      });
    });
  }

  Future<void> _submitComment() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final commentText = _commentController.text;

    if (name.isNotEmpty && email.isNotEmpty && commentText.isNotEmpty) {
      final newComment = Comment(
        null,
        widget.ingredientRecommendation.recommendationId,
        name,
        email,
        0,
        commentText,
        DateTime.now(),
      );

      await _recommendationService.addComment(newComment);
      setState(() {
        _commentsFuture = _recommendationService
            .getComments(widget.ingredientRecommendation.recommendationId!);
      });

      _nameController.clear();
      _emailController.clear();
      _commentController.clear();
      Navigator.of(context).pop(); // Close the dialog
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lütfen tüm alanları doldurun')));
    }
  }

  void _showCommentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Yorum Yap',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Adınız'),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'E-posta'),
                  ),
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(labelText: 'Yorumunuz'),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('İptal'),
                      ),
                      ElevatedButton(
                        onPressed: _submitComment,
                        child: Text('Gönder'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: IngredientPageColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isFileUrlAvailable = widget.ingredientRecommendation.fileUrl != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.ingredientRecommendation.recommendedIngredientName ??
              'Öneri Detayı',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: IngredientPageColor,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          tabs: [
            Tab(text: 'Açıklama'),
            Tab(text: 'Dosyalar'),
            Tab(text: 'Yorumlar'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDescriptionTab(),
                _buildFilesTab(isFileUrlAvailable),
                _buildCommentsTab(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          icon:
                              Icon(Icons.arrow_circle_up, color: Colors.green),
                          onPressed: _voteUp,
                          iconSize: 50,
                        ),
                        Text(
                          '${widget.ingredientRecommendation.approvalCount}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon:
                              Icon(Icons.arrow_circle_down, color: Colors.pink),
                          onPressed: _voteDown,
                          iconSize: 50,
                        ),
                        Text(
                          '${widget.ingredientRecommendation.rejectionCount}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionTab() {
    bool isNotAnonymous = widget.ingredientRecommendation.recommenderEmail != null;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.ingredientRecommendation.recommendationDescription ?? 'No Description',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (isNotAnonymous) // Anonim değilse e-posta gönderme butonu ekle
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        final email = widget.ingredientRecommendation.recommenderEmail!;
                        final Uri emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: email,
                          query: encodeQueryParameters(<String, String>{
                            'subject': 'Ingredient Recommendation Inquiry'
                          }),
                        );
                        launchUrl(emailLaunchUri);
                      },
                      child: Transform.scale(
                        scale: 2.5, // Animasyonun ölçeğini ayarlar
                        child: Lottie.network(
                          'https://lottie.host/e13048ae-65f1-491b-bc8e-bc904c6639c0/6C9WXzboTB.json',
                          width: 70,
                          height: 70,
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: 0.7, // Yazının opaklığını azaltarak arka planda tutar
                      child: Text(
                        'Uçak sizi tavsiye sahibine götürmek için hazır!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600], // Yazı rengini gri yapar
                        ),
                      ),
                    ),
                  ],
                ),


            ],
          ),
        ),
      ],
    );
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  Widget _buildFilesTab(bool isFileUrlAvailable) {
    String fileExtension = isFileUrlAvailable
        ? widget.ingredientRecommendation.fileUrl!
        .split('.')
        .last
        .split('?')
        .first
        .toUpperCase()
        : 'No File';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isFileUrlAvailable
                ? '$fileExtension dosyasını görmek için tıklayın!'
                : 'Dosya yok',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          if (isFileUrlAvailable)
            GestureDetector(
              onTap: () => _launchURL(widget.ingredientRecommendation.fileUrl!),
              child: Transform.scale(
                scale: 1, // Animasyonun ölçeğini ayarlar
                child: Lottie.network(
                  'https://lottie.host/fa6c8ffa-74eb-4f5f-b411-6150658884f4/N0Hp3tZa9I.json',
                  width: 100,
                  height: 100,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentsTab() {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<List<Comment>>(
            future: _commentsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                    child: Text(
                        'Yorumlar yüklenirken hata oluştu: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('Henüz yorum yok.'));
              } else {
                List<Comment> comments = snapshot.data!;
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    Comment comment = comments[index];
                    // AnimationController her yorum için burada oluşturuluyor
                    comment.animationController ??= AnimationController(
                      vsync: this,
                      duration: Duration(milliseconds: 500),
                    );

                    return Card(
                      margin:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment.commenterName ?? 'Anonim',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text(
                              comment.commentText ?? '',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('dd MMM yyyy').format(
                                      comment.creationTime ?? DateTime.now()),
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 12),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _incrementCommentLikeCount(comment);
                                        comment.animationController!.forward();
                                      },
                                      child: Lottie.network(
                                        'https://lottie.host/6e4ae731-6284-43d0-95cc-ed2ae66f763e/rEtXFRpCTJ.json',
                                        height: 60,
                                        width: 60,
                                        controller: comment.animationController,
                                      ),
                                    ),
                                    Text(
                                      comment.likeCount.toString(),
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
        Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 10),
          child: TextButton(
            onPressed: _showCommentDialog,
            child: Text(
              "Yorum Ekle",
              style: TextStyle(color: IngredientPageColor, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
