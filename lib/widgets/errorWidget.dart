import 'package:flutter/material.dart';

Widget CustomErrorWidget(){
  return Center(
    child: Image(
      image: AssetImage(
        'assets/images/8_404 Error.png'
      ),
    ),
  );
}

// Widget CustomErrorWidget(){
//   return  Stack(
//     fit: StackFit.expand,
//     children: [
//       Image.asset(
//         "assets/images/8_404 Error.png",
//         fit: BoxFit.cover,
//       ),
//       Positioned(
//         // bottom: MediaQuery.of(context).size.height * 0.14,
//         // left: MediaQuery.of(context).size.width * 0.065,
//         bottom: 100,
//         left: 50,
//         child: Container(
//           decoration: BoxDecoration(
//             boxShadow: [
//               BoxShadow(
//                 offset: Offset(0, 5),
//                 blurRadius: 25,
//                 color: Colors.black.withOpacity(0.17),
//               ),
//             ],
//           ),
//           child: FlatButton(
//             color: Colors.white,
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(50)),
//             onPressed: () {},
//             child: Text("Home".toUpperCase()),
//           ),
//         ),
//       )
//     ],
//   );
// }