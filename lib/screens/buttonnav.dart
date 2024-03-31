import 'package:flutter/material.dart';
import 'package:podcast/screens/Home_page.dart';
import 'package:podcast/screens/frontpgae.dart';
import 'package:podcast/screens/profilepage.dart';

class buttomPage extends StatefulWidget {
  const buttomPage({super.key});

  @override
  State<buttomPage> createState() => _buttomPageState();
}

class _buttomPageState extends State<buttomPage> {
  int currentIndex = 0;



  void _selected(int index){
    setState(() {
      currentIndex = index;
    });
  }

    final List <Widget> _screens = [
  HighPopularityPodcastScreen(),
   PodcastScreen(),
   UserProfilePage(),

 

];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        // selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        currentIndex: currentIndex,
        elevation: 0,
        onTap: _selected,
        items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
         BottomNavigationBarItem(
          icon: Icon(Icons.person_2_sharp),
          label: 'Search',
        ),

      ]),
    );
  }
}