import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectgate/Services/auth_services.dart';
import 'package:connectgate/models/admin_model.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';

class AnswersCard extends StatefulWidget {
  final String myTitle;

  const AnswersCard({Key? key, required this.myTitle}) : super(key: key);

  @override
  _AnswersCardState createState() => _AnswersCardState();
}

class _AnswersCardState extends State<AnswersCard> {
  late Future<List<QueryDocumentSnapshot>> _futureAnswers;
  final Map<String, bool> _expandedStates = {};
  final Map<String, TextEditingController> _replyControllers = {};
  MyAppAdmins? currentAdmin;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QueryDocumentSnapshot>>(
      future: _futureAnswers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.black));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available for ${widget.myTitle}'));
        }

        final answers = snapshot.data!;
        return ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: answers.length,
          itemBuilder: (context, index) {
            final answer = answers[index];
            final answerId = answer.id;
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
                      _buildAnswerHeader(userName, finalData, answerId),
                      _buildAnswerBody(userAnswer),
                      if (_expandedStates[answerId] == true) ...[
                        _buildRepliesStream(answerId),
                        _buildReplyInput(answerId),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
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
        'admin_name': currentAdmin!.name,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding reply: $e');
    }
  }

  Widget _buildAnswerBody(String userAnswer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        userAnswer,
        softWrap: true,
        overflow: TextOverflow.clip,
        maxLines: 8,
        style: const TextStyle(
          height: 1.25,
          color: Colors.white,
          fontFamily: 'NRT',
          fontSize: 14,
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
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(400),
            ),
            child: const Icon(Icons.person_4, color: Colors.white, size: 45),
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
            ],
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              _expandedStates[answerId] == true
                  ? Icons.expand_less
                  : Icons.expand_more,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _expandedStates[answerId] =
                    !(_expandedStates[answerId] ?? false);
              });
            },
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
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, replySnapshot) {
        if (replySnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.black));
        }
        if (replySnapshot.hasError) {
          return Text('Error: ${replySnapshot.error}');
        }
        if (!replySnapshot.hasData || replySnapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final replies = replySnapshot.data!.docs;
        return Column(
          children: replies.map((reply) {
            final adminReply = reply.get('reply') as String? ?? '';
            final adminName = reply.get('admin_name') as String? ?? 'Unknown';
            final replyTimestamp = reply.get('timestamp') as Timestamp?;
            final replyDate = replyTimestamp?.toDate();

            return Padding(
              padding: const EdgeInsets.only(
                top: 4.0,
                left: 20,
                right: 20,
                bottom: 6,
              ),
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
                      adminReply,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: ElevatedButton(
            onPressed: () {
              if (_replyControllers[answerId] != null) {
                _addReply(answerId, _replyControllers[answerId]!.text);
                _replyControllers[answerId]!.clear();
              }
            },
            child: const Text('Reply'),
          ),
        ),
      ],
    );
  }

  Future<List<QueryDocumentSnapshot>> _fetchAnswers() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection(currentAdmin!.org)
          .doc(currentAdmin!.city)
          .collection('answers')
          // .where('title', isEqualTo: widget.myTitle)
          .orderBy('timestamp', descending: true)
          .get();
      return querySnapshot.docs;
    } catch (e) {
      debugPrint('Error fetching answers: $e');
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot>> _initialize() async {
    final authService = AuthService(context);
    currentAdmin = await authService.getCurrentAdmin();

    return currentAdmin != null ? _fetchAnswers() : [];
  }

  void _initializeControllers(String answerId) {
    if (!_expandedStates.containsKey(answerId)) {
      _expandedStates[answerId] = false;
      _replyControllers[answerId] = TextEditingController();
    }
  }
}
