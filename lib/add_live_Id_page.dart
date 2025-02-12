import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/is_live_provider.dart';
import 'package:pratishtha/models/live_stream_model.dart';
import 'package:pratishtha/utils/fonts.dart';
import 'package:pratishtha/widgets/customTextField.dart';
import 'package:provider/provider.dart';

class AddLiveIdPage extends StatefulWidget {
  const AddLiveIdPage({super.key});

  @override
  State<AddLiveIdPage> createState() => _AddLiveIdPage();
}

class _AddLiveIdPage extends State<AddLiveIdPage> {
  bool _isLoading = false;
  TextEditingController _liveIdController = TextEditingController();
  TextEditingController _titleController = TextEditingController();

  setIsLoading(bool isLoading) async {
    setState(() {
      _isLoading = isLoading;
    });
  }

  void addLiveId() async {
    setIsLoading(true);

    DocumentReference docRef = FirebaseFirestore.instance
        .collection('livestreamIds')
        .doc('liveStreams');

    try {
      DocumentSnapshot documentSnapshot = await docRef.get();

      List<LiveStreamModel> existingStreams = [];

      if (documentSnapshot.exists && documentSnapshot.data() != null) {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        if (data.containsKey('streams')) {
          existingStreams = (data['streams'] as List)
              .map((stream) => LiveStreamModel.fromJson(stream))
              .toList();
        }
      }

      LiveStreamModel streamDetails = LiveStreamModel(
        liveId: _liveIdController.text,
        title: _titleController.text,
        isLive: false,
      );

      existingStreams.add(streamDetails);

      await docRef.set({
        'streams': existingStreams.map((stream) => stream.toJson()).toList(),
      }, SetOptions(merge: true));

      setIsLoading(false);
      _liveIdController.clear();
      _titleController.clear();
      Fluttertoast.showToast(
        msg: 'Added Successfully',
        backgroundColor: greenColor,
      );
    } catch (e) {
      setIsLoading(false);
      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  void dispose() {
    _liveIdController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Live ID',
          style: AppFonts.poppins(),
        ),
      ),
      body: ListView(
        children: [
          CustomTextField1(
            controller: _liveIdController,
            hintText: 'Enter YouTube Livestreem ID',
          ),
          CustomTextField1(
            controller: _titleController,
            hintText: 'Enter  Livestreem Title',
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: addLiveId,
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Add Live Stream',
                      style: AppFonts.poppins(
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  primaryColor,
                ),
                fixedSize: WidgetStatePropertyAll(
                  Size(double.maxFinite, 50),
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                padding: WidgetStatePropertyAll(
                  EdgeInsets.all(10),
                ),
              ),
            ),
          ),
          Consumer<IsLiveProvider>(builder: (context, provider, child) {
            return FutureBuilder(
              future: provider.fetchAllStreams(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.data!.isEmpty || snapshot.hasError) {
                  return Center(child: Text('No Data Found'));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final stream = snapshot.data![index];
                    return ListTile(
                      title: Text(stream.title),
                      trailing: CupertinoSwitch(
                        value: true,
                        onChanged: (value) {},
                      ),
                    );
                  },
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
