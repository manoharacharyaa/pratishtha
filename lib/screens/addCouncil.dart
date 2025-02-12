// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AddCouncil extends StatefulWidget {
//   @override
//   _AddCouncilState createState() => _AddCouncilState();
// }

// class _AddCouncilState extends State<AddCouncil> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _indexController = TextEditingController();
//   final TextEditingController _postController = TextEditingController();
//   final TextEditingController _yearController = TextEditingController();

//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       FirebaseFirestore.instance.collection('council2425').add({
//         'name': _nameController.text,
//         'index': _indexController.text,
//         'post': _postController.text,
//         'year': _yearController.text,
//       }).then((value) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Council member added successfully')),
//         );
//         _formKey.currentState!;
//       }).catchError((error) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to add council member: $error')),
//         );
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add Council Member'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
        
//               TextFormField(
//                 controller: _nameController,
//                 decoration: InputDecoration(labelText: 'Name'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a name';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _indexController,
//                 decoration: InputDecoration(labelText: 'Index'),
//                 keyboardType: TextInputType.text,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter an index';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _postController,
//                 decoration: InputDecoration(labelText: 'Post'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a post';
//                   }
//                   return null;
//                 },
//               ),
 
//               TextFormField(
//                 controller: _yearController,
//                 decoration: InputDecoration(labelText: 'Year'),
//                 keyboardType: TextInputType.text,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a year';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _submitForm,
//                 child: Text('Submit'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }