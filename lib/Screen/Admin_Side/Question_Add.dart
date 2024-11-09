// ignore_for_file: file_names, library_private_types_in_public_api, deprecated_member_use, unused_field, unused_element, depend_on_referenced_packages, non_constant_identifier_names, unnecessary_new

import 'dart:io';

import 'package:connectgate/Screen/Admin_Side/UsersGroupsCreate.dart';
import 'package:connectgate/Services/group_services.dart';
import 'package:connectgate/Services/question_services.dart';
// import 'package:connectgate/core/CeckForUpdate.dart';
import 'package:connectgate/core/Check%20internet.dart';
import 'package:connectgate/core/NoInternet.dart';
import 'package:connectgate/models/group_model.dart';
import 'package:connectgate/providers/question_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class QuestionAdd extends StatefulWidget {
  const QuestionAdd({super.key});

  @override
  _QuestionAddState createState() => _QuestionAddState();
}

class _QuestionAddState extends State<QuestionAdd> {
  // Create an instance of GroupServices and pass the current context to it
  final QuestionService _questionService = QuestionService();

  TextEditingController optionController = TextEditingController();
  TextEditingController questionController = TextEditingController();
  TextEditingController questionTitleController = TextEditingController();
  bool question_error = false;
  bool title_error = false;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _pickedImage;
  List<String> multipleChoiceOptions = [];
  bool isMultipleChoice = false;
  String? selectedGroupId;
  String selectedType = '';
  List<String> selectedGroups = [];
  String selectedGroupName = '';
  void addOption() {
    if (optionController.text.isNotEmpty) {
      setState(() {
        multipleChoiceOptions.add(optionController.text);
        optionController.text = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<connectivitycheck>(builder: (context, modle, child) {
      return modle.isonline
          ? Scaffold(
              backgroundColor: Colors.white,
              body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      automaticallyImplyLeading: false,
                      expandedHeight: 130,
                      floating: false,
                      pinned: true,
                      snap: false,
                      shadowColor: Colors.transparent,
                      backgroundColor: Colors.white,
                      flexibleSpace: FlexibleSpaceBar(
                        expandedTitleScale: 1.3,
                        background: Container(
                          color: Colors.white,
                        ),
                        centerTitle: true,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'ADD QUESTIONS'.tr,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontFamily: 'ageo-bold',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 35),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: SizedBox(
                                  width: 300,
                                  height: 60,
                                  child: buildGroupDropdown()),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 6),
                              child: buildQuestionTypeSelector(),
                            ),

                            ///textfield for title of question
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: TextField(
                                minLines: 1,
                                maxLines: 1,
                                maxLength: 25,
                                controller: questionTitleController,
                                cursorColor: Colors.black,
                                decoration: InputDecoration(
                                  labelText: 'Title'.tr,
                                  hintText: 'Enter Title Of Question Here'.tr,
                                  labelStyle: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14.0,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.title,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 183, 183, 183),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                            ),

                            Center(
                              child: Visibility(
                                  visible: title_error,
                                  child: Text(
                                    "Title  is required Please enter your title"
                                        .tr,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 10),
                                  )),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: TextField(
                                minLines: 1,
                                maxLines: 15,
                                controller: questionController,
                                keyboardType: TextInputType.multiline,
                                cursorColor: Colors.black,
                                decoration: InputDecoration(
                                  labelText: 'Question'.tr,
                                  hintText: 'Enter Question Here'.tr,
                                  labelStyle: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14.0,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.question_answer,
                                    color: Colors.black,
                                    size: 18,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 183, 183, 183),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Center(
                              child: Visibility(
                                  visible: question_error,
                                  child: Text(
                                    "Question  is required Please enter your question"
                                        .tr,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 10),
                                  )),
                            ),
                            const SizedBox(height: 12),

                            if (isMultipleChoice) buildMultipleChoiceOptions(),
                            if (_pickedImage != null) _buildImage(),
                            const SizedBox(height: 22),
//////////////////////

                            Consumer<QuestionProvider>(
                              builder: (context, questionProvider, child) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      height: 46,
                                      width: 220,
                                      // width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          setState(() {
                                            question_error =
                                                questionController.text.isEmpty;
                                            title_error =
                                                questionTitleController
                                                    .text.isEmpty;
                                          });
                                          // Check if any required fields are empty

                                          if (questionController.text.isEmpty ||
                                              questionTitleController
                                                  .text.isEmpty) {
                                            _showAlertDialog();
                                          }
                                          // Check if a group is selected
                                          else if (selectedGroupId == null) {
                                            _showSnackBar(
                                                "Please select a group".tr,
                                                Colors.red);
                                          }
                                          // Check if it's a multiple choice question and options are empty
                                          else if (isMultipleChoice &&
                                              multipleChoiceOptions.isEmpty) {
                                            _showSnackBar(
                                                "Please add options for the multiple choice question"
                                                    .tr,
                                                Colors.red);
                                          } else {
                                            String uploadedImageUrl = '';
                                            if (_pickedImage != null) {
                                              uploadedImageUrl =
                                                  await _uploadImage(
                                                      File(_pickedImage!.path));
                                            }

                                            questionProvider.addQuestion(
                                              context: context,
                                              groupname: selectedGroupName,
                                              groupIds: selectedGroups,
                                              title:
                                                  questionTitleController.text,
                                              question: questionController.text,
                                              type: selectedType,
                                              options: multipleChoiceOptions,
                                              imageFile: uploadedImageUrl,
                                            );
                                            questionTitleController.clear();
                                            questionController.clear();
                                          }

                                          // Use the questionProvider to add the question
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Send'.tr,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 46,
                                      width: 72,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          Get.back(); // Close the bottom sheet
                                          final XFile? image =
                                              await _imagePicker.pickImage(
                                                  source: ImageSource.gallery);
                                          if (image != null) {
                                            setState(() {
                                              _pickedImage =
                                                  image; // Update the picked image
                                            });
                                          } else {
                                            // SnackbarManager().showSnackbar(
                                            //   context,
                                            //   "Error",
                                            //   "No image selected.",
                                            //   onThen: () => Get.back(),
                                            //   Icon(
                                            //     Icons.error,
                                            //     color: regularblack,
                                            //   ),
                                            // );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              side: const BorderSide(
                                                  color: Colors.black,
                                                  width: 1.5)),
                                        ),
                                        child: Icon(
                                          Icons.add_a_photo_outlined,
                                          color: Colors.black,
                                          size: 27,
                                        ),
                                      ),
                                    ),
                                  ],
                                ).paddingSymmetric(horizontal: 40);
                              },
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            const SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              child: Container(
                                height: 1.2,
                                color: Colors.black,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'TO ADD USERS  AND GROUPS'.tr,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontFamily: 'NRT'),
                                ),
                                const SizedBox(width: 5),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const UsersGroupsCreate(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Click Here'.tr,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 11,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (isMultipleChoice)
                              showingmultiplequestionchoice(),
                            const SizedBox(
                              height: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Nointernet();
    });
  }

  Widget buildGroupDropdown() {
    return StreamBuilder<List<MyAppGroup>>(
      stream: GroupService().getGroups(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<MyAppGroup> groups = snapshot.data!;
          return DropdownButtonFormField<String>(
            focusColor: Colors.black,
            value: selectedGroupId,
            onChanged: (String? newValue) {
              setState(() {
                selectedGroupId = newValue ?? '';
                selectedGroupName =
                    groups.firstWhere((group) => group.id == newValue).name;
                // selectedGroups.add(
                //     newValue ?? ''); // Add the selected group ID to the list

                clearSelectedGroups(); // Clear the selectedGroups list
                selectedGroups.add(
                    newValue ?? ''); // Add the selected group ID to the list
              });
            },
            items: groups
                .map((group) => DropdownMenuItem<String>(
                      value: group.id,
                      child: Text(group.name),
                    ))
                .toList(),
            decoration: InputDecoration(
              labelText: 'Select Group'.tr,
              labelStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black54, width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget buildMultipleChoiceOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 33,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 60,
                  child: TextField(
                    minLines: 1,
                    maxLines: 8,
                    controller: optionController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      labelText: 'Option'.tr,
                      hintText: 'Enter Option Here'.tr,
                      labelStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14.0,
                      ),
                      prefixIcon: const Icon(
                        Icons.abc_outlined,
                        color: Colors.black,
                        size: 33,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 183, 183, 183),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 47,
                child: ElevatedButton(
                  onPressed: addOption,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget buildQuestionTypeSelector() {
    return Row(
      children: [
        Radio<String>(
          value: 'Regular',
          groupValue: selectedType,
          onChanged: (value) {
            setState(() {
              selectedType = value!;
              isMultipleChoice = false; // Hide the multiple choice field
              multipleChoiceOptions.clear(); // Clear the list of options
            });
          },
          activeColor: Colors.black,
        ),
        Text('Regular Question'.tr),
        const SizedBox(width: 16),
        Radio<String>(
          value: 'MultipleChoice',
          groupValue: selectedType,
          onChanged: (value) {
            setState(() {
              selectedType = value ?? ''; // Provide a default value if null
              isMultipleChoice = true; // Show the multiple choice field
            });
          },
          activeColor: Colors.black,
        ),
        Text('Multiple Choice'.tr),
      ],
    );
  }

  void clearSelectedGroups() {
    setState(() {
      selectedGroups.clear();
    });
  }

  @override
  void dispose() {
    optionController.dispose();
    questionController.dispose();
    questionTitleController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    selectedType = 'Regular'; // Set 'Regular' as the default choice
    // Future.delayed(const Duration(seconds: 1));
    // SeendUpdate(context);
  }

  Widget showingmultiplequestionchoice() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///obder button
          Text(
            'Multiple Choice Options:'.tr,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w400, fontSize: 12),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: multipleChoiceOptions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(multipleChoiceOptions[index]),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      multipleChoiceOptions.removeAt(index);
                    });
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // Build Image Widget with a close icon
  Widget _buildImage() {
    return Stack(
      children: [
        Center(
          child: Container(
            height: 185,
            width: 320,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: FileImage(File(_pickedImage!.path)),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned(
          right: 55,
          top: 12,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _pickedImage = null;
              });
            },
            child: Icon(Icons.close, size: 22, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Future<void> _showAlertDialog() async {
    return showDialog<void>(
        builder: (context) => CupertinoAlertDialog(
              title: Text("Error".tr),
              // ignore: prefer_const_constructors
              content: new Text("Please fill in the required fields".tr),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
        context: context);
  }

  void _showSnackBar(String message, Color backgroundColor) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 14),
      ),
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Ensure the _uploadImage function is defined as follows
  Future<String> _uploadImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child(
          'questions/${questionTitleController.text.toString()}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Start the upload
      UploadTask uploadTask = imageRef.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Wait for the upload to complete
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print("Image uploaded successfully: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      throw Exception('Failed to upload image: $e');
    }
  }
}
