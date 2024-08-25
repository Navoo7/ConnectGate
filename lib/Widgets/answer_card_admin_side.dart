import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectgate/Services/auth_services.dart';
import 'package:connectgate/models/admin_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_time_ago/get_time_ago.dart';

class AnswersCard extends StatefulWidget {
  final String myTitle;

  const AnswersCard({Key? key, required this.myTitle}) : super(key: key);

  @override
  _AnswersCardState createState() => _AnswersCardState();
}

class _AnswersCardState extends State<AnswersCard> {
  late Future<List<Map<String, dynamic>>> _futureAnswers;
  final Map<String, bool> _expandedStates = {};
  final Map<String, TextEditingController> _replyControllers = {};
  MyAppAdmins? currentAdmin;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureAnswers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(color: Colors.black)
                  .paddingSymmetric(vertical: 165));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No answers for "${widget.myTitle}" yet. Please check back later.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ).paddingSymmetric(vertical: 165),
          );
        }

        final answersWithCounts = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true, // Use shrinkWrap to limit the ListView's height
          physics:
              ClampingScrollPhysics(), // Prevents the ListView from expanding infinitely
          itemCount: answersWithCounts.length,
          itemBuilder: (context, index) {
            final answerWithCount = answersWithCounts[index];
            final answer = answerWithCount['document'] as QueryDocumentSnapshot;
            final answerId = answer.id;
            final replyCount = answerWithCount['replyCount'] as int;
            final userName = answer.get('user_name') as String? ?? 'Unknown';
            final userAnswer = answer.get('answer') as String? ?? 'No answer';
            final timestamp = answer.get('timestamp') as Timestamp?;
            final finalData = timestamp?.toDate();

            _initializeControllers(answerId);

            return Padding(
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
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _replyControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _futureAnswers = _initialize();
  }

  Future<void> _addReply(String answerId, String reply) async {
    if (currentAdmin == null) return;
    try {
      await FirebaseFirestore.instance
          .collection(currentAdmin!.org)
          .doc(currentAdmin!.city)
          .collection('answers')
          .doc(answerId)
          .collection('replies')
          .add({
        'reply': reply,
        'Name': currentAdmin!.name,
        'timestamp': FieldValue.serverTimestamp(),
      });
      // Update the reply count
      await _updateReplyCount(answerId);
    } catch (e) {
      debugPrint('Error adding reply: $e');
    }
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 16,
                  letterSpacing: 1.2,
                  color: Colors.white,
                  fontFamily: 'ageo-bold',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                finalData != null ? GetTimeAgo.parse(finalData) : 'N/A',
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
          const Spacer(),
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

  Widget _buildRepliesStream(String answerId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(currentAdmin!.org)
          .doc(currentAdmin!.city)
          .collection('answers')
          .doc(answerId)
          .collection('replies')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.black));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Center(
              child: Text(
                'No replies yet.',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'ageo',
                ),
              ),
            ),
          );
        }

        final replies = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(), // Prevents nested scrolling
          itemCount: replies.length,
          itemBuilder: (context, index) {
            final reply = replies[index];
            final replyText = reply.get('reply') as String? ?? 'No reply';
            final adminName = reply.get('Name') as String? ?? 'No UserName';
            final timestamp = reply.get('timestamp') as Timestamp?;
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
                          adminName,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const Spacer(),
                        Text(
                          replyDate != null
                              ? GetTimeAgo.parse(replyDate)
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.comment, color: Colors.white54, size: 14.5),
              SizedBox(width: 8),
              Text(
                'Replies: $replyCount',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          if (_expandedStates[answerId] == true) ...[
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
              if (_replyControllers[answerId] != null) {
                _addReply(answerId, _replyControllers[answerId]!.text);
                _replyControllers[answerId]!.clear();
                setState(() {}); // Refresh UI to show updated reply count
              }
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

  Future<List<Map<String, dynamic>>> _fetchAnswers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(currentAdmin!.org)
          .doc(currentAdmin!.city)
          .collection('answers')
          .where('title', isEqualTo: widget.myTitle)
          .orderBy('timestamp', descending: true)
          .get();

      final answers = snapshot.docs;
      final List<Map<String, dynamic>> answersWithReplyCounts = [];

      for (var answer in answers) {
        final answerId = answer.id;
        final replyCount = await _getReplyCount(answerId);
        answersWithReplyCounts.add({
          'document': answer,
          'replyCount': replyCount,
        });
      }

      return answersWithReplyCounts;
    } catch (e) {
      debugPrint('Error fetching answers: $e');
      return [];
    }
  }

  Future<int> _getReplyCount(String answerId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(currentAdmin!.org)
          .doc(currentAdmin!.city)
          .collection('answers')
          .doc(answerId)
          .collection('replies')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error fetching reply count: $e');
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> _initialize() async {
    try {
      currentAdmin = await AuthService(context).getCurrentAdmin();
      if (currentAdmin == null) {
        throw Exception('No admin found');
      }
      return _fetchAnswers();
    } catch (e) {
      debugPrint('Error initializing admin: $e');
      return [];
    }
  }

  void _initializeControllers(String answerId) {
    if (!_replyControllers.containsKey(answerId)) {
      _replyControllers[answerId] = TextEditingController();
    }
  }

  Future<void> _updateReplyCount(String answerId) async {
    try {
      final replySnapshot = await FirebaseFirestore.instance
          .collection(currentAdmin!.org)
          .doc(currentAdmin!.city)
          .collection('answers')
          .doc(answerId)
          .collection('replies')
          .get();
      final replyCount = replySnapshot.docs.length;

      await FirebaseFirestore.instance
          .collection(currentAdmin!.org)
          .doc(currentAdmin!.city)
          .collection('answers')
          .doc(answerId)
          .update({'replyCount': replyCount});
    } catch (e) {
      debugPrint('Error updating reply count: $e');
    }
  }
}
































































































































































































































































































































































// // Best Code

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectgate/Services/auth_services.dart';
// import 'package:connectgate/models/admin_model.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_time_ago/get_time_ago.dart';

// class AnswersCard extends StatefulWidget {
//   final String myTitle;

//   const AnswersCard({Key? key, required this.myTitle}) : super(key: key);

//   @override
//   _AnswersCardState createState() => _AnswersCardState();
// }

// class _AnswersCardState extends State<AnswersCard> {
//   late Future<List<Map<String, dynamic>>> _futureAnswers;
//   final Map<String, bool> _expandedStates = {};
//   final Map<String, TextEditingController> _replyControllers = {};
//   MyAppAdmins? currentAdmin;

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Map<String, dynamic>>>(
//       future: _futureAnswers,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator(color: Colors.black));
//         }
//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }
//         if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return Center(
//               child: Text(
//             'No answers for "${widget.myTitle}" yet. Please check back later.',
//             style: TextStyle(
//                 color: Colors.black54,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w400),
//           ));
//         }

//         final answersWithCounts = snapshot.data!;
//         return ListView.builder(
//           itemCount: answersWithCounts.length,
//           itemBuilder: (context, index) {
//             final answerWithCount = answersWithCounts[index];
//             final answer = answerWithCount['document'] as QueryDocumentSnapshot;
//             final answerId = answer.id;
//             final replyCount = answerWithCount['replyCount'] as int;
//             final userName = answer.get('user_name') as String? ?? 'Unknown';
//             final userAnswer = answer.get('answer') as String? ?? 'No answer';
//             final timestamp = answer.get('timestamp') as Timestamp?;
//             final finalData = timestamp?.toDate();

//             _initializeControllers(answerId);

//             return Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(20),
//                 child: Container(
//                   color: Color.fromARGB(221, 20, 20, 20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(height: 12),
//                       _buildAnswerHeader(userName, finalData, answerId),
//                       Divider(
//                         thickness: 1.2,
//                         color: Colors.grey[700],
//                       ).paddingSymmetric(horizontal: 22),
//                       _buildAnswerBody(userAnswer),
//                       SizedBox(height: 10),
//                       if (_expandedStates[answerId] == true) ...[
//                         _buildRepliesStream(answerId),
//                         _buildReplyInput(answerId),
//                       ],
//                       SizedBox(height: 1),
//                       _buildReplyCount(replyCount, answerId),
//                     ],
//                   ).paddingOnly(bottom: 8),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     _futureAnswers = _initialize();
//   }

//   Future<void> _addReply(String answerId, String reply) async {
//     if (currentAdmin == null) return;
//     try {
//       await FirebaseFirestore.instance
//           .collection(currentAdmin!.org)
//           .doc(currentAdmin!.city)
//           .collection('answers')
//           .doc(answerId)
//           .collection('replies')
//           .add({
//         'reply': reply,
//         'admin_name': currentAdmin!.name,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//       // Update the reply count
//       await _updateReplyCount(answerId);
//     } catch (e) {
//       debugPrint('Error adding reply: $e');
//     }
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
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 userName,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   letterSpacing: 1.2,
//                   color: Colors.white,
//                   fontFamily: 'ageo-bold',
//                 ),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 finalData != null ? GetTimeAgo.parse(finalData) : 'N/A',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   letterSpacing: 1.1,
//                   fontSize: 9,
//                   fontWeight: FontWeight.w400,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 8),
//             ],
//           ),
//           const Spacer(),
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

//   Widget _buildRepliesStream(String answerId) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection(currentAdmin!.org)
//           .doc(currentAdmin!.city)
//           .collection('answers')
//           .doc(answerId)
//           .collection('replies')
//           .orderBy('timestamp', descending: false)
//           .snapshots(),
//       builder: (context, replySnapshot) {
//         if (replySnapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator(color: Colors.black));
//         }
//         if (replySnapshot.hasError) {
//           return Text('Error: ${replySnapshot.error}');
//         }
//         if (!replySnapshot.hasData || replySnapshot.data!.docs.isEmpty) {
//           return const SizedBox.shrink();
//         }

//         final replies = replySnapshot.data!.docs;

//         return Column(
//           children: replies.map((reply) {
//             final adminReply = reply.get('reply') as String? ?? '';
//             final adminName = reply.get('admin_name') as String? ?? 'Unknown';
//             final replyTimestamp = reply.get('timestamp') as Timestamp?;
//             final replyDate = replyTimestamp?.toDate();

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
//                           adminName,
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                         const Spacer(),
//                         Text(
//                           replyDate != null
//                               ? GetTimeAgo.parse(replyDate)
//                               : 'N/A',
//                           style: const TextStyle(
//                               color: Colors.white54, fontSize: 10),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       adminReply,
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }

//   Widget _buildReplyCount(int replyCount, String answerId) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8, top: 7),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.comment, color: Colors.white54, size: 14.5),
//               SizedBox(width: 8),
//               Text(
//                 'Replies: $replyCount',
//                 style: const TextStyle(color: Colors.white54, fontSize: 12),
//               ),
//             ],
//           ),
//           if (_expandedStates[answerId] == true) ...[
//             GestureDetector(
//               onTap: () {
//                 setState(() {
//                   _expandedStates[answerId] =
//                       !(_expandedStates[answerId] ?? false);
//                 });
//               },
//               child: Icon(
//                 _expandedStates[answerId] == true
//                     ? Icons.expand_less
//                     : Icons.expand_more,
//                 color: Colors.white,
//                 size: 24,
//               ),
//             ),
//           ],
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
//               if (_replyControllers[answerId] != null) {
//                 _addReply(answerId, _replyControllers[answerId]!.text);
//                 _replyControllers[answerId]!.clear();
//                 setState(() {}); // Refresh UI to show updated reply count
//               }
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

//   Future<List<Map<String, dynamic>>> _fetchAnswers() async {
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection(currentAdmin!.org)
//           .doc(currentAdmin!.city)
//           .collection('answers')
//           .where('title', isEqualTo: widget.myTitle)
//           .orderBy('timestamp', descending: true)
//           .get();

//       final answers = snapshot.docs;
//       final List<Map<String, dynamic>> answersWithReplyCounts = [];

//       for (var answer in answers) {
//         final answerId = answer.id;
//         final replyCount = await _getReplyCount(answerId);
//         answersWithReplyCounts.add({
//           'document': answer,
//           'replyCount': replyCount,
//         });
//       }

//       return answersWithReplyCounts;
//     } catch (e) {
//       debugPrint('Error fetching answers: $e');
//       return [];
//     }
//   }

//   Future<int> _getReplyCount(String answerId) async {
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection(currentAdmin!.org)
//           .doc(currentAdmin!.city)
//           .collection('answers')
//           .doc(answerId)
//           .collection('replies')
//           .get();
//       return snapshot.docs.length;
//     } catch (e) {
//       debugPrint('Error fetching reply count: $e');
//       return 0;
//     }
//   }

//   Future<List<Map<String, dynamic>>> _initialize() async {
//     try {
//       currentAdmin = await AuthService(context).getCurrentAdmin();
//       if (currentAdmin == null) {
//         throw Exception('No admin found');
//       }
//       return _fetchAnswers();
//     } catch (e) {
//       debugPrint('Error initializing admin: $e');
//       return [];
//     }
//   }

//   void _initializeControllers(String answerId) {
//     if (!_replyControllers.containsKey(answerId)) {
//       _replyControllers[answerId] = TextEditingController();
//     }
//   }

//   Future<void> _updateReplyCount(String answerId) async {
//     try {
//       final replySnapshot = await FirebaseFirestore.instance
//           .collection(currentAdmin!.org)
//           .doc(currentAdmin!.city)
//           .collection('answers')
//           .doc(answerId)
//           .collection('replies')
//           .get();
//       final replyCount = replySnapshot.docs.length;

//       await FirebaseFirestore.instance
//           .collection(currentAdmin!.org)
//           .doc(currentAdmin!.city)
//           .collection('answers')
//           .doc(answerId)
//           .update({'replyCount': replyCount});
//     } catch (e) {
//       debugPrint('Error updating reply count: $e');
//     }
//   }
// }
