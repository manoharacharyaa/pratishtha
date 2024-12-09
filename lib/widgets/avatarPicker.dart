import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pratishtha/constants/avatars.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:pratishtha/services/databaseServices.dart';

class AvatarPicker extends StatefulWidget {
  AvatarPicker({super.key, this.currentUser});

  User? currentUser;

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  DatabaseServices databaseServices = DatabaseServices();
  int selectedAvatar = 4;

  @override
  void initState() {
    super.initState();
    selectedAvatar = this.widget.currentUser!.avatar;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        color: eggShell,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height / 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(avatarMap[selectedAvatar]!),
                //child: Image.asset('assets/images/Asset 1.png'),
                // child: Text("P"),
              ),
              SizedBox(
                height: 50.0,
              ),
              Text(
                'Choose your avatar',
                style: TextStyle(
                  color: blackColor,
                  fontSize: 30,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 30,
                      mainAxisSpacing: 20,
                      //childAspectRatio: (MediaQuery.of(context).size.width/2.2)/MediaQuery.of(context).size.height/5
                    ),
                    itemCount: avatarMap.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: MediaQuery.of(context).size.width / 2.2,
                        height: MediaQuery.of(context).size.height / 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(eggShell),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedAvatar = index;
                            });
                          },
                          child: SvgPicture.asset(avatarMap[index]!),
                        ),
                        //child: Image.asset('assets/images/Asset 1.png'),
                        // child: Text("P"),
                      );
                    }),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  await databaseServices.updateAvatar(
                      avatar: selectedAvatar,
                      currentUser: this.widget.currentUser!);
                  Navigator.pop(context);
                },
                child: Text(
                  'Confirm',
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
