import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/screens/admin/event_approval/approval_page.dart';
import 'package:pratishtha/screens/admin/event_approval/regristration_model.dart';
import 'package:pratishtha/utils/fonts.dart';

class RegistrationListPage extends StatefulWidget {
  const RegistrationListPage({super.key});

  @override
  State<RegistrationListPage> createState() => _ApproRegistrationtate();
}

class _ApproRegistrationtate extends State<RegistrationListPage> {
  final searchController = TextEditingController();

  List<RegistrationModel> allEvents = [];
  List<Registration> filteredRegistrations = [];

  bool isLoading = true;

  Future<void> fetchEvents() async {
    setState(() => isLoading = true);

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('registrations').get();

    final events = querySnapshot.docs
        .map((event) =>
            RegistrationModel.fromJson(event.data() as Map<String, dynamic>))
        .toList();

    setState(() {
      allEvents = events;
      if (searchController.text.isNotEmpty) {
        final query = searchController.text.toLowerCase();
        allEvents = allEvents
            .where((event) => event.eventName.toLowerCase().contains(query))
            .toList();
      }
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchEvents();
    searchController.addListener(() {
      fetchEvents();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Events',
          style: AppFonts.poppins(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            CustomSearchBar(searchController: searchController),
            const SizedBox(height: 10),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: allEvents.isEmpty
                        ? Text('No events found')
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: allEvents.length,
                            itemBuilder: (context, index) {
                              final event = allEvents[index];
                              return InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ApprovalPage(
                                      event: event,
                                    ),
                                  ),
                                ),
                                child: CustomListTile(
                                  eventName: event.eventName,
                                  eventImg: event.eventImg,
                                ),
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    super.key,
    required this.eventName,
    required this.eventImg,
  });

  final String eventName;
  final String eventImg;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              height: 75,
              width: 125,
              margin: EdgeInsets.fromLTRB(12, 0, 20, 0),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: eventImg.isEmpty
                  ? Center(
                      child: Text(
                        eventName,
                        style: AppFonts.poppins(color: secondaryColor),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        eventImg,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            SizedBox(
              width: size.width * 0.35,
              child: Text(
                eventName,
                style: AppFonts.poppins(),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Icon(
                Icons.arrow_forward_ios,
                color: primaryColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({
    super.key,
    required this.searchController,
  });

  final TextEditingController searchController;

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  bool _isEmpty = true;

  @override
  void initState() {
    super.initState();
    _isEmpty = widget.searchController.text.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.searchController,
      maxLines: 1,
      cursorColor: Colors.black,
      cursorHeight: 20,
      onChanged: (value) {
        setState(() {
          _isEmpty = value.isEmpty;
        });
      },
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search, color: primaryColor),
        suffixIcon: _isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  setState(() {
                    _isEmpty = true;
                    widget.searchController.clear();
                  });
                },
                icon: Icon(Icons.cancel_outlined, color: primaryColor),
              ),
        hintText: 'Search events',
        hintStyle: AppFonts.poppins(size: 16, color: primaryColor),
        enabled: true,
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
