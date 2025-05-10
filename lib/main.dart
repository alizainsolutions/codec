import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});



  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

   var name = TextEditingController();
   var description = TextEditingController();
   var id = "";
   var storedName = "";
   bool isLoading = false;
   bool isLoading2 = false;

   @override
  void initState() {
    super.initState();
    getName();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text("Codec"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: name,
              decoration: InputDecoration(
                label: Text("Title"),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  )
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: description,
              decoration: InputDecoration(
                  label: Text("Description"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  )
              ),
            ),
          ),
          ElevatedButton(onPressed: () async{
            var myName = name.text.toString();
            var myDescription = description.text.toString();
            var myPref = await SharedPreferences.getInstance();
            myPref.setString("name", myName);
            if(myName.isNotEmpty && myDescription.isNotEmpty){
              savedDataToFirestore(myName, myDescription);
              setState(() {
                storedName = myName;
                isLoading = true;
                // savedDataToFirestore(myName);
              });
            }else
              {
                showToastMessage2("All fields are required!");
              }


          }
          , child: isLoading ? CircularProgressIndicator(color: Colors.green) : Text("Save")),
          SizedBox(height: 10,),
          ElevatedButton(onPressed: () async{
            var myName = name.text.toString();
            var myDescription = description.text.toString();
            var myPref = await SharedPreferences.getInstance();
            myPref.setString("name", myName);
            if(myName.isNotEmpty && myDescription.isNotEmpty){
              updateDataToFirestore(id, myName, myDescription);
              setState(() {
                storedName = myName;
                isLoading2 = true;
                // savedDataToFirestore(myName);
              });
            }else
            {
              showToastMessage2("All fields are required!");
            }


          }
              , child: isLoading2 ? CircularProgressIndicator(color: Colors.green) : Text("Update")),
          // Text(storedName),
          SizedBox(height: 10,),
          StreamBuilder(stream: FirebaseFirestore.instance.collection("Notes").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(),);
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("Data not found"));
                }

                final notes = snapshot.data!.docs;
                return Expanded(
                  child: ListView.builder(itemBuilder: (context, index)

                  {
                    final note = notes[index];
                    final title = note["title"];
                    final descriptions = note["description"];

                    return GestureDetector(
                      onTap: (){
                         name.text = title;
                        description.text = descriptions;
                        id = note.id;
                      },
                      onDoubleTap: (){
                        deleteItem(note.id);
                      } ,
                      child: Card(
                        child: ListTile(
                          title: Text(title),
                          subtitle: Text(descriptions),
                        ),
                      ),
                    );
                  },
                  itemCount: notes.length,),
                );
              } )
        ],
      ),



    );
  }
  void getName() async{
    var myPref = await SharedPreferences.getInstance();
    var myName = myPref.getString("name");
    storedName = myName!;

  }

  void savedDataToFirestore(String title, String descriptions){
     FirebaseFirestore.instance.collection("Notes").add({
       "title": title,
       "description": descriptions,
     }).then((value) {
       showToastMessage("Saved Successfully!");
       name.clear();
       description.clear();
       setState(() {
         isLoading = false;
       });
       print("Data Added");
     }).catchError((error){
       print(error.toString());
     });


  }
   void updateDataToFirestore(String id, String title, String descriptions){
     FirebaseFirestore.instance.collection("Notes").doc(id).update({
       "title": title,
       "description": descriptions,
     }).then((value) {
       showToastMessage("Updated Successfully!");
       name.clear();
       description.clear();
       setState(() {
         isLoading2 = false;
       });
       print("Data Added");
     }).catchError((error){
       print(error.toString());
     });


   }
  
  void showToastMessage(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );

  }
   void showToastMessage2(String message){
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
         content: Text(message),
         duration: Duration(seconds: 2),
         backgroundColor: Colors.red,
       ),
     );

   }
   void deleteItem(String id){
     FirebaseFirestore.instance.collection("Notes").doc(id).delete().then((value) {
       showToastMessage("Deleted Successfully!");
     });
   }



}
