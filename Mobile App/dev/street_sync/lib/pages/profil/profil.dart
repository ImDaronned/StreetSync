import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:street_sync/pages/auth/auth_screen.dart';
import 'package:street_sync/pages/profil/subpages/billing.dart';
import 'package:street_sync/pages/profil/subpages/edit_profil.dart';
import 'package:street_sync/pages/profil/subpages/infos.dart';
import 'package:street_sync/pages/profil/subpages/my_events.dart';
import 'package:street_sync/pages/profil/subpages/my_service.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPage();
}

class _ProfilPage extends State<ProfilPage>{
  late Future<SharedPreferences> _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const Center(
                child: Icon(
                  Icons.people_rounded,
                  size: 100,
                ),
              ),
              const SizedBox( height: 10),
              const Text("Matheo", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              const Text("pic@gmail.com", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditProfil()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, 
                    side: BorderSide.none, 
                    shape: const StadiumBorder()
                  ),
                  child: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 30,),
              const Divider(),
              _profilMenuWidget(
                "Billing Details", 
                const Icon(Icons.credit_card, color: Colors.blueAccent,),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BillingDetailPage()),
                  );
                },
                null,
                null
              ),
              const SizedBox(height: 10,),
              _profilMenuWidget(
                "My events",
                const Icon(Icons.event, color: Colors.blueAccent,),
                () {
                  Navigator.push(
                    context,
                     MaterialPageRoute(builder: (context) => const MyEventPage()),
                  );
                },
                null,
                null
              ),
              const SizedBox(height: 10,),
              _profilMenuWidget(
                "My services",
                const Icon(Icons.plumbing, color: Colors.blueAccent,),
                () {
                  Navigator.push(
                    context,
                     MaterialPageRoute(builder: (context) => const MyServicePage()),
                  );
                },
                null,
                null
              ),
              const SizedBox(height: 10,),
              const Divider(),
              _profilMenuWidget(
                "Information",
                const Icon(Icons.info, color: Colors.blueAccent,),
                () {
                  Navigator.push(
                    context,
                     MaterialPageRoute(builder: (context) => const InfoPage()),
                  );
                },
                null,
                null
              ),
              const SizedBox(height: 10,),
              _profilMenuWidget(
                "Logout",
                const Icon(Icons.logout, color: Colors.redAccent,),
                () async {
                  final SharedPreferences prefs = await _prefs;
                  prefs.clear();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthPage()),
                    (Route<dynamic> route) => false,
                  );
                },
                Colors.red,
                true
              ),          
            ],
          ),
        ),
      )
    );
  }

  Widget _profilMenuWidget(String title, Icon icon, VoidCallback onPressed, Color? textColor, bool? last) {
    last ??= false;
    textColor ??= const Color.fromARGB(255, 0, 0, 0);

    return ListTile(
      onTap: onPressed,
      leading: Container(
        width: 50, height: 50,
          decoration: BoxDecoration(
            borderRadius:  BorderRadius.circular(100),
            color: last? textColor.withOpacity(0.1) : Colors.blueAccent.withOpacity(0.1)
          ),
          child: icon,
      ),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.grey.withOpacity(0.1)
        ),
        child: const Icon(Icons.chevron_right, size: 18, color: Colors.grey,)
      )
    );
  }
}

