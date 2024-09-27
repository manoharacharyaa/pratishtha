import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pratishtha/models/ewalletModel.dart';
import 'package:pratishtha/services/databaseServices.dart';

class WalletServices {
  final CollectionReference walletCollection =
      FirebaseFirestore.instance.collection('e-wallet');

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  //Add Money in Wallet
  Future addMoney({String? toUid, String? value}) async {
    var userdata = await DatabaseServices().getCurrentUser();
    if (userdata.role >= 1) {
      var walletData = walletCollection.doc();
      await walletData.set(walletToJson(EWallet(
          value: value,
          addedto: toUid,
          addedby: userdata.uid,
          date: DateTime.now(),
          reason: int.parse(value!)>0 ? "Money added to Wallet" : "Money deducted from Wallet")));

      return await userCollection.doc(toUid).update({
        "wallet": FieldValue.increment(int.parse(value)),
        "wallet_history": FieldValue.arrayUnion([walletData.id])
      });
    } else {
      return false;
    }
  }

  //Get Wallet history
  Future<EWallet> getWalletHist(String id) async {
    var walletdata = await walletCollection.doc(id).get();
    return walletFromMap(walletdata.data() as Map<String, dynamic>, walletdata.id);
  }
}
