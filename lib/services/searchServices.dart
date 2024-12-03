import 'package:pratishtha/models/eventModel.dart';
import 'package:pratishtha/models/userModel.dart';

List<Event> eventSearch({String? query, List<Event>? allEventsList}) {
  List<Event> eventSearchResults = [];
  allEventsList!.forEach((event) {
    if (event.name!.toLowerCase().contains(query!.toLowerCase())
        //|| event.description.toLowerCase().contains(query.toLowerCase())
        ) {
      eventSearchResults.add(event);
    }
  });
  return eventSearchResults;
}

List<User> userSearch({String? query, List<User>? allUsersList}) {
  List<User> userSearchResults = [];
  allUsersList!.forEach((user) {
    if (user.firstName!.toLowerCase().contains(query!.toLowerCase()) ||
        user.lastName!.toLowerCase().contains(query.toLowerCase()) ||
        '${user.firstName! + " " + user.lastName!}'
            .toLowerCase()
            .contains(query.toLowerCase()) ||
        user.phone!.toLowerCase() == query.toLowerCase() ||
        '${user.firstName![0] + user.lastName![0]}'
            .toLowerCase()
            .contains(query.toLowerCase())) {
      userSearchResults.add(user);
    }
  });
  return userSearchResults;
}

List<int> userSearchWithIndex({String? query, List<User>? allUsersList}) {
  List<int> userSearchResults = [];
  allUsersList!.forEach((user) {});

  int length = allUsersList.length;
  for (int i = 0; i < length; i++) {
    if (allUsersList[i]
            .firstName!
            .toLowerCase()
            .contains(query!.toLowerCase()) ||
        allUsersList[i].lastName!.toLowerCase().contains(query.toLowerCase()) ||
        '${allUsersList[i].firstName! + " " + allUsersList[i].lastName!}'
            .toLowerCase()
            .contains(query.toLowerCase()) ||
        allUsersList[i].phone!.toLowerCase() == query.toLowerCase() ||
        '${allUsersList[i].firstName![0] + allUsersList[i].lastName![0]}'
            .toLowerCase()
            .contains(query.toLowerCase())) {
      userSearchResults.add(i);
    }
  }
  return userSearchResults;
}
