// see_answers_admin.dart

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart'; // For zipping files
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectgate/Services/answer_service.dart';
import 'package:connectgate/Services/auth_services.dart';
import 'package:connectgate/Widgets/pie_cahrt_widgets.dart';
import 'package:connectgate/core/Check%20internet.dart';
import 'package:connectgate/core/NoInternet.dart';
import 'package:connectgate/models/admin_model.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // For .paddingOnly etc.
import 'package:intl/intl.dart'; // For timestamp formatting
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class SeeAnswersAdmin extends StatefulWidget {
  final Map<String, dynamic> questionData;
  final String questionId;

  const SeeAnswersAdmin({
    super.key,
    required this.questionData,
    required this.questionId,
  });

  @override
  _SeeAnswersAdminState createState() => _SeeAnswersAdminState();
}

class _SeeAnswersAdminState extends State<SeeAnswersAdmin> {
  MyAppAdmins? currentAdmin;
  late AnswerService _answerService;

  Map<String, double> optionPercentages = {};
  String? title;
  String? questionItself;
  String? questionType;
  String? groupName;

  bool _isLoading = true;
  bool _isDownloading = false;

  // Variables for pagination
  final List<DocumentSnapshot> _answers = [];
  bool _isLoadingAnswers = false;
  bool _hasMoreAnswers = true;
  DocumentSnapshot? _lastAnswerDocument;
  final int _answersPerPage = 5;

  final ScrollController _scrollController = ScrollController();

  final Map<String, bool> _expandedStates = {};
  final Map<String, TextEditingController> _replyControllers = {};

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

      if (currentAdmin == null) {
        return Scaffold(
          body: Center(
            child: Text('Error: Admin data not found'),
          ),
        );
      }

      return Scaffold(
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Your existing SliverAppBar and SliverList code

            SliverAppBar(
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              expandedHeight: 245,
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (questionType == 'MultipleChoice')
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: PieChartWidget(
                    optionPercentages: optionPercentages,
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
        floatingActionButton: FloatingActionButton(
          onPressed: _isDownloading ? null : downloadCSV,
          backgroundColor: Colors.black,
          child: _isDownloading
              ? SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 1.4,
                  ))
              : Icon(Icons.download_rounded, color: Colors.white),
        ),
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _replyControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> downloadCSV() async {
    if (title == null || currentAdmin == null || _isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      // Fetch all answers as QuerySnapshot
      QuerySnapshot answersSnapshot =
          await _answerService.getAllAnswersSnapshot(title!);

      List<List<dynamic>> answersData = [];
      List<List<dynamic>> repliesData = [];

      int answerIndex = 1;
      for (var doc in answersSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String answerId = doc.id;
        String userName = data['user_name'] ?? 'Unknown';
        String userEmail = data['user_email'] ?? 'Unknown';
        String userAnswer = data['answer'] ?? 'No answer';
        String timestamp = data['timestamp'] != null
            ? (data['timestamp'] as Timestamp).toDate().toIso8601String()
            : '';

        answersData.add([
          userName,
          userEmail,
          userAnswer,
          timestamp,
          answerId, // Include answerId for later use
        ]);

        // Fetch replies for this answer
        List<Map<String, dynamic>> replies =
            await _answerService.getRepliesData(answerId);

        int replyIndex = 1;
        for (var reply in replies) {
          String replyText = reply['replyText'] ?? '';
          String adminName = reply['adminName'] ?? '';
          String replyTimestamp = reply['timestamp'] ?? '';

          repliesData.add([
            replyIndex, // Reply Index
            answerIndex, // Answer Index
            answerId, // Answer ID
            userName, // Answerer Name
            userEmail, // Answerer Email
            userAnswer, // Answer Text
            adminName, // Replied Name
            replyText, // Reply Text
            replyTimestamp, // Timestamp
          ]);

          replyIndex++;
        }

        // Add a separator between answers
        repliesData.add([]);
        answerIndex++;
      }

      // Generate CSV data for answers (No changes as per your request)
      final answersCSVData =
          _generateAnswersCSVData(widget.questionData, answersData);

      // Save answers CSV file
      final directory = await getTemporaryDirectory();
      final answersFilePath = '${directory.path}/${title!}-answers.csv';
      final answersFile = File(answersFilePath);
      final answersCSVFile = const ListToCsvConverter().convert(answersCSVData);
      await answersFile.writeAsString(answersCSVFile, encoding: utf8);

      // Generate CSV data for replies
      String? repliesFilePath;
      if (repliesData.isNotEmpty) {
        final repliesCSVData = _generateRepliesCSVData(repliesData);
        // Save replies CSV file
        repliesFilePath = '${directory.path}/${title!}-replies.csv';
        final repliesFile = File(repliesFilePath);
        final repliesCSVFile =
            const ListToCsvConverter().convert(repliesCSVData);
        await repliesFile.writeAsString(repliesCSVFile, encoding: utf8);
      }

      // Generate CSV data for analyze (No changes as per your request)
      String? analyzeFilePath;
      if (questionType == 'MultipleChoice' && optionPercentages.isNotEmpty) {
        final analyzeCSVData =
            _generateAnalyzeCSVData(widget.questionData, optionPercentages);
        // Save analyze CSV file
        analyzeFilePath = '${directory.path}/${title!}-percentage.csv';
        final analyzeFile = File(analyzeFilePath);
        final analyzeCSVFile =
            const ListToCsvConverter().convert(analyzeCSVData);
        await analyzeFile.writeAsString(analyzeCSVFile, encoding: utf8);
      }

      // Create a text file with professional content
      String textFilePath = '${directory.path}/${title!}.txt';
      final textFile = File(textFilePath);
      String textContent =
          'Question "${title!}" saved on ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())} by ${currentAdmin!.name} in ${currentAdmin!.org}/${currentAdmin!.city}.';
      await textFile.writeAsString(textContent, encoding: utf8);

      // Create a zip file containing all the files
      final zipFilePath = '${directory.path}/${title!}-files.zip';
      final zipEncoder = ZipFileEncoder();
      zipEncoder.create(zipFilePath);
      zipEncoder.addFile(answersFile);
      if (repliesFilePath != null) {
        zipEncoder.addFile(File(repliesFilePath));
      }
      if (analyzeFilePath != null) {
        zipEncoder.addFile(File(analyzeFilePath));
      }
      zipEncoder.addFile(textFile);
      zipEncoder.close();

      // Share the zip file
      await Share.shareFiles([zipFilePath]);
    } catch (e) {
      print('Error downloading CSV: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
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
          Column(
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
      stream: _answerService.getRepliesStream(answerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.black));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final replies = snapshot.data!.docs;
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
            final adminName = replyData['Name'] as String? ?? 'No UserName';
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
                          adminName,
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
                return;
              }
              _answerService.addReply(
                answerId,
                _replyControllers[answerId]!.text,
                currentAdmin!.name,
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
      print('Error fetching answers: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAnswers = false;
        });
      }
    }
  }

  Future<void> _fetchOptionPercentages() async {
    if (currentAdmin == null || title == null) return;
    try {
      if (widget.questionData['options'] != null) {
        final percentages = await _answerService.calculateOptionPercentages(
          title!,
          widget.questionData['options'],
        );
        if (mounted) {
          setState(() {
            optionPercentages = percentages;
          });
        }
      }
    } catch (e) {
      print('Error fetching option percentages: $e');
    }
  }

  Future<void> _fetchQuestionData() async {
    if (currentAdmin == null) return;

    try {
      final questionDoc = await FirebaseFirestore.instance
          .collection(currentAdmin!.org)
          .doc(currentAdmin!.city)
          .collection('questions')
          .doc(widget.questionId)
          .get();

      if (!questionDoc.exists) return;

      final questionData = questionDoc.data() as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          title = questionData['title'] as String?;
          questionItself = questionData['question'] as String?;
          groupName = questionData['groupname'] as String?;
          questionType = questionData['type'] as String?;
        });
      }
    } catch (e) {
      print('Error fetching question data: $e');
    }
  }

  Future<void> _fetchUserData() async {
    final authService = AuthService(context);
    try {
      currentAdmin = await authService.getCurrentAdmin();
      if (currentAdmin != null) {
        _answerService = AnswerService(
          org: currentAdmin!.org,
          city: currentAdmin!.city,
        );
      } else {
        throw Exception('Admin data not found');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // No changes to this function as per your request
  List<List<dynamic>> _generateAnalyzeCSVData(
    Map<String, dynamic> questionData,
    Map<String, double> optionPercentages,
  ) {
    List<List<dynamic>> rows = [];

    // Header
    rows.add(['Question Analysis']);

    final title = questionData['title'] as String? ?? '';
    final questionItself = questionData['question'] as String? ?? '';
    final groupName = questionData['groupname'] as String? ?? '';
    final questionType = questionData['type'] as String? ?? '';

    // Question Info
    rows.add(['Question Title', title]);
    rows.add(['Question Text', questionItself]);
    rows.add(['Question Group', groupName]);
    rows.add(['Question Type', questionType]);

    // Empty row
    rows.add([]);

    // Option Percentages
    rows.add(['Option', 'Percentage']);
    optionPercentages.forEach((option, percentage) {
      rows.add([option, '${percentage.toStringAsFixed(2)}%']);
    });

    return rows;
  }

  // No changes to this function as per your request
  List<List<dynamic>> _generateAnswersCSVData(
    Map<String, dynamic> questionData,
    List<List<dynamic>> answersData,
  ) {
    List<List<dynamic>> rows = [];

    // Header
    rows.add([
      'Index',
      'Question Title',
      'Question Text',
      'Question Group',
      'Question Type',
      'User Name',
      'User Email',
      'User Answer',
      'Timestamp',
    ]);

    final title = questionData['title'] as String? ?? '';
    final questionItself = questionData['question'] as String? ?? '';
    final groupName = questionData['groupname'] as String? ?? '';
    final questionType = questionData['type'] as String? ?? '';

    int index = 1;
    for (var answer in answersData) {
      String formattedTimestamp = answer[3];
      try {
        DateTime timestamp = DateTime.parse(answer[3]);
        formattedTimestamp =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp);
      } catch (e) {
        // Keep original string if parsing fails
      }

      rows.add([
        index.toString(),
        title,
        questionItself,
        groupName,
        questionType,
        answer[0], // User Name
        answer[1], // User Email
        answer[2], // User Answer
        formattedTimestamp, // Formatted Timestamp
      ]);
      index++;
    }

    return rows;
  }

  List<List<dynamic>> _generateRepliesCSVData(List<List<dynamic>> repliesData) {
    List<List<dynamic>> rows = [];

    // Header
    rows.add([
      'Reply Index',
      'Answer Index',
      'Answer ID',
      'Answerer Name',
      'Answerer Email',
      'Answer Text',
      'Replied Name',
      'Reply Text',
      'Timestamp',
    ]);

    for (var reply in repliesData) {
      if (reply.isEmpty) {
        // Add an empty row as a separator
        rows.add([]);
        continue;
      }

      String formattedTimestamp = reply[8];
      try {
        DateTime timestamp = DateTime.parse(reply[8]);
        formattedTimestamp =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp);
      } catch (e) {
        // Keep original string if parsing fails
      }

      rows.add([
        reply[0], // Reply Index
        reply[1], // Answer Index
        reply[2], // Answer ID
        reply[3], // Answerer Name
        reply[4], // Answerer Email
        reply[5], // Answer Text
        reply[6], // Replied Name
        reply[7], // Reply Text
        formattedTimestamp, // Formatted Timestamp
      ]);
    }

    return rows;
  }

  Future<void> _initialize() async {
    try {
      await _fetchUserData();
      await _fetchQuestionData();
      await _fetchOptionPercentages();
      await _fetchAnswers();
    } catch (e) {
      print('Initialization error: $e');
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

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingAnswers &&
        _hasMoreAnswers) {
      _fetchAnswers();
    }
  }
}





// // see_answers_admin.dart

// import 'dart:convert';
// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectgate/Services/answer_service.dart';
// import 'package:connectgate/Services/auth_services.dart';
// import 'package:connectgate/Widgets/pie_cahrt_widgets.dart';
// import 'package:connectgate/core/Check%20internet.dart';
// import 'package:connectgate/core/NoInternet.dart';
// import 'package:connectgate/models/admin_model.dart';
// import 'package:csv/csv.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart'; // For .paddingOnly etc.
// import 'package:intl/intl.dart'; // For timestamp formatting
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:share/share.dart';

// class SeeAnswersAdmin extends StatefulWidget {
//   final Map<String, dynamic> questionData;
//   final String questionId;

//   const SeeAnswersAdmin({
//     super.key,
//     required this.questionData,
//     required this.questionId,
//   });

//   @override
//   _SeeAnswersAdminState createState() => _SeeAnswersAdminState();
// }

// class _SeeAnswersAdminState extends State<SeeAnswersAdmin> {
//   MyAppAdmins? currentAdmin;
//   late AnswerService _answerService;

//   Map<String, double> optionPercentages = {};
//   String? title;
//   String? questionItself;
//   String? questionType;
//   String? groupName;

//   bool _isLoading = true;
//   bool _isDownloading = false;

//   // Variables for pagination
//   final List<DocumentSnapshot> _answers = [];
//   bool _isLoadingAnswers = false;
//   bool _hasMoreAnswers = true;
//   DocumentSnapshot? _lastAnswerDocument;
//   final int _answersPerPage = 5;

//   final ScrollController _scrollController = ScrollController();

//   final Map<String, bool> _expandedStates = {};
//   final Map<String, TextEditingController> _replyControllers = {};

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

//       if (currentAdmin == null) {
//         return Scaffold(
//           body: Center(
//             child: Text('Error: Admin data not found'),
//           ),
//         );
//       }

//       return Scaffold(
//         body: CustomScrollView(
//           controller: _scrollController,
//           slivers: [
//             // Your existing SliverAppBar and SliverList code

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
//             if (questionType == 'MultipleChoice')
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: PieChartWidget(
//                     optionPercentages: optionPercentages,
//                   ),
//                 ),
//               ),
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
//         floatingActionButton: FloatingActionButton(
//           onPressed: _isDownloading ? null : downloadCSV,
//           backgroundColor: Colors.black,
//           child: _isDownloading
//               ? SizedBox(
//                   height: 18,
//                   width: 18,
//                   child: CircularProgressIndicator(
//                     color: Colors.white,
//                     strokeWidth: 1.4,
//                   ))
//               : Icon(Icons.download_rounded, color: Colors.white),
//         ),
//       );
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _replyControllers.forEach((_, controller) => controller.dispose());
//     super.dispose();
//   }

//   Future<void> downloadCSV() async {
//     if (title == null || currentAdmin == null || _isDownloading) return;

//     setState(() {
//       _isDownloading = true;
//     });

//     try {
//       // Fetch all answers as QuerySnapshot
//       QuerySnapshot answersSnapshot =
//           await _answerService.getAllAnswersSnapshot(title!);

//       List<List<dynamic>> answersData = [];
//       List<List<dynamic>> repliesData = [];

//       int answerIndex = 1;
//       for (var doc in answersSnapshot.docs) {
//         var data = doc.data() as Map<String, dynamic>;
//         String answerId = doc.id;
//         String userName = data['user_name'] ?? 'Unknown';
//         String userEmail = data['user_email'] ?? 'Unknown';
//         String userAnswer = data['answer'] ?? 'No answer';
//         String timestamp = data['timestamp'] != null
//             ? (data['timestamp'] as Timestamp).toDate().toIso8601String()
//             : '';

//         answersData.add([
//           userName,
//           userEmail,
//           userAnswer,
//           timestamp,
//           answerId, // Include answerId for later use
//         ]);

//         // Fetch replies for this answer
//         List<Map<String, dynamic>> replies =
//             await _answerService.getRepliesData(answerId);

//         int replyIndex = 1;
//         for (var reply in replies) {
//           String replyText = reply['replyText'] ?? '';
//           String adminName = reply['adminName'] ?? '';
//           String replyTimestamp = reply['timestamp'] ?? '';

//           repliesData.add([
//             answerIndex, // Answer Index
//             replyIndex, // Reply Index
//             answerId, // Answer ID
//             userName, // Answerer Name
//             userEmail, // Answerer Email
//             userAnswer, // Answer Text
//             adminName, // Replied Name
//             replyText, // Reply Text
//             replyTimestamp, // Timestamp
//           ]);

//           replyIndex++;
//         }

//         // Add a separator between answers
//         repliesData.add([]);
//         answerIndex++;
//       }

//       // Generate CSV data for answers (No changes as per your request)
//       final answersCSVData =
//           _generateAnswersCSVData(widget.questionData, answersData);

//       // Save answers CSV file
//       final directory = await getTemporaryDirectory();
//       final answersFilePath = '${directory.path}/${title!}-answers.csv';
//       final answersFile = File(answersFilePath);
//       final answersCSVFile = const ListToCsvConverter().convert(answersCSVData);
//       await answersFile.writeAsString(answersCSVFile, encoding: utf8);

//       // Generate CSV data for replies
//       String? repliesFilePath;
//       if (repliesData.isNotEmpty) {
//         final repliesCSVData = _generateRepliesCSVData(repliesData);
//         // Save replies CSV file
//         repliesFilePath = '${directory.path}/${title!}-replies.csv';
//         final repliesFile = File(repliesFilePath);
//         final repliesCSVFile =
//             const ListToCsvConverter().convert(repliesCSVData);
//         await repliesFile.writeAsString(repliesCSVFile, encoding: utf8);
//       }

//       // Generate CSV data for analyze (No changes as per your request)
//       String? analyzeFilePath;
//       if (questionType == 'MultipleChoice' && optionPercentages.isNotEmpty) {
//         final analyzeCSVData =
//             _generateAnalyzeCSVData(widget.questionData, optionPercentages);
//         // Save analyze CSV file
//         analyzeFilePath = '${directory.path}/${title!}-percentage.csv';
//         final analyzeFile = File(analyzeFilePath);
//         final analyzeCSVFile =
//             const ListToCsvConverter().convert(analyzeCSVData);
//         await analyzeFile.writeAsString(analyzeCSVFile, encoding: utf8);
//       }

//       // Create a text file with professional content
//       String textFilePath = '${directory.path}/${title!}.txt';
//       final textFile = File(textFilePath);
//       String textContent =
//           'Question "${title!}" saved on ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())} by ${currentAdmin!.name} in ${currentAdmin!.org}/${currentAdmin!.city}.';
//       await textFile.writeAsString(textContent, encoding: utf8);

//       // Share the files
//       List<String> filePaths = [answersFilePath];
//       if (repliesFilePath != null) {
//         filePaths.add(repliesFilePath);
//       }
//       if (analyzeFilePath != null) {
//         filePaths.add(analyzeFilePath);
//       }
//       filePaths.add(textFilePath);

//       await Share.shareFiles(filePaths);
//     } catch (e) {
//       print('Error downloading CSV: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isDownloading = false;
//         });
//       }
//     }
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
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 userName,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   letterSpacing: 1.2,
//                   color: Colors.white,
//                   fontFamily: 'NRT',
//                 ),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 finalData != null
//                     ? DateFormat('yyyy-MM-dd HH:mm:ss').format(finalData)
//                     : 'N/A',
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
//       stream: _answerService.getRepliesStream(answerId),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator(color: Colors.black));
//         }
//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }
//         final replies = snapshot.data!.docs;
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
//             final adminName = replyData['Name'] as String? ?? 'No UserName';
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
//                           adminName,
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
//                 return;
//               }
//               _answerService.addReply(
//                 answerId,
//                 _replyControllers[answerId]!.text,
//                 currentAdmin!.name,
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
//       print('Error fetching answers: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoadingAnswers = false;
//         });
//       }
//     }
//   }

//   Future<void> _fetchOptionPercentages() async {
//     if (currentAdmin == null || title == null) return;
//     try {
//       if (widget.questionData['options'] != null) {
//         final percentages = await _answerService.calculateOptionPercentages(
//           title!,
//           widget.questionData['options'],
//         );
//         if (mounted) {
//           setState(() {
//             optionPercentages = percentages;
//           });
//         }
//       }
//     } catch (e) {
//       print('Error fetching option percentages: $e');
//     }
//   }

//   Future<void> _fetchQuestionData() async {
//     if (currentAdmin == null) return;

//     try {
//       final questionDoc = await FirebaseFirestore.instance
//           .collection(currentAdmin!.org)
//           .doc(currentAdmin!.city)
//           .collection('questions')
//           .doc(widget.questionId)
//           .get();

//       if (!questionDoc.exists) return;

//       final questionData = questionDoc.data() as Map<String, dynamic>;
//       if (mounted) {
//         setState(() {
//           title = questionData['title'] as String?;
//           questionItself = questionData['question'] as String?;
//           groupName = questionData['groupname'] as String?;
//           questionType = questionData['type'] as String?;
//         });
//       }
//     } catch (e) {
//       print('Error fetching question data: $e');
//     }
//   }

//   Future<void> _fetchUserData() async {
//     final authService = AuthService(context);
//     try {
//       currentAdmin = await authService.getCurrentAdmin();
//       if (currentAdmin != null) {
//         _answerService = AnswerService(
//           org: currentAdmin!.org,
//           city: currentAdmin!.city,
//         );
//       } else {
//         throw Exception('Admin data not found');
//       }
//     } catch (e) {
//       print('Error fetching user data: $e');
//     }
//   }

//   // No changes to this function as per your request
//   List<List<dynamic>> _generateAnalyzeCSVData(
//     Map<String, dynamic> questionData,
//     Map<String, double> optionPercentages,
//   ) {
//     List<List<dynamic>> rows = [];

//     // Header
//     rows.add(['Question Analysis']);

//     final title = questionData['title'] as String? ?? '';
//     final questionItself = questionData['question'] as String? ?? '';
//     final groupName = questionData['groupname'] as String? ?? '';
//     final questionType = questionData['type'] as String? ?? '';

//     // Question Info
//     rows.add(['Question Title', title]);
//     rows.add(['Question Text', questionItself]);
//     rows.add(['Question Group', groupName]);
//     rows.add(['Question Type', questionType]);

//     // Empty row
//     rows.add([]);

//     // Option Percentages
//     rows.add(['Option', 'Percentage']);
//     optionPercentages.forEach((option, percentage) {
//       rows.add([option, '${percentage.toStringAsFixed(2)}%']);
//     });

//     return rows;
//   }

//   // No changes to this function as per your request
//   List<List<dynamic>> _generateAnswersCSVData(
//     Map<String, dynamic> questionData,
//     List<List<dynamic>> answersData,
//   ) {
//     List<List<dynamic>> rows = [];

//     // Header
//     rows.add([
//       'Index',
//       'Question Title',
//       'Question Text',
//       'Question Group',
//       'Question Type',
//       'User Name',
//       'User Email',
//       'User Answer',
//       'Timestamp',
//     ]);

//     final title = questionData['title'] as String? ?? '';
//     final questionItself = questionData['question'] as String? ?? '';
//     final groupName = questionData['groupname'] as String? ?? '';
//     final questionType = questionData['type'] as String? ?? '';

//     int index = 1;
//     for (var answer in answersData) {
//       String formattedTimestamp = answer[3];
//       try {
//         DateTime timestamp = DateTime.parse(answer[3]);
//         formattedTimestamp =
//             DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp);
//       } catch (e) {
//         // Keep original string if parsing fails
//       }

//       rows.add([
//         index.toString(),
//         title,
//         questionItself,
//         groupName,
//         questionType,
//         answer[0], // User Name
//         answer[1], // User Email
//         answer[2], // User Answer
//         formattedTimestamp, // Formatted Timestamp
//       ]);
//       index++;
//     }

//     return rows;
//   }

//   List<List<dynamic>> _generateRepliesCSVData(List<List<dynamic>> repliesData) {
//     List<List<dynamic>> rows = [];

//     // Header
//     rows.add([
//       'Reply Index',
//       'Answer Index',
//       'Answer ID',
//       'Answerer Name',
//       'Answerer Email',
//       'Answer Text',
//       'Replied Name',
//       'Reply Text',
//       'Timestamp',
//     ]);

//     for (var reply in repliesData) {
//       if (reply.isEmpty) {
//         // Add an empty row as a separator
//         rows.add([]);
//         continue;
//       }

//       String formattedTimestamp = reply[8];
//       try {
//         DateTime timestamp = DateTime.parse(reply[8]);
//         formattedTimestamp =
//             DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp);
//       } catch (e) {
//         // Keep original string if parsing fails
//       }

//       rows.add([
//         reply[0], // Reply Index
//         reply[1], // Answer Index
//         reply[2], // Answer ID
//         reply[3], // Answerer Name
//         reply[4], // Answerer Email
//         reply[5], // Answer Text
//         reply[6], // Replied Name
//         reply[7], // Reply Text
//         formattedTimestamp, // Formatted Timestamp
//       ]);
//     }

//     return rows;
//   }

//   Future<void> _initialize() async {
//     try {
//       await _fetchUserData();
//       await _fetchQuestionData();
//       await _fetchOptionPercentages();
//       await _fetchAnswers();
//     } catch (e) {
//       print('Initialization error: $e');
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

//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//             _scrollController.position.maxScrollExtent - 200 &&
//         !_isLoadingAnswers &&
//         _hasMoreAnswers) {
//       _fetchAnswers();
//     }
//   }
// }

































// // see_answers_admin.dart

// import 'dart:convert';
// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectgate/Services/answer_service.dart';
// import 'package:connectgate/Services/auth_services.dart';
// import 'package:connectgate/Widgets/pie_cahrt_widgets.dart';
// import 'package:connectgate/core/Check%20internet.dart';
// import 'package:connectgate/core/NoInternet.dart';
// import 'package:connectgate/models/admin_model.dart';
// import 'package:csv/csv.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart'; // For .paddingOnly etc.
// import 'package:get_time_ago/get_time_ago.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:share/share.dart';

// class SeeAnswersAdmin extends StatefulWidget {
//   final Map<String, dynamic> questionData;
//   final String questionId;

//   const SeeAnswersAdmin({
//     super.key,
//     required this.questionData,
//     required this.questionId,
//   });

//   @override
//   _SeeAnswersAdminState createState() => _SeeAnswersAdminState();
// }

// class _SeeAnswersAdminState extends State<SeeAnswersAdmin> {
//   MyAppAdmins? currentAdmin;
//   late AnswerService _answerService;

//   Map<String, double> optionPercentages = {};
//   String? title;
//   String? questionItself;
//   String? questionType;
//   String? groupName;

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

//       if (currentAdmin == null) {
//         return Scaffold(
//           body: Center(
//             child: Text('Error: Admin data not found'),
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
//             if (questionType == 'MultipleChoice')
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: PieChartWidget(
//                     optionPercentages: optionPercentages,
//                   ),
//                 ),
//               ),
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
//         floatingActionButton: FloatingActionButton(
//           onPressed: downloadCSV,
//           backgroundColor: Colors.black,
//           child: Icon(Icons.download_rounded, color: Colors.white),
//         ),
//       );
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _replyControllers.forEach((_, controller) => controller.dispose());
//     super.dispose();
//   }

//   Future<void> downloadCSV() async {
//     if (title == null || currentAdmin == null) return;

//     try {
//       final answersList = await _answerService.getAllAnswers(title!);

//       final csvData = _generateCSVData(widget.questionData, answersList);

//       final directory = await getApplicationDocumentsDirectory();
//       final filePath = '${directory.path}/$title.csv';
//       final file = File(filePath);
//       final csvFile = const ListToCsvConverter().convert(csvData);
//       await file.writeAsString(csvFile, encoding: utf8);

//       await Share.shareFiles([filePath], text: 'Questions and Answers CSV');
//     } catch (e) {
//       print('Error downloading CSV: $e');
//     }
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
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 userName,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   letterSpacing: 1.2,
//                   color: Colors.white,
//                   fontFamily: 'NRT',
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
//       stream: _answerService.getRepliesStream(answerId),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator(color: Colors.black));
//         }
//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }
//         final replies = snapshot.data!.docs;
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
//             final adminName = replyData['Name'] as String? ?? 'No UserName';
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
//                           adminName,
//                           style: const TextStyle(
//                               color: Colors.white, fontFamily: 'NRT'),
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
//                 return;
//               }
//               _answerService.addReply(
//                 answerId,
//                 _replyControllers[answerId]!.text,
//                 currentAdmin!.name,
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

//   Future<void> _fetchAnswers() async {
//     if (_isLoadingAnswers || !_hasMoreAnswers) return;
//     setState(() {
//       _isLoadingAnswers = true;
//     });
//     try {
//       QuerySnapshot snapshot = await _answerService.getAnswers(
//         widget.questionData['title'],
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
//       print('Error fetching answers: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoadingAnswers = false;
//         });
//       }
//     }
//   }

//   Future<void> _fetchOptionPercentages() async {
//     if (currentAdmin == null) return;
//     try {
//       final percentages = await _answerService.calculateOptionPercentages(
//         widget.questionData['title'],
//         widget.questionData['options'],
//       );
//       if (mounted) {
//         setState(() {
//           optionPercentages = percentages;
//         });
//       }
//     } catch (e) {
//       print('Error fetching option percentages: $e');
//     }
//   }

//   Future<void> _fetchQuestionData() async {
//     if (currentAdmin == null) return;

//     try {
//       final questionDoc = await FirebaseFirestore.instance
//           .collection(currentAdmin!.org)
//           .doc(currentAdmin!.city)
//           .collection('questions')
//           .doc(widget.questionId)
//           .get();

//       if (!questionDoc.exists) return;

//       final questionData = questionDoc.data() as Map<String, dynamic>;
//       if (mounted) {
//         setState(() {
//           title = questionData['title'] as String?;
//           questionItself = questionData['question'] as String?;
//           groupName = questionData['groupname'] as String?;
//           questionType = questionData['type'] as String?;
//         });
//       }
//     } catch (e) {
//       print('Error fetching question data: $e');
//     }
//   }

//   Future<void> _fetchUserData() async {
//     final authService = AuthService(context);
//     try {
//       currentAdmin = await authService.getCurrentAdmin();
//       if (currentAdmin != null) {
//         _answerService = AnswerService(
//           org: currentAdmin!.org,
//           city: currentAdmin!.city,
//         );
//       } else {
//         throw Exception('Admin data not found');
//       }
//     } catch (e) {
//       print('Error fetching user data: $e');
//     }
//   }

//   List<List<dynamic>> _generateCSVData(
//     Map<String, dynamic> questionData,
//     List<List<dynamic>> answersData,
//   ) {
//     if (answersData.isEmpty) {
//       return [];
//     }

//     final rows = [
//       [
//         'Question Title',
//         'Question',
//         'Question Group',
//         'Question Type',
//         'User Name',
//         'User Email',
//         'User Answer',
//         'Timestamp',
//       ],
//     ];

//     final title = questionData['title'] as String? ?? '';
//     final questionItself = questionData['question'] as String? ?? '';
//     final groupName = questionData['groupname'] as String? ?? '';
//     final questionType = questionData['type'] as String? ?? '';

//     for (var answer in answersData) {
//       rows.add([
//         title,
//         questionItself,
//         groupName,
//         questionType,
//         answer[0],
//         answer[1],
//         answer[2],
//         answer[3],
//       ]);
//     }

//     return rows;
//   }

//   Future<void> _initialize() async {
//     try {
//       await _fetchUserData();
//       await _fetchQuestionData();
//       await _fetchOptionPercentages();
//       await _fetchAnswers();
//     } catch (e) {
//       print('Initialization error: $e');
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

//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//             _scrollController.position.maxScrollExtent - 200 &&
//         !_isLoadingAnswers &&
//         _hasMoreAnswers) {
//       _fetchAnswers();
//     }
//   }
// }
























































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































// import 'dart:convert';
// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectgate/Services/auth_services.dart';
// import 'package:connectgate/Widgets/answer_card_admin_side.dart';
// import 'package:connectgate/Widgets/pie_cahrt_widgets.dart';
// import 'package:connectgate/core/Check%20internet.dart';
// import 'package:connectgate/core/NoInternet.dart'; // Ensure this is defined elsewhere
// import 'package:connectgate/models/admin_model.dart';
// import 'package:csv/csv.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:share/share.dart';

// class SeeAnswersAdmin extends StatefulWidget {
//   final Map<String, dynamic> questionData;
//   final String questionId;

//   const SeeAnswersAdmin({
//     Key? key,
//     required this.questionData,
//     required this.questionId,
//   }) : super(key: key);

//   @override
//   _SeeAnswersAdminState createState() => _SeeAnswersAdminState();
// }

// class _SeeAnswersAdminState extends State<SeeAnswersAdmin> {
//   final Map<String, List<List<dynamic>>> answersDataMap = {};
//   MyAppAdmins? currentAdmin;
//   Map<String, double> optionPercentages = {};

//   String? title;
//   String? questionItself;
//   String? questionType;
//   String? groupName;

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<connectivitycheck>(builder: (context, model, child) {
//       if (!model.isonline) return Nointernet();

//       return Scaffold(
//         body: GestureDetector(
//           onTap: () => FocusScope.of(context).unfocus(),
//           child: CustomScrollView(
//             slivers: [
//               SliverAppBar(
//                 surfaceTintColor: Colors.transparent,
//                 automaticallyImplyLeading: false,
//                 expandedHeight: 245,
//                 pinned: true,
//                 flexibleSpace: FlexibleSpaceBar(
//                   collapseMode: CollapseMode.pin,
//                   background: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.black,
//                       borderRadius: BorderRadius.only(
//                         bottomLeft: Radius.circular(50),
//                         bottomRight: Radius.circular(50),
//                       ),
//                     ),
//                     child: Padding(
//                       padding:
//                           const EdgeInsets.only(top: 60, left: 22, right: 20),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               GestureDetector(
//                                 onTap: () => Navigator.pop(context),
//                                 child:
//                                     Icon(Icons.arrow_back, color: Colors.white),
//                               ),
//                               Text(' '),
//                               if (title != null)
//                                 Text(
//                                   title!,
//                                   style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 12,
//                                       fontFamily: 'NRT'),
//                                 ),
//                             ],
//                           ),
//                           SizedBox(height: 10),
//                           Center(
//                             child: Icon(Icons.message,
//                                 color: Colors.white, size: 22),
//                           ),
//                           SizedBox(height: 15),
//                           Center(
//                             child: Text(
//                               questionItself ?? '',
//                               softWrap: true,
//                               overflow: TextOverflow.clip,
//                               maxLines: 20,
//                               textAlign: TextAlign.justify,
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 14,
//                                   fontFamily: 'NRT',
//                                   letterSpacing: 1.2),
//                             ),
//                           ),
//                           SizedBox(height: 25),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Text('Option Percentages:',
//                       //     style: TextStyle(
//                       //         fontSize: 18, fontWeight: FontWeight.bold)),
//                       // SizedBox(height: 10),
//                       // if (widget.questionData['options'] != null)
//                       //   ...widget.questionData['options']!.map(
//                       //     (option) => Text(
//                       //       '$option: ${optionPercentages[option]?.toStringAsFixed(2) ?? '0.00'}%',
//                       //       style: TextStyle(fontSize: 16),
//                       //     ),
//                       //   ),
//                       SizedBox(height: 10),
//                       // Add Pie Chart here
//                       if(questionType=='MultipleChoice')
//                       PieChartWidget(optionPercentages: optionPercentages),
//                     ],
//                   ),
//                 ),
//               ),
//               SliverToBoxAdapter(
//                 child:
//                     AnswersCard(myTitle: widget.questionData['title'] ?? 'N/A'),
//               ),
//             ],
//           ),
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: downloadCSV,
//           backgroundColor: Colors.black,
//           child: Icon(Icons.download_rounded, color: Colors.white),
//         ),
//       );
//     });
//   }

//   Future<void> downloadCSV() async {
//     if (title == null || !answersDataMap.containsKey(title!)) return;

//     final csvData = await generateCSVData(
//       widget.questionData,
//       answersDataMap[title!]!,
//     );

//     final directory = await getApplicationDocumentsDirectory();
//     final filePath = '${directory.path}/$title.csv';
//     final file = File(filePath);
//     final csvFile = const ListToCsvConverter().convert(csvData);
//     await file.writeAsString(csvFile, encoding: utf8);

//     await Share.shareFiles([filePath], text: 'Questions and Answers CSV');
//   }

//   Future<void> fetchQuestionAndAnswers() async {
//     if (currentAdmin == null) return;

//     try {
//       final questionDocument = await FirebaseFirestore.instance
//           .collection(currentAdmin!.org)
//           .doc(currentAdmin!.city)
//           .collection('questions')
//           .doc(widget.questionId)
//           .get();

//       if (!questionDocument.exists) return;

//       final questionData = questionDocument.data() as Map<String, dynamic>;
//       setState(() {
//         title = questionData['title'] as String?;
//         questionItself = questionData['question'] as String?;
//         groupName = questionData['groupname'] as String?;
//         questionType = questionData['type'] as String?;
//       });

//       final answersQuerySnapshot = await FirebaseFirestore.instance
//           .collection(currentAdmin!.org)
//           .doc(currentAdmin!.city)
//           .collection('answers')
//           .where('title', isEqualTo: title)
//           .get();

//       final answersList = answersQuerySnapshot.docs.map((answerDocument) {
//         final userName = answerDocument['user_name'] as String? ?? 'Unknown';
//         final userEmail = answerDocument['user_email'] as String? ?? 'N/A';
//         final userAnswer = answerDocument['answer'] as String? ?? 'No answer';
//         final timestamp = answerDocument['timestamp'] as Timestamp?;

//         return [
//           userName,
//           userEmail,
//           userAnswer,
//           timestamp != null ? timestamp.toDate().toString() : ''
//         ];
//       }).toList();

//       setState(() {
//         answersDataMap[title!] = answersList;
//       });
//     } catch (e) {
//       print('Error fetching question and answers: $e');
//     }
//   }

//   Future<void> fetchUserData() async {
//     final authService = AuthService(context);
//     final adminData = await authService.getCurrentAdmin();
//     setState(() {
//       currentAdmin = adminData;
//     });
//   }

//   Future<List<List<dynamic>>> generateCSVData(
//     Map<String, dynamic> questionData,
//     List<List<dynamic>> answersData,
//   ) async {
//     if (answersData.isEmpty) {
//       return [];
//     }

//     final rows = [
//       [
//         'Questions Title',
//         'Questions',
//         'Questions Group',
//         'Questions Type',
//         'Users Name',
//         'Users Email',
//         'Users Answer',
//         'Timestamp',
//       ],
//     ];

//     final title = questionData['title'] as String? ?? '';
//     final questionItself = questionData['question'] as String? ?? '';
//     final groupName = questionData['groupname'] as String? ?? '';
//     final questionType = questionData['type'] as String? ?? '';

//     for (var answer in answersData) {
//       rows.add([
//         title,
//         questionItself,
//         groupName,
//         questionType,
//         answer[0],
//         answer[1],
//         answer[2],
//         answer[3], // Timestamp column
//       ]);
//     }

//     return rows;
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initialize();
//   }

// //
//   Future<Map<String, double>> _calculateOptionPercentages() async {
//     try {
//       final answersQuerySnapshot = await FirebaseFirestore.instance
//           .collection(currentAdmin!.org)
//           .doc(currentAdmin!.city)
//           .collection('answers')
//           .where('title', isEqualTo: widget.questionData['title'])
//           .get();

//       final optionCounts = <String, int>{};
//       int totalAnswers = 0;

//       // Initialize optionCounts with all available options set to 0
//       for (var option in widget.questionData['options'] ?? []) {
//         optionCounts[option] = 0;
//       }

//       for (var answerDoc in answersQuerySnapshot.docs) {
//         // Debug: Print the document data to check its structure
//         print('Document data: ${answerDoc.data()}');

//         final userAnswer = answerDoc.get('answer') as String? ?? '';
//         final selectedOptions =
//             userAnswer.split(',').map((e) => e.trim()).toList();

//         // Debug: Print the selected options
//         print('Selected options: $selectedOptions');

//         for (var option in selectedOptions) {
//           if (optionCounts.containsKey(option)) {
//             optionCounts[option] = (optionCounts[option] ?? 0) + 1;
//             totalAnswers++;
//           }
//         }
//       }

//       final optionPercentages = <String, double>{};
//       if (totalAnswers > 0) {
//         optionCounts.forEach((option, count) {
//           optionPercentages[option] = (count / totalAnswers) * 100;
//         });
//       } else {
//         // If there are no answers, set all options to 0%
//         for (var option in widget.questionData['options'] ?? []) {
//           optionPercentages[option] = 0.0;
//         }
//       }

//       // Debug: Print calculated percentages
//       print('Calculated percentages: $optionPercentages');

//       return optionPercentages;
//     } catch (e) {
//       print('Error calculating percentages: $e');
//       return {};
//     }
//   }

//   Future<void> _fetchOptionPercentages() async {
//     final percentages = await _calculateOptionPercentages();
//     setState(() {
//       optionPercentages = percentages;
//     });
//   }

//   Future<void> _initialize() async {
//     await fetchUserData();
//     await fetchQuestionAndAnswers();
//     await _fetchOptionPercentages();
//   }
// }































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































// import 'dart:convert';
// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectgate/Services/auth_services.dart';
// import 'package:connectgate/Widgets/answer_card_admin_side.dart';
// import 'package:connectgate/core/Check%20internet.dart';
// import 'package:connectgate/core/NoInternet.dart'; // Ensure this is defined elsewhere
// import 'package:connectgate/models/admin_model.dart';
// import 'package:csv/csv.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:share/share.dart';

// class SeeAnswersAdmin extends StatefulWidget {
//   final Map<String, dynamic> questionData;
//   final String questionId;

//   const SeeAnswersAdmin({
//     Key? key,
//     required this.questionData,
//     required this.questionId,
//   }) : super(key: key);

//   @override
//   _SeeAnswersAdminState createState() => _SeeAnswersAdminState();
// }

// class _SeeAnswersAdminState extends State<SeeAnswersAdmin> {
//   final Map<String, List<List<dynamic>>> answersDataMap = {};
//   MyAppAdmins? currentAdmin;

//   late String title;
//   late String questionItself;
//   late String questionType;
//   late String groupName;

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<connectivitycheck>(builder: (context, model, child) {
//       if (!model.isonline)
//         return Nointernet(); // Ensure this widget is defined or replace with appropriate widget

//       return Scaffold(
//         body: GestureDetector(
//           onTap: () => FocusScope.of(context).unfocus(),
//           child: CustomScrollView(
//             slivers: [
//               SliverAppBar(
//                 automaticallyImplyLeading: false,
//                 expandedHeight: 245,
//                 pinned: true,
//                 flexibleSpace: FlexibleSpaceBar(
//                   collapseMode: CollapseMode.pin,
//                   background: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.black,
//                       borderRadius: BorderRadius.only(
//                         bottomLeft: Radius.circular(50),
//                         bottomRight: Radius.circular(50),
//                       ),
//                     ),
//                     child: Padding(
//                       padding:
//                           const EdgeInsets.only(top: 60, left: 22, right: 20),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               GestureDetector(
//                                 onTap: () => Navigator.pop(context),
//                                 child: Icon(
//                                   Icons.arrow_back,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               Text(' '),
//                               Text(
//                                 title,
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 12,
//                                   fontFamily: 'NRT',
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 10),
//                           Center(
//                             child: Icon(
//                               Icons.message,
//                               color: Colors.white,
//                               size: 22,
//                             ),
//                           ),
//                           SizedBox(height: 15),
//                           Center(
//                             child: Text(
//                               questionItself,
//                               softWrap: true,
//                               overflow: TextOverflow.clip,
//                               maxLines: 20,
//                               textAlign: TextAlign.justify,
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 14,
//                                 fontFamily: 'NRT',
//                                 letterSpacing: 1.2,
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 25),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SliverToBoxAdapter(
//                 child: AnswersCard(
//                   myTitle: widget.questionData['title'] ?? 'N/A',
//                 ),
//               ),
//             ],
//           ),
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: downloadCSV,
//           backgroundColor: Colors.black,
//           child: Icon(
//             Icons.download_rounded,
//             color: Colors.white,
//           ),
//         ),
//       );
//     });
//   }

//   Future<void> downloadCSV() async {
//     if (title.isEmpty || !answersDataMap.containsKey(title)) return;

//     final csvData = await generateCSVData(
//       widget.questionData,
//       answersDataMap[title]!,
//     );

//     final directory = await getApplicationDocumentsDirectory();
//     final filePath = '${directory.path}/$title.csv';
//     final file = File(filePath);
//     final csvFile = const ListToCsvConverter().convert(csvData);
//     await file.writeAsString(csvFile, encoding: utf8);

//     await Share.shareFiles([filePath], text: 'Questions and Answers CSV');
//   }

//   Future<void> fetchQuestionAndAnswers() async {
//     if (currentAdmin == null) return;

//     try {
//       final questionDocument = await FirebaseFirestore.instance
//           .collection(currentAdmin!.org)
//           .doc(currentAdmin!.city)
//           .collection('questions')
//           .doc(widget.questionId)
//           .get();

//       if (!questionDocument.exists) return;

//       final questionData = questionDocument.data() as Map<String, dynamic>;
//       setState(() {
//         title = questionData['title'] as String? ?? '';
//         questionItself = questionData['question'] as String? ?? '';
//         groupName = questionData['groupname'] as String? ?? '';
//         questionType = questionData['type'] as String? ?? '';
//       });

//       final answersQuerySnapshot = await FirebaseFirestore.instance
//           .collection(currentAdmin!.org)
//           .doc(currentAdmin!.city)
//           .collection('answers')
//           .where('title', isEqualTo: title)
//           .get();

//       final answersList = answersQuerySnapshot.docs.map((answerDocument) {
//         final userName = answerDocument['user_name'] as String? ?? 'Unknown';
//         final userEmail = answerDocument['user_email'] as String? ?? 'N/A';
//         final userAnswer = answerDocument['answer'] as String? ?? 'No answer';
//         final timestamp = answerDocument['timestamp'] as Timestamp?;

//         return [
//           userName,
//           userEmail,
//           userAnswer,
//           timestamp != null ? timestamp.toDate().toString() : ''
//         ];
//       }).toList();

//       setState(() {
//         answersDataMap[title] = answersList;
//       });
//     } catch (e) {
//       print('Error fetching question and answers: $e');
//     }
//   }

//   Future<void> fetchUserData() async {
//     final authService = AuthService(context);
//     final adminData = await authService.getCurrentAdmin();
//     setState(() {
//       currentAdmin = adminData;
//     });
//   }

//   Future<List<List<dynamic>>> generateCSVData(
//     Map<String, dynamic> questionData,
//     List<List<dynamic>> answersData,
//   ) async {
//     if (answersData.isEmpty) {
//       return [];
//     }

//     final rows = [
//       [
//         'Questions Title',
//         'Questions',
//         'Questions Group',
//         'Questions Type',
//         'Users Name',
//         'Users Email',
//         'Users Answer',
//         'Timestamp', // Added Timestamp for clarity
//       ],
//     ];

//     final title = questionData['title'] as String? ?? '';
//     final questionItself = questionData['question'] as String? ?? '';
//     final groupName = questionData['groupname'] as String? ?? '';
//     final questionType = questionData['type'] as String? ?? '';

//     for (var answer in answersData) {
//       rows.add([
//         title,
//         questionItself,
//         groupName,
//         questionType,
//         answer[0],
//         answer[1],
//         answer[2],
//         answer[3], // Timestamp column
//       ]);
//     }

//     return rows;
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initialize();

//     title = widget.questionData['title'] ?? '';
//     questionItself = widget.questionData['question'] ?? '';
//     questionType = widget.questionData['type'] ?? '';
//     groupName = widget.questionData['groupname'] ?? '';
//   }

//   Future<void> _initialize() async {
//     await fetchUserData();
//     await fetchQuestionAndAnswers();
//   }
// }


 