import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectgate/Services/answer_service.dart';
import 'package:connectgate/Services/auth_services.dart';
import 'package:connectgate/core/Check%20internet.dart';
import 'package:connectgate/core/NoInternet.dart';
import 'package:connectgate/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // For .paddingOnly etc.
import 'package:intl/intl.dart'; // For DateFormat
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'Open_Q_Page.dart';
import 'User_Main_Screen.dart'; // Import your main user screen

class SeeAnswersUser extends StatefulWidget {
  final Map<String, dynamic> questionData;

  const SeeAnswersUser({
    super.key,
    required this.questionData,
  });

  @override
  _SeeAnswersUserState createState() => _SeeAnswersUserState();
}

class _SeeAnswersUserState extends State<SeeAnswersUser> {
  MyAppUser? currentUser;
  late AnswerService _answerService;

  String? title;
  String? questionItself;
  String? imageUrl;

  bool _isLoading = true;

  // Variables for pagination
  final List<DocumentSnapshot> _answers = [];
  bool _isLoadingAnswers = false;
  bool _hasMoreAnswers = true;
  DocumentSnapshot? _lastAnswerDocument;
  final int _answersPerPage = 5;
  final GlobalKey _globalKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  final Map<String, bool> _expandedStates = {};
  final Map<String, TextEditingController> _replyControllers = {};

  // Variables for handling next question
  Map<int, dynamic> _questionData = {};
  Map<int, dynamic> _remainingQuestions = {};
  List<String> userGroups = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<connectivitycheck>(builder: (context, model, child) {
      if (!model.isonline) return Nointernet();

      if (_isLoading) {
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: Colors.black),
          ),
        );
      }

      if (currentUser == null) {
        return Scaffold(
          body: Center(
            child: Text('Error: User data not found'),
          ),
        );
      }

      return Scaffold(
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              expandedHeight: imageUrl?.isNotEmpty == true ? 400 : 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 60, left: 22, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // AppBar content
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child:
                                  Icon(Icons.arrow_back, color: Colors.white),
                            ),
                            Text(' '),
                            if (title != null)
                              Text(
                                title!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'NRT',
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: Icon(Icons.message,
                              color: Colors.white, size: 22),
                        ),
                        SizedBox(height: 15),
                        Center(
                          child: Text(
                            questionItself ?? '',
                            softWrap: true,
                            overflow: TextOverflow.clip,
                            maxLines: 20,
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'NRT',
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
// // // Replace your existing image display code in the FlexibleSpaceBar background:
                        if (imageUrl != null && imageUrl!.isNotEmpty)
                          RepaintBoundary(
                            key: _globalKey,
                            child: PinchZoom(
                              maxScale: 10.0,
                              child: Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl ?? '',
                                  fit: BoxFit.cover,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) =>
                                      Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ).paddingSymmetric(vertical: 8),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Include the answers as a SliverList
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == _answers.length) {
                    if (_hasMoreAnswers) {
                      return Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 1.5,
                          ),
                        ).paddingOnly(bottom: 18, top: 6),
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  }

                  final answer = _answers[index];
                  final answerId = answer.id;
                  final answerData = answer.data() as Map<String, dynamic>;
                  final userName =
                      answerData['user_name'] as String? ?? 'Unknown';
                  final userAnswer =
                      answerData['answer'] as String? ?? 'No answer';
                  final timestamp = answerData['timestamp'] as Timestamp?;
                  final finalData = timestamp?.toDate();
                  final replyCount = answerData['replyCount'] ?? 0;

                  _initializeControllers(answerId);

                  return GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          color: Color.fromARGB(221, 20, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 12),
                              _buildAnswerHeader(userName, finalData, answerId),
                              Divider(
                                thickness: 1.2,
                                color: Colors.grey[700],
                              ).paddingSymmetric(horizontal: 22),
                              _buildAnswerBody(userAnswer),
                              SizedBox(height: 10),
                              if (_expandedStates[answerId] == true) ...[
                                _buildRepliesStream(answerId),
                                _buildReplyInput(answerId),
                              ],
                              SizedBox(height: 1),
                              _buildReplyCount(replyCount, answerId),
                            ],
                          ).paddingOnly(bottom: 8),
                        ),
                      ),
                    ),
                  );
                },
                childCount: _answers.length + (_hasMoreAnswers ? 1 : 0),
              ),
            ),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(),
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _replyControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<List<String>> getCurrentUserGroups() async {
    List<String> userGroups = [];
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>?;
          Map<String, dynamic>? groupsData =
              data?['groups'] as Map<String, dynamic>?;

          if (groupsData != null) {
            userGroups.addAll(groupsData.keys);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching user groups: $e');
    }
    return userGroups;
  }

  @override
  void initState() {
    super.initState();
    _initialize();
    _scrollController.addListener(_onScroll);
  }

  Widget _buildAnswerBody(String userAnswer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Center(
        child: Text(
          userAnswer,
          softWrap: true,
          overflow: TextOverflow.clip,
          textAlign: TextAlign.center,
          maxLines: 8,
          style: const TextStyle(
            height: 1.25,
            color: Colors.white,
            fontFamily: 'NRT',
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerHeader(
      String userName, DateTime? finalData, String answerId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(400),
            ),
            child: const Icon(Icons.person_4, color: Colors.white, size: 42),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 16,
                    letterSpacing: 1.2,
                    color: Colors.white,
                    fontFamily: 'NRT',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  finalData != null
                      ? DateFormat('yyyy-MM-dd HH:mm:ss').format(finalData)
                      : 'N/A',
                  style: const TextStyle(
                    color: Colors.white,
                    letterSpacing: 1.1,
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _expandedStates[answerId] =
                    !(_expandedStates[answerId] ?? false);
              });
            },
            child: Icon(
              _expandedStates[answerId] == true
                  ? Icons.expand_less
                  : Icons.expand_more,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    return _remainingQuestions.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(bottom: 15, right: 5),
            child: FloatingActionButton(
              onPressed: _navigateToNextQuestion,
              backgroundColor: Colors.black,
              child: Icon(
                Icons.arrow_forward_ios,
                size: 22,
                color: Colors.white,
              ),
            ),
          )
        : null;
  }

  Widget _buildRepliesStream(String answerId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _answerService.getRepliesStream(answerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.black));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final replies = snapshot.data?.docs ?? [];
        if (replies.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Center(
              child: Text(
                'No replies yet.',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'NRT',
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: replies.length,
          itemBuilder: (context, index) {
            final reply = replies[index];
            final replyData = reply.data() as Map<String, dynamic>;
            final replyText = replyData['reply'] as String? ?? 'No reply';
            final userName = replyData['Name'] as String? ?? 'No UserName';
            final timestamp = replyData['timestamp'] as Timestamp?;
            final replyDate = timestamp?.toDate();

            return Padding(
              padding: const EdgeInsets.only(
                  top: 4.0, left: 20, right: 20, bottom: 6),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          userName,
                          style: const TextStyle(
                              color: Colors.white, fontFamily: 'NRT'),
                        ),
                        const Spacer(),
                        Text(
                          replyDate != null
                              ? DateFormat('yyyy-MM-dd HH:mm:ss')
                                  .format(replyDate)
                              : 'N/A',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      replyText,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReplyCount(int replyCount, String answerId) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8, top: 7),
      child: Row(
        children: [
          Icon(Icons.comment, color: Colors.white54, size: 14.5),
          SizedBox(width: 8),
          Text(
            'Replies: $replyCount',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyInput(String answerId) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 18, right: 18, top: 12),
          child: TextField(
            controller: _replyControllers[answerId],
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Write your reply...',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 2),
          child: ElevatedButton(
            onPressed: () {
              if (_replyControllers[answerId]!.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reply cannot be empty'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              _answerService.addReply(
                answerId,
                _replyControllers[answerId]!.text,
                currentUser!.name,
              );
              _replyControllers[answerId]!.clear();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white70,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Reply',
              style: TextStyle(color: Colors.black, fontSize: 13.5),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _fetchAllQuestions() async {
    if (currentUser == null) return;
    final firestore = FirebaseFirestore.instance;

    try {
      final collectionReference = firestore
          .collection(currentUser!.org)
          .doc(currentUser!.city)
          .collection('questions')
          .where('groupIds',
              arrayContainsAny: userGroups.isNotEmpty ? userGroups : [''])
          .where('createdAt',
              isGreaterThanOrEqualTo:
                  DateTime.now().subtract(Duration(hours: 24)))
          .orderBy('createdAt', descending: false);

      QuerySnapshot querySnapshot = await collectionReference.get();

      _questionData = {};
      int index = 0;
      for (var document in querySnapshot.docs) {
        final data = document.data() as Map<String, dynamic>;
        data['id'] = document.id; // Add document ID to data
        _questionData[index] = data;
        index++;
      }

      _remainingQuestions = Map.from(_questionData);
      _remainingQuestions.removeWhere((key, value) {
        return value['id'] == widget.questionData['id'];
      });

      await _filterAnsweredQuestions();
    } catch (e) {
      debugPrint('Error fetching all questions: $e');
    }
  }

  Future<void> _fetchAnswers() async {
    if (_isLoadingAnswers || !_hasMoreAnswers || title == null) return;
    setState(() {
      _isLoadingAnswers = true;
    });
    try {
      QuerySnapshot snapshot = await _answerService.getAnswers(
        title!,
        lastDoc: _lastAnswerDocument,
        limit: _answersPerPage,
      );
      if (snapshot.docs.isNotEmpty) {
        _lastAnswerDocument = snapshot.docs.last;
        setState(() {
          _answers.addAll(snapshot.docs);
        });
        if (snapshot.docs.length < _answersPerPage) {
          _hasMoreAnswers = false;
        }
      } else {
        _hasMoreAnswers = false;
      }
    } catch (e) {
      debugPrint('Error fetching answers: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAnswers = false;
        });
      }
    }
  }

  Future<void> _fetchQuestionData() async {
    if (currentUser == null) return;

    try {
      title = widget.questionData['title'] as String?;
      questionItself = widget.questionData['question'] as String?;
      imageUrl = widget.questionData['imageUrl'] as String?;
    } catch (e) {
      debugPrint('Error fetching question data: $e');
    }
  }

  Future<void> _fetchUserData() async {
    final authService = AuthService(context);
    try {
      currentUser = await authService.getCurrentUser();
      if (currentUser != null) {
        _answerService = AnswerService(
          org: currentUser!.org,
          city: currentUser!.city,
        );
      } else {
        throw Exception('User data not found');
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<void> _fetchUserGroups() async {
    try {
      final groups = await getCurrentUserGroups();
      setState(() {
        userGroups = groups;
      });
    } catch (e) {
      debugPrint('Error fetching user groups: $e');
    }
  }

  Future<void> _filterAnsweredQuestions() async {
    if (currentUser == null) return;
    final firestore = FirebaseFirestore.instance;

    try {
      final answersSnapshot = await firestore
          .collection(currentUser!.org)
          .doc(currentUser!.city)
          .collection('answers')
          .where('user_email', isEqualTo: currentUser!.email)
          .get();

      final answeredTitles = answersSnapshot.docs
          .map((doc) => (doc.data())['title'] as String)
          .toSet();

      _remainingQuestions.removeWhere((key, value) {
        return answeredTitles.contains(value['title']);
      });
    } catch (e) {
      debugPrint('Error filtering answered questions: $e');
    }
  }

  Future<void> _initialize() async {
    try {
      await _fetchUserData();
      await _fetchUserGroups();
      await _fetchQuestionData();
      await _fetchAnswers();
      await _fetchAllQuestions();
    } catch (e) {
      debugPrint('Initialization error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _initializeControllers(String answerId) {
    if (!_replyControllers.containsKey(answerId)) {
      _replyControllers[answerId] = TextEditingController();
    }
  }

  Future<void> _navigateToNextQuestion() async {
    if (_remainingQuestions.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserMainScreen(),
        ),
      );
    } else {
      final nextQuestionData = _remainingQuestions.values.first;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OpenQPage(
            questionData: nextQuestionData,
          ),
        ),
      );
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingAnswers &&
        _hasMoreAnswers) {
      _fetchAnswers();
    }
  }
}











// // see_answers_user.dart

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectgate/Services/answer_service.dart';
// import 'package:connectgate/Services/auth_services.dart';
// import 'package:connectgate/core/Check%20internet.dart';
// import 'package:connectgate/core/NoInternet.dart';
// import 'package:connectgate/models/user_model.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart'; // For .paddingOnly etc.
// import 'package:intl/intl.dart'; // For DateFormat
// import 'package:provider/provider.dart';

// import 'Open_Q_Page.dart';
// import 'User_Main_Screen.dart'; // Import your main user screen

// class SeeAnswersUser extends StatefulWidget {
//   final Map<String, dynamic> questionData;

//   const SeeAnswersUser({
//     super.key,
//     required this.questionData,
//   });

//   @override
//   _SeeAnswersUserState createState() => _SeeAnswersUserState();
// }

// class _SeeAnswersUserState extends State<SeeAnswersUser> {
//   MyAppUser? currentUser;
//   late AnswerService _answerService;

//   String? title;
//   String? questionItself;

//   bool _isLoading = true;

//   // Variables for pagination
//   final List<DocumentSnapshot> _answers = [];
//   bool _isLoadingAnswers = false;
//   bool _hasMoreAnswers = true;
//   DocumentSnapshot? _lastAnswerDocument;
//   final int _answersPerPage = 5;

//   final ScrollController _scrollController = ScrollController();

//   final Map<String, bool> _expandedStates = {};
//   final Map<String, TextEditingController> _replyControllers = {};

//   // Variables for handling next question
//   Map<int, dynamic> _questionData = {};
//   Map<int, dynamic> _remainingQuestions = {};
//   List<String> userGroups = [];

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<connectivitycheck>(builder: (context, model, child) {
//       if (!model.isonline) return Nointernet();

//       if (_isLoading) {
//         return Scaffold(
//           body: Center(
//             child: CircularProgressIndicator(color: Colors.black),
//           ),
//         );
//       }

//       if (currentUser == null) {
//         return Scaffold(
//           body: Center(
//             child: Text('Error: User data not found'),
//           ),
//         );
//       }

//       return Scaffold(
//         body: CustomScrollView(
//           controller: _scrollController,
//           slivers: [
//             SliverAppBar(
//               surfaceTintColor: Colors.transparent,
//               automaticallyImplyLeading: false,
//               expandedHeight: 245,
//               pinned: true,
//               flexibleSpace: FlexibleSpaceBar(
//                 collapseMode: CollapseMode.pin,
//                 background: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.black,
//                     borderRadius: BorderRadius.only(
//                       bottomLeft: Radius.circular(50),
//                       bottomRight: Radius.circular(50),
//                     ),
//                   ),
//                   child: Padding(
//                     padding:
//                         const EdgeInsets.only(top: 60, left: 22, right: 20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // AppBar content
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             GestureDetector(
//                               onTap: () => Navigator.pop(context),
//                               child:
//                                   Icon(Icons.arrow_back, color: Colors.white),
//                             ),
//                             Text(' '),
//                             if (title != null)
//                               Text(
//                                 title!,
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 12,
//                                   fontFamily: 'NRT',
//                                 ),
//                               ),
//                           ],
//                         ),
//                         SizedBox(height: 10),
//                         Center(
//                           child: Icon(Icons.message,
//                               color: Colors.white, size: 22),
//                         ),
//                         SizedBox(height: 15),
//                         Center(
//                           child: Text(
//                             questionItself ?? '',
//                             softWrap: true,
//                             overflow: TextOverflow.clip,
//                             maxLines: 20,
//                             textAlign: TextAlign.justify,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 14,
//                               fontFamily: 'NRT',
//                               letterSpacing: 1.2,
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 25),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             // Include the answers as a SliverList
//             SliverList(
//               delegate: SliverChildBuilderDelegate(
//                 (context, index) {
//                   if (index == _answers.length) {
//                     if (_hasMoreAnswers) {
//                       return Center(
//                         child: SizedBox(
//                           width: 24,
//                           height: 24,
//                           child: CircularProgressIndicator(
//                             color: Colors.black,
//                             strokeWidth: 1.5,
//                           ),
//                         ).paddingOnly(bottom: 18, top: 6),
//                       );
//                     } else {
//                       return SizedBox.shrink();
//                     }
//                   }

//                   final answer = _answers[index];
//                   final answerId = answer.id;
//                   final answerData = answer.data() as Map<String, dynamic>;
//                   final userName =
//                       answerData['user_name'] as String? ?? 'Unknown';
//                   final userAnswer =
//                       answerData['answer'] as String? ?? 'No answer';
//                   final timestamp = answerData['timestamp'] as Timestamp?;
//                   final finalData = timestamp?.toDate();
//                   final replyCount = answerData['replyCount'] ?? 0;

//                   _initializeControllers(answerId);

//                   return GestureDetector(
//                     onTap: () => FocusScope.of(context).unfocus(),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(20),
//                         child: Container(
//                           color: Color.fromARGB(221, 20, 20, 20),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               SizedBox(height: 12),
//                               _buildAnswerHeader(userName, finalData, answerId),
//                               Divider(
//                                 thickness: 1.2,
//                                 color: Colors.grey[700],
//                               ).paddingSymmetric(horizontal: 22),
//                               _buildAnswerBody(userAnswer),
//                               SizedBox(height: 10),
//                               if (_expandedStates[answerId] == true) ...[
//                                 _buildRepliesStream(answerId),
//                                 _buildReplyInput(answerId),
//                               ],
//                               SizedBox(height: 1),
//                               _buildReplyCount(replyCount, answerId),
//                             ],
//                           ).paddingOnly(bottom: 8),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//                 childCount: _answers.length + (_hasMoreAnswers ? 1 : 0),
//               ),
//             ),
//           ],
//         ),
//         floatingActionButton: _buildFloatingActionButton(),
//       );
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _replyControllers.forEach((_, controller) => controller.dispose());
//     super.dispose();
//   }

//   Future<List<String>> getCurrentUserGroups() async {
//     List<String> userGroups = [];
//     try {
//       final User? user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         final DocumentSnapshot userDoc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .get();

//         if (userDoc.exists) {
//           final data = userDoc.data() as Map<String, dynamic>?;
//           Map<String, dynamic>? groupsData =
//               data?['groups'] as Map<String, dynamic>?;

//           if (groupsData != null) {
//             // Add all group IDs to the userGroups list
//             userGroups.addAll(groupsData.keys);
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint('Error fetching user groups: $e');
//     }
//     return userGroups;
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initialize();
//     _scrollController.addListener(_onScroll);
//   }

//   Widget _buildAnswerBody(String userAnswer) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//       child: Center(
//         child: Text(
//           userAnswer,
//           softWrap: true,
//           overflow: TextOverflow.clip,
//           textAlign: TextAlign.center,
//           maxLines: 8,
//           style: const TextStyle(
//             height: 1.25,
//             color: Colors.white,
//             fontFamily: 'NRT',
//             fontSize: 14,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAnswerHeader(
//       String userName, DateTime? finalData, String answerId) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       child: Row(
//         children: [
//           Container(
//             height: 55,
//             width: 55,
//             decoration: BoxDecoration(
//               color: Colors.black45,
//               borderRadius: BorderRadius.circular(400),
//             ),
//             child: const Icon(Icons.person_4, color: Colors.white, size: 42),
//           ),
//           const SizedBox(width: 20),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   userName,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     letterSpacing: 1.2,
//                     color: Colors.white,
//                     fontFamily: 'NRT',
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   finalData != null
//                       ? DateFormat('yyyy-MM-dd HH:mm:ss').format(finalData)
//                       : 'N/A',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     letterSpacing: 1.1,
//                     fontSize: 9,
//                     fontWeight: FontWeight.w400,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 8),
//               ],
//             ),
//           ),
//           GestureDetector(
//             onTap: () {
//               setState(() {
//                 _expandedStates[answerId] =
//                     !(_expandedStates[answerId] ?? false);
//               });
//             },
//             child: Icon(
//               _expandedStates[answerId] == true
//                   ? Icons.expand_less
//                   : Icons.expand_more,
//               color: Colors.white,
//               size: 24,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget? _buildFloatingActionButton() {
//     return _remainingQuestions.isNotEmpty
//         ? Padding(
//             padding: const EdgeInsets.only(bottom: 15, right: 5),
//             child: FloatingActionButton(
//               onPressed: _navigateToNextQuestion,
//               backgroundColor: Colors.black,
//               child: Icon(
//                 Icons.arrow_forward_ios,
//                 size: 22,
//                 color: Colors.white,
//               ),
//             ),
//           )
//         : null;
//   }

//   Widget _buildRepliesStream(String answerId) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _answerService.getRepliesStream(answerId),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator(color: Colors.black));
//         }
//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }
//         final replies = snapshot.data?.docs ?? [];
//         if (replies.isEmpty) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//             child: Center(
//               child: Text(
//                 'No replies yet.',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 12,
//                   fontFamily: 'NRT',
//                 ),
//               ),
//             ),
//           );
//         }

//         return ListView.builder(
//           shrinkWrap: true,
//           physics: NeverScrollableScrollPhysics(),
//           itemCount: replies.length,
//           itemBuilder: (context, index) {
//             final reply = replies[index];
//             final replyData = reply.data() as Map<String, dynamic>;
//             final replyText = replyData['reply'] as String? ?? 'No reply';
//             final userName = replyData['Name'] as String? ?? 'No UserName';
//             final timestamp = replyData['timestamp'] as Timestamp?;
//             final replyDate = timestamp?.toDate();

//             return Padding(
//               padding: const EdgeInsets.only(
//                   top: 4.0, left: 20, right: 20, bottom: 6),
//               child: Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: Colors.black45,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         const Icon(Icons.person, color: Colors.white),
//                         const SizedBox(width: 10),
//                         Text(
//                           userName,
//                           style: const TextStyle(
//                               color: Colors.white, fontFamily: 'NRT'),
//                         ),
//                         const Spacer(),
//                         Text(
//                           replyDate != null
//                               ? DateFormat('yyyy-MM-dd HH:mm:ss')
//                                   .format(replyDate)
//                               : 'N/A',
//                           style: const TextStyle(
//                               color: Colors.white54, fontSize: 10),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       replyText,
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildReplyCount(int replyCount, String answerId) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8, top: 7),
//       child: Row(
//         children: [
//           Icon(Icons.comment, color: Colors.white54, size: 14.5),
//           SizedBox(width: 8),
//           Text(
//             'Replies: $replyCount',
//             style: const TextStyle(color: Colors.white54, fontSize: 12),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildReplyInput(String answerId) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 18, right: 18, top: 12),
//           child: TextField(
//             controller: _replyControllers[answerId],
//             maxLines: 3,
//             style: const TextStyle(color: Colors.white),
//             decoration: InputDecoration(
//               hintText: 'Write your reply...',
//               hintStyle: const TextStyle(color: Colors.white54),
//               filled: true,
//               fillColor: Colors.black26,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide.none,
//               ),
//             ),
//           ),
//         ),
//         Padding(
//           padding:
//               const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 2),
//           child: ElevatedButton(
//             onPressed: () {
//               if (_replyControllers[answerId]!.text.isEmpty) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('Reply cannot be empty'),
//                     backgroundColor: Colors.red,
//                   ),
//                 );
//                 return;
//               }
//               _answerService.addReply(
//                 answerId,
//                 _replyControllers[answerId]!.text,
//                 currentUser!.name,
//               );
//               _replyControllers[answerId]!.clear();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.white70,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             child: const Text(
//               'Reply',
//               style: TextStyle(color: Colors.black, fontSize: 13.5),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Future<void> _fetchAllQuestions() async {
//     if (currentUser == null) return;
//     final firestore = FirebaseFirestore.instance;

//     try {
//       final collectionReference = firestore
//           .collection(currentUser!.org)
//           .doc(currentUser!.city)
//           .collection('questions')
//           .where('groupIds',
//               arrayContainsAny: userGroups.isNotEmpty ? userGroups : [''])
//           .where('createdAt',
//               isGreaterThanOrEqualTo:
//                   DateTime.now().subtract(Duration(hours: 24)))
//           .orderBy('createdAt', descending: false);

//       QuerySnapshot querySnapshot = await collectionReference.get();

//       _questionData = {};
//       int index = 0;
//       for (var document in querySnapshot.docs) {
//         final data = document.data() as Map<String, dynamic>;
//         data['id'] = document.id; // Add document ID to data
//         _questionData[index] = data;
//         index++;
//       }

//       // Remove current question from remaining questions
//       _remainingQuestions = Map.from(_questionData);
//       _remainingQuestions.removeWhere((key, value) {
//         return value['id'] == widget.questionData['id'];
//       });

//       // Filter out questions that the user has already answered
//       await _filterAnsweredQuestions();
//     } catch (e) {
//       debugPrint('Error fetching all questions: $e');
//     }
//   }

//   Future<void> _fetchAnswers() async {
//     if (_isLoadingAnswers || !_hasMoreAnswers || title == null) return;
//     setState(() {
//       _isLoadingAnswers = true;
//     });
//     try {
//       QuerySnapshot snapshot = await _answerService.getAnswers(
//         title!,
//         lastDoc: _lastAnswerDocument,
//         limit: _answersPerPage,
//       );
//       if (snapshot.docs.isNotEmpty) {
//         _lastAnswerDocument = snapshot.docs.last;
//         setState(() {
//           _answers.addAll(snapshot.docs);
//         });
//         if (snapshot.docs.length < _answersPerPage) {
//           _hasMoreAnswers = false;
//         }
//       } else {
//         _hasMoreAnswers = false;
//       }
//     } catch (e) {
//       debugPrint('Error fetching answers: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoadingAnswers = false;
//         });
//       }
//     }
//   }

//   Future<void> _fetchQuestionData() async {
//     if (currentUser == null) return;

//     try {
//       title = widget.questionData['title'] as String?;
//       questionItself = widget.questionData['question'] as String?;
//     } catch (e) {
//       debugPrint('Error fetching question data: $e');
//     }
//   }

//   Future<void> _fetchUserData() async {
//     final authService = AuthService(context);
//     try {
//       currentUser = await authService.getCurrentUser();
//       if (currentUser != null) {
//         _answerService = AnswerService(
//           org: currentUser!.org,
//           city: currentUser!.city,
//         );
//       } else {
//         throw Exception('User data not found');
//       }
//     } catch (e) {
//       debugPrint('Error fetching user data: $e');
//     }
//   }

//   Future<void> _fetchUserGroups() async {
//     try {
//       final groups = await getCurrentUserGroups();
//       setState(() {
//         userGroups = groups;
//       });
//     } catch (e) {
//       debugPrint('Error fetching user groups: $e');
//     }
//   }

//   Future<void> _filterAnsweredQuestions() async {
//     if (currentUser == null) return;
//     final firestore = FirebaseFirestore.instance;

//     try {
//       final answersSnapshot = await firestore
//           .collection(currentUser!.org)
//           .doc(currentUser!.city)
//           .collection('answers')
//           .where('user_email', isEqualTo: currentUser!.email)
//           .get();

//       final answeredTitles = answersSnapshot.docs
//           .map((doc) => (doc.data())['title'] as String)
//           .toSet();

//       _remainingQuestions.removeWhere((key, value) {
//         return answeredTitles.contains(value['title']);
//       });
//     } catch (e) {
//       debugPrint('Error filtering answered questions: $e');
//     }
//   }

//   Future<void> _initialize() async {
//     try {
//       await _fetchUserData();
//       await _fetchUserGroups();
//       await _fetchQuestionData();
//       await _fetchAnswers();
//       await _fetchAllQuestions();
//     } catch (e) {
//       debugPrint('Initialization error: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   void _initializeControllers(String answerId) {
//     if (!_replyControllers.containsKey(answerId)) {
//       _replyControllers[answerId] = TextEditingController();
//     }
//   }

//   Future<void> _navigateToNextQuestion() async {
//     if (_remainingQuestions.isEmpty) {
//       // No more questions, navigate to main screen or desired page
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => UserMainScreen(),
//         ),
//       );
//     } else {
//       // Navigate to next question
//       final nextQuestionData = _remainingQuestions.values.first;
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => OpenQPage(
//             questionData: nextQuestionData,
//           ),
//         ),
//       );
//     }
//   }

//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//             _scrollController.position.maxScrollExtent - 200 &&
//         !_isLoadingAnswers &&
//         _hasMoreAnswers) {
//       _fetchAnswers();
//     }
//   }
// }







































































































































































































































































































































































































































































































































































































































































// // ignore_for_file: camel_case_types, prefer_const_constructors, prefer_const_constructors_in_immutables, unused_local_variable, unnecessary_new, prefer_const_literals_to_create_immutables, non_constant_identifier_names, avoid_function_literals_in_foreach_calls, avoid_print, sized_box_for_whitespace, unnecessary_null_comparison, depend_on_referenced_packages, no_leading_underscores_for_local_identifiers, use_build_context_synchronously

// import 'dart:math';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectgate/Screen/User_Side/Open_Q_Page.dart';
// import 'package:connectgate/Screen/User_Side/User_Main_Screen.dart';
// import 'package:connectgate/Services/auth_services.dart';
// import 'package:connectgate/core/Check%20internet.dart';
// import 'package:connectgate/core/NoInternet.dart';
// import 'package:connectgate/models/user_model.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get_time_ago/get_time_ago.dart';
// import 'package:provider/provider.dart';

// class SeeAnsweres extends StatefulWidget {
//   // final Map<String, dynamic> answeresData;
//   final Map<String, dynamic> questionData;
//   // final int totalQuestions;
//   SeeAnsweres({
//     super.key,
//     required this.questionData,
//   });

//   @override
//   State<SeeAnsweres> createState() => _SeeAnsweresState();
// }

// class _SeeAnsweresState extends State<SeeAnsweres> {
//   Map<int, dynamic> _questionData = {};
//   Map<int, dynamic> _questionData2 = {};

//   List<String> userGroups = [];
//   int currentQuestionIndex = 0;

//   // bool visible = true;
//   MyAppUser? currentUser;

//   Widget answares_card(String myTitle) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: currentUser != null
//           ? FirebaseFirestore.instance
//               .collection(currentUser!.org)
//               .doc(currentUser!.city)
//               .collection('answers')
//               .where('title', isEqualTo: myTitle)
//               .orderBy('timestamp', descending: true) // Add orderBy clause here
//               .snapshots()
//           : Stream.empty(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: CircularProgressIndicator(
//               color: Colors.black,
//             ),
//           );
//         } else if (snapshot.hasError) {
//           return Text('Error: ${snapshot.error}');
//         } else if (!snapshot.hasData || snapshot.data == null) {
//           return Center(
//             child: SizedBox(
//                 height: 20,
//                 width: 20,
//                 child: CircularProgressIndicator(
//                   color: Colors.black,
//                 )),
//           );
//         } else {
//           final answers = snapshot.data!.docs;

//           return ListView.builder(
//             scrollDirection: Axis.vertical,
//             itemCount: answers.length,
//             itemBuilder: (context, index) {
//               final answer = answers[index];
//               final userName = answer.get('user_name');
//               final userAnswer = answer.get('answer');
//               // final timestamp = answer.get('timestamp') as Timestamp;
//               final timestamp = answer.get('timestamp') as Timestamp?;

//               final finalData = timestamp != null
//                   ? DateTime.parse(timestamp.toDate().toString())
//                   : null;
//               return Padding(
//                 padding: const EdgeInsets.only(
//                     top: 2.5, left: 16, bottom: 16, right: 16),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(20),
//                   child: Container(
//                     color: Color.fromARGB(221, 20, 20, 20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 20, vertical: 10),
//                           child: Wrap(
//                             children: [
//                               Column(
//                                 children: [
//                                   SizedBox(
//                                     height: 8,
//                                   ),
//                                   Row(
//                                     children: [
//                                       Container(
//                                         height: 65,
//                                         width: 65,
//                                         decoration: BoxDecoration(
//                                             color: Colors.black,
//                                             borderRadius:
//                                                 BorderRadius.circular(400)),
//                                         child: const Icon(
//                                           Icons.person_4,
//                                           color: Colors.white,
//                                           size: 45,
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         width: 20,
//                                       ),
//                                       Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.start,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             userName,
//                                             style: const TextStyle(
//                                                 fontSize: 16,
//                                                 letterSpacing: 1.2,
//                                                 color: Colors.white,
//                                                 fontFamily: 'ageo-bold'),
//                                           ),
//                                           SizedBox(
//                                             height: 6,
//                                           ),
//                                           Text(
//                                             finalData != null
//                                                 ? GetTimeAgo.parse(finalData)
//                                                 : 'N/A', // Display 'N/A' while loading
//                                             style: TextStyle(
//                                                 color: Colors.white,
//                                                 //fontFamily: 'ageo',
//                                                 letterSpacing: 1.1,
//                                                 fontSize: 9,
//                                                 fontWeight: FontWeight.w400),
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                   const Padding(
//                                     padding: EdgeInsets.only(left: 84.0),
//                                     child: Divider(
//                                       color: Colors.white30,
//                                       thickness: 1.4,
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: 10,
//                                   ),
//                                   Text(
//                                     userAnswer,
//                                     softWrap: true,
//                                     overflow: TextOverflow.clip,
//                                     maxLines: 8,
//                                     textAlign: TextAlign.justify,
//                                     style: TextStyle(
//                                         height: 1.25,
//                                         color: Colors.white,
//                                         fontFamily: 'NRT',
//                                         fontSize: 14),
//                                   ),
//                                   SizedBox(
//                                     height: 9,
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         }
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final questionData = widget.questionData;

//     final groupname = questionData['groupname'] as String;
//     final title = questionData['title'] as String;
//     final timestamp = questionData['createdAt'] as Timestamp;
//     final questionitself = questionData['question'] as String;
//     final questiontype = questionData['type'] as String;

//     final options =
//         questionData['options'] as List<dynamic>; // Cast options as a List
//     // getAnswers(title);
//     return Consumer<connectivitycheck>(builder: (context, modle, child) {
//       if (modle.isonline != null) {
//         return modle.isonline
//             ? Stack(
//                 children: [
//                   Scaffold(
//                     backgroundColor: Colors.white,
//                     body: GestureDetector(
//                       onTap: () {
//                         FocusScope.of(context).requestFocus(
//                           new FocusNode(),
//                         );
//                       },
//                       child: SingleChildScrollView(
//                         // reverse: true,
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 Container(
//                                   height: 290,
//                                   constraints: BoxConstraints(
//                                     maxHeight:
//                                         MediaQuery.of(context).size.height,
//                                     maxWidth: MediaQuery.of(context).size.width,
//                                   ),
//                                   decoration: const BoxDecoration(
//                                     color: Colors.black,
//                                     borderRadius: BorderRadius.only(
//                                       bottomLeft: Radius.circular(50),
//                                       bottomRight: Radius.circular(50),
//                                     ),
//                                   ),
//                                   child: Wrap(
//                                     alignment: WrapAlignment.start,
//                                     children: [
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             top: 60, left: 22, right: 20),
//                                         child: Wrap(
//                                           children: [
//                                             Column(
//                                               children: [
//                                                 Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .spaceBetween,
//                                                   children: [
//                                                     Align(
//                                                       alignment:
//                                                           Alignment.topLeft,
//                                                       child: GestureDetector(
//                                                         onTap: () =>
//                                                             Navigator.pop(
//                                                                 context),
//                                                         child: const Icon(
//                                                           Icons.arrow_back,
//                                                           color: Colors.white,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     Text(
//                                                       title,
//                                                       style: TextStyle(
//                                                           color: Colors.white,
//                                                           fontSize: 12,
//                                                           fontFamily: 'NRT'),
//                                                     )
//                                                   ],
//                                                 ),
//                                                 const SizedBox(
//                                                   height: 15,
//                                                   width: double.infinity,
//                                                 ),
//                                                 const Center(
//                                                   child: Icon(
//                                                     Icons.message,
//                                                     color: Colors.white,
//                                                     size: 22,
//                                                   ),
//                                                 ),
//                                                 const SizedBox(
//                                                   height: 15,
//                                                   width: double.infinity,
//                                                 ),
//                                                 Center(
//                                                   child: Text(
//                                                     questionitself,
//                                                     softWrap: true,
//                                                     overflow: TextOverflow.clip,
//                                                     maxLines: 15,
//                                                     textAlign:
//                                                         TextAlign.justify,
//                                                     style: TextStyle(
//                                                       color: Colors.white,
//                                                       fontSize: 14,
//                                                       fontFamily: 'NRT',
//                                                       letterSpacing: ln2,
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 const SizedBox(height: 15),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Column(
//                               children: [
//                                 Container(
//                                   width: double.infinity,
//                                   height: 650,
//                                   child: answares_card(title),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 40, right: 40),
//                     child: Align(
//                       alignment: Alignment.bottomRight,
//                       child: Visibility(
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             await _initializeQuestions(); // Start initializing questions
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.black,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(50.0),
//                             ),
//                           ),
//                           child: Icon(
//                             Icons.arrow_forward_ios,
//                             size: 22,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   )
//                 ],
//               )
//             : Nointernet();
//       }
//       return CircularProgressIndicator(
//         color: Colors.black,
//       );
//     });
//   }

//   @override
//   void dispose() {
//     _questionData = {};
//     // _questionData2 = {};
//     super.dispose();
//   }

//   Future<void> fetchUserData() async {
//     AuthService authService = AuthService(context);
//     MyAppUser? userData = (await authService.getCurrentUser());
//     setState(() {
//       currentUser = userData;
//     });
//   }

//   Future<void> fetchUserGroups() async {
//     try {
//       final groups = await getCurrentUserGroups();
//       setState(() {
//         userGroups = groups;
//       });
//     } catch (e) {
//       print('Error fetching user groups: $e');
//     }
//   }

//   Future<void> get_all_questions() async {
//     final firestore = FirebaseFirestore.instance;

//     // Reference to your Firestore collection
//     await Future.delayed(const Duration(seconds: 1));
//     final collectionReference = firestore
//         .collection(currentUser!.org)
//         .doc(currentUser!.city)
//         .collection('questions')
//         .where('groupIds',
//             arrayContainsAny: userGroups.isNotEmpty
//                 ? userGroups
//                 : ['']) // Ensure userGroups is not empty
//         .where('createdAt',
//             isGreaterThanOrEqualTo: DateTime.now().subtract(Duration(
//                 hours: 24))) // Filter out questions older than 24 hours
//         .orderBy('createdAt', descending: false);
//     // Query the collection and get all documents
//     QuerySnapshot querySnapshot = await collectionReference.get();

//     // Initialize an empty map to store the document data
//     // _questionData = {};
//     // Loop through the documents and add them to the map
//     int index = 0;
//     _questionData = {};
//     querySnapshot.docs.forEach((document) {
//       final title = document.get("title") as String;
//       final timestamp = document.get('createdAt') as Timestamp;
//       final questionitself = document.get('question') as String;
//       final questiontype = document.get('type') as String;
//       final options = document.get('options') as List<dynamic>;
//       final groupname = document.get('groupname') as String;

//       ///
//       ///

//       final questionData = {
//         'title': title, // Replace with the actual data you want to pass
//         'createdAt': timestamp, // Replace with the actual data you want to pass
//         // Add more fields as needed
//         'question': questionitself,
//         'type': questiontype,
//         'options': options,
//         'groupname': groupname,
//       };

//       _questionData.addAll({index: questionData});

//       index++;
//     });
//     // Rename get_all_questions to _initializeQuestions and make it async

// //this is for ansawared questions checker

//     final firestore2 = FirebaseFirestore.instance;
//     await Future.delayed(const Duration(seconds: 1));
//     // Reference to your Firestore collection
//     final collectionReference2 = firestore2
//         .collection(currentUser!.org)
//         .doc(currentUser!.city)
//         .collection('answers')
//         .where('user_email',
//             isEqualTo: FirebaseAuth.instance.currentUser?.email);

//     // Query the collection and get all documents
//     QuerySnapshot querySnapshot2 = await collectionReference2.get();

//     // Initialize an empty map to store the document data
//     if (querySnapshot2.docs.isEmpty) {
//       return;
//     }

//     // Loop through the documents and add them to the map
//     querySnapshot2.docs.forEach((document) {
//       _questionData.removeWhere((key, value) {
//         return value['title'] == document.get("title") as String;
//       });

//       _questionData2 = _questionData;
//     });
//   }

//   // Function to retrieve current user's group IDs
//   Future<List<String>> getCurrentUserGroups() async {
//     List<String> userGroups = [];
//     try {
//       final User? user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         final DocumentSnapshot userDoc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .get();

//         if (userDoc.exists) {
//           Map<String, dynamic>? groupsData = userDoc['groups'];

//           if (groupsData != null) {
//             // Add all group IDs to the userGroups list
//             userGroups.addAll(groupsData.keys);
//           }
//         }
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//     return userGroups;
//   }

//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(seconds: 1));
//     fetchUserData();
//     fetchUserGroups();
//     getCurrentUserGroups();
//     // _initializeQuestions();
//   }

//   Future<void> _initializeQuestions() async {
//     Future.delayed(const Duration(seconds: 1));
//     await get_all_questions();
//     // Future.delayed(const Duration(seconds: 1));
//     if (mounted) {
//       // Check if the widget is still mounted
//       if (_questionData2.keys.isEmpty) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => UserMainScreen(),
//           ),
//         );
//       } else {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => OpenQPage(
//               questionData: _questionData[_questionData2.keys.first],
//             ),
//           ),
//         );
//       }
//     }
//   }
// }
