import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:data_connection_checker_nulls/data_connection_checker_nulls.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
import 'package:pratishtha/widgets/noConnectionScreen.dart';

checkConection({Widget? child}) {
  //DataConnectionChecker().checkInterval = Duration(seconds: 20);
  return StatefulBuilder(builder: (context, setState) {
    return StreamBuilder<ConnectivityResult>(
      stream: Connectivity().onConnectivityChanged,
      builder: (
        BuildContext context,
        AsyncSnapshot<ConnectivityResult> snapshot,
      ) {
        if (snapshot.data == ConnectivityResult.none) {
          return NoConnectionScreen(setState);
        } else {
          return StreamBuilder<DataConnectionStatus>(
            stream: DataConnectionChecker().onStatusChange,
            builder: (context, snap) {
              if (snap.data == DataConnectionStatus.disconnected) {
                return NoConnectionScreen(setState);
              } else {
                return child!;
              }
            },
          );
        }
      },
    );
  });
}

          // SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          //   showModalBottomSheet(
          //     context: context,
          //     elevation: 5,
          //     isDismissible: false,
          //     builder: (BuildContext context) {
          //       return NoConnectionScreen();
          //     },
          //   );
          // });