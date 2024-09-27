import 'package:pratishtha/widgets/userCard.dart';
import 'package:pratishtha/models/userModel.dart';

List<UserCard> getListOfUserCards(List<User> userList){
  List<UserCard> userCardList = [];
  userList.forEach((user) {
    userCardList.add(
      UserCard(user: user)
    );
  });
  return userCardList;
}